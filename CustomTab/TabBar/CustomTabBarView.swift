import UIKit

final class CustomTabBarView: UIView {
    struct Item {
        let tab: TabIdentifier
        let systemImage: String
        let isCenter: Bool
        let title: String
    }

    private let items: [Item]
    private var selectedTab: TabIdentifier?
    private var onSelect: ((TabIdentifier) -> Void)?

    private var slotRects: [TabIdentifier: CGRect] = [:] // для індикатора (лінія)

    private let backgroundView = UIView()
    private let backgroundShapeLayer = CAShapeLayer()
    private let backgroundTopStrokeLayer = CAShapeLayer()

    // Індикатор-стрічка як набір сегментів (щоб вигинатися по кривій).
    private let indicatorSegmentsContainer = CALayer()
    private var indicatorSegments: [CALayer] = []
    private let indicatorSegmentsCount = 20
    private let indicatorRibbonWidthScale: CGFloat = 0.50
    private let indicatorThicknessScale: CGFloat = 0.58
    private let indicatorSegmentFillFactor: CGFloat = 1.16
    private let indicatorMoveDuration: CFTimeInterval = 0.22
    private var indicatorCurrentCenterX: CGFloat?
    private var indicatorCurrentBaseY: CGFloat?
    private var indicatorCurrentWidth: CGFloat?
    private var indicatorCurrentHeight: CGFloat?

    private var tapButtonsByTab: [TabIdentifier: UIButton] = [:]
    private var iconViewsByTab: [TabIdentifier: UIImageView] = [:]
    private var titleLabelsByTab: [TabIdentifier: UILabel] = [:]
    private var centerCircleByTab: [TabIdentifier: UIView] = [:]

    private var pendingMenuHighlight: DispatchWorkItem?

    private var centerIconRotation: CGFloat = 0
    private var centerIconScale: CGFloat = 1.0
    private var isCenterIconAnimating: Bool = false
    private let centerIconActiveScale: CGFloat = 1.16
    private let centerIconSpinDuration: TimeInterval = 0.32
    private let centerIconScaleDuration: TimeInterval = 0.18

    /// Зсув жовтого кола **вниз** (у pt). Більше значення — коло нижче (`circleY` збільшується).
    private let centerCircleExtraDown: CGFloat = 0

    /// Прозорість темного фону бару (0…1). Менше — помітніший контент, що заходить під таббар.
    private let tabBarBackgroundAlpha: CGFloat = 0.78

    // Геометрія заглиблення для анімації індикатора.
    private var notchXLeft: CGFloat = 0
    private var notchXRight: CGFloat = 0
    private var notchDepth: CGFloat = 0
    private var notchSamples: [CGPoint] = [] // x в координатах Self, y = localYOffset (0...yBottom)

    init(
        items: [Item],
        selectedTab: TabIdentifier?,
        onSelect: ((TabIdentifier) -> Void)?
    ) {
        self.items = items
        self.selectedTab = selectedTab
        self.onSelect = onSelect
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        clipsToBounds = false
        isOpaque = false
        backgroundColor = .clear

        // Малюємо фон через shape layer (не mask). Напівпрозорий fill — видно відтінок контенту під баром.
        backgroundView.backgroundColor = .clear
        backgroundView.isOpaque = false
        backgroundView.isUserInteractionEnabled = false
        backgroundShapeLayer.fillColor = UIColor(white: 0.12, alpha: tabBarBackgroundAlpha).cgColor
        backgroundShapeLayer.strokeColor = nil
        backgroundView.layer.insertSublayer(backgroundShapeLayer, at: 0)

        // Ледь помітна лінія по верхньому контуру (щоб бар не зливався з чорним фоном).
        backgroundTopStrokeLayer.fillColor = UIColor.clear.cgColor
        backgroundTopStrokeLayer.strokeColor = UIColor.white.withAlphaComponent(0.14).cgColor
        backgroundTopStrokeLayer.lineWidth = 1
        backgroundTopStrokeLayer.lineCap = .round
        backgroundTopStrokeLayer.lineJoin = .round
        backgroundView.layer.addSublayer(backgroundTopStrokeLayer)
        addSubview(backgroundView)

        indicatorSegmentsContainer.masksToBounds = false
        layer.addSublayer(indicatorSegmentsContainer)
        ensureIndicatorSegments()

        for item in items {
            // Tap area
            let tap = UIButton(type: .custom)
            tap.backgroundColor = .clear
            tap.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
            tap.tag = item.tab.rawValue
            addSubview(tap)
            tapButtonsByTab[item.tab] = tap

            // Icon
            let icon = UIImageView(image: UIImage(systemName: item.systemImage))
            icon.contentMode = .scaleAspectFit
            addSubview(icon)
            iconViewsByTab[item.tab] = icon

            // Title (для не-центральних, і для центру теж буде підпис)
            let label = UILabel()
            label.text = item.title
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 11, weight: .semibold)
            addSubview(label)
            titleLabelsByTab[item.tab] = label

            if item.isCenter {
                let circle = UIView()
                circle.backgroundColor = UIColor.systemYellow
                circle.layer.cornerRadius = 30
                circle.layer.shadowColor = UIColor.black.cgColor
                circle.layer.shadowOpacity = 0.25
                circle.layer.shadowRadius = 12
                circle.layer.shadowOffset = CGSize(width: 0, height: 4)
                circle.isUserInteractionEnabled = false
                addSubview(circle)
                centerCircleByTab[item.tab] = circle

                // Важливо: коло додається пізніше і може перекривати іконку.
                // Підіймаємо іконку/текст/тап-зону над колом.
                if let icon = iconViewsByTab[item.tab] {
                    bringSubviewToFront(icon)
                }
                if let label = titleLabelsByTab[item.tab] {
                    bringSubviewToFront(label)
                }
                if let tap = tapButtonsByTab[item.tab] {
                    bringSubviewToFront(tap)
                }
            }
        }
    }

    @objc private func didTap(_ sender: UIButton) {
        guard let tab = TabIdentifier(rawValue: sender.tag) else { return }
        onSelect?(tab)
    }

    private func centerIconViewTransform(rotation: CGFloat, scale: CGFloat) -> CGAffineTransform {
        CGAffineTransform(rotationAngle: rotation).scaledBy(x: scale, y: scale)
    }

    private func updateCenterIconForSelection(from oldTab: TabIdentifier?, to newTab: TabIdentifier, animated: Bool) {
        guard let icon = iconViewsByTab[.create] else { return }

        if newTab == .create {
            if animated {
                guard oldTab != .create else { return }
                animateCenterIconSelect()
            } else if !isCenterIconAnimating {
                centerIconScale = centerIconActiveScale
                icon.transform = centerIconViewTransform(rotation: centerIconRotation, scale: centerIconScale)
            }
            return
        }

        guard oldTab == .create else { return }
        if animated {
            animateCenterIconDeselect()
        } else if !isCenterIconAnimating {
            centerIconRotation = 0
            centerIconScale = 1.0
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            icon.transform = .identity
            CATransaction.commit()
        }
    }

    private func animateCenterIconSelect() {
        guard let icon = iconViewsByTab[.create] else { return }
        isCenterIconAnimating = true
        let r1 = centerIconRotation + .pi
        let s0 = centerIconScale

        UIView.animate(withDuration: centerIconSpinDuration, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
            icon.transform = self.centerIconViewTransform(rotation: r1, scale: s0)
        } completion: { [weak self] finished in
            guard let self, finished else { return }
            self.centerIconRotation = r1
            UIView.animate(withDuration: self.centerIconScaleDuration, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
                icon.transform = self.centerIconViewTransform(rotation: r1, scale: self.centerIconActiveScale)
            } completion: { [weak self] done in
                guard let self, done else { return }
                self.centerIconScale = self.centerIconActiveScale
                self.isCenterIconAnimating = false
            }
        }
    }

    private func animateCenterIconDeselect() {
        guard let icon = iconViewsByTab[.create] else { return }
        isCenterIconAnimating = true
        let r1 = centerIconRotation + .pi
        let s0 = centerIconScale

        UIView.animate(withDuration: centerIconSpinDuration, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
            icon.transform = self.centerIconViewTransform(rotation: r1, scale: s0)
        } completion: { [weak self] finished in
            guard let self, finished else { return }
            self.centerIconRotation = r1
            UIView.animate(withDuration: self.centerIconScaleDuration, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
                icon.transform = self.centerIconViewTransform(rotation: r1, scale: 1.0)
            } completion: { [weak self] done in
                guard let self, done else { return }
                self.centerIconRotation = 0
                self.centerIconScale = 1.0
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                icon.transform = .identity
                CATransaction.commit()
                self.isCenterIconAnimating = false
            }
        }
    }

    private func applyCenterGlow(active: Bool, animated: Bool) {
        guard let circle = centerCircleByTab[.create] else { return }

        let changes = {
            if active {
                circle.layer.shadowColor = UIColor.systemYellow.cgColor
                circle.layer.shadowOpacity = 0.75
                circle.layer.shadowRadius = 18
                circle.layer.shadowOffset = .zero
            } else {
                circle.layer.shadowColor = UIColor.black.cgColor
                circle.layer.shadowOpacity = 0.25
                circle.layer.shadowRadius = 12
                circle.layer.shadowOffset = CGSize(width: 0, height: 4)
            }
        }

        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            changes()
            CATransaction.commit()
            return
        }

        let duration: CFTimeInterval = 0.18

        let animOpacity = CABasicAnimation(keyPath: "shadowOpacity")
        animOpacity.duration = duration
        animOpacity.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animOpacity.fromValue = circle.layer.shadowOpacity

        let animRadius = CABasicAnimation(keyPath: "shadowRadius")
        animRadius.duration = duration
        animRadius.timingFunction = animOpacity.timingFunction
        animRadius.fromValue = circle.layer.shadowRadius

        let animOffset = CABasicAnimation(keyPath: "shadowOffset")
        animOffset.duration = duration
        animOffset.timingFunction = animOpacity.timingFunction
        animOffset.fromValue = NSValue(cgSize: circle.layer.shadowOffset)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        changes()
        CATransaction.commit()

        animOpacity.toValue = circle.layer.shadowOpacity
        animRadius.toValue = circle.layer.shadowRadius
        animOffset.toValue = NSValue(cgSize: circle.layer.shadowOffset)

        circle.layer.add(animOpacity, forKey: "centerGlowOpacity")
        circle.layer.add(animRadius, forKey: "centerGlowRadius")
        circle.layer.add(animOffset, forKey: "centerGlowOffset")
    }

    // Щоб середня кнопка (яка вище за bounds) все одно ловила дотики,
    // як в підході з custom UITabBar.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0.01 else { return nil }
        for member in subviews.reversed() {
            let subPoint = member.convert(point, from: self)
            if let result = member.hitTest(subPoint, with: event) {
                return result
            }
        }
        return super.hitTest(point, with: event)
    }

    func setSelectedTab(_ tab: TabIdentifier, animated: Bool) {
        let oldTab = selectedTab
        selectedTab = tab

        // Оновлюємо іконки/тексти.
        let selectedColor = UIColor.systemYellow
        let unselectedColor = UIColor(white: 0.55, alpha: 1.0)

        // Якщо ми йдемо з меню — відміняємо заплановану підсвітку.
        pendingMenuHighlight?.cancel()
        pendingMenuHighlight = nil

        for item in items {
            let t = item.tab
            let isSelected = t == tab

            let iconColor: UIColor
            let titleColor: UIColor

            if item.isCenter {
                iconColor = .black
                // Для меню робимо відкладену підсвітку (після того як індикатор сховається).
                titleColor = isSelected ? unselectedColor : unselectedColor
            } else {
                iconColor = isSelected ? selectedColor : unselectedColor
                titleColor = isSelected ? selectedColor : unselectedColor
            }

            iconViewsByTab[t]?.tintColor = iconColor
            titleLabelsByTab[t]?.textColor = titleColor
        }

        guard let targetRect = slotRects[tab] else {
            // layout ще не відпрацював
            return
        }

        updateCenterIconForSelection(from: oldTab, to: tab, animated: animated)

        // Якщо обрана середня вкладка — спочатку анімуємо індикатор у центр (в заглиблення),
        // а вже після того ховаємо його (щоб виглядало як “перетворення” у текст).
        if tab == .create {
            // Показуємо індикатор (якщо був прихований), щоб було видно рух.
            setIndicatorHidden(false, animated: animated)

            // Ціль руху — центр вкладки create.
            guard let centerRect = slotRects[.create] else { return }
            let indicatorWidth = centerRect.width * indicatorRibbonWidthScale
            let indicatorHeight = max(1.5, centerRect.height * indicatorThicknessScale)
            let targetCenterX = centerRect.midX
            let baseY = centerRect.midY

            let fromX = indicatorCurrentCenterX ?? targetCenterX
            let fromBaseY = indicatorCurrentBaseY ?? baseY

            indicatorCurrentCenterX = targetCenterX
            indicatorCurrentBaseY = baseY
            indicatorCurrentWidth = indicatorWidth
            indicatorCurrentHeight = indicatorHeight

            // Кінцевий стан.
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layoutIndicatorSegments(centerX: targetCenterX, baseY: baseY, width: indicatorWidth, height: indicatorHeight)
            CATransaction.commit()

            if animated {
                animateIndicatorSegments(
                    fromCenterX: fromX,
                    fromBaseY: fromBaseY,
                    toCenterX: targetCenterX,
                    toBaseY: baseY,
                    width: indicatorWidth,
                    height: indicatorHeight,
                    duration: indicatorMoveDuration
                )

                // Ховаємо після завершення руху вниз.
                let work = DispatchWorkItem { [weak self] in
                    guard let self else { return }
                    self.setIndicatorHidden(true, animated: true)

                    // Після fade-out індикатора підсвічуємо "Меню" жовтим, ніби індикатор його “фарбує”.
                    let fadeDuration: TimeInterval = 0.12
                    DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) { [weak self] in
                        self?.setMenuTitleHighlighted(true, animated: true)
                    }
                }
                pendingMenuHighlight = work
                DispatchQueue.main.asyncAfter(deadline: .now() + indicatorMoveDuration, execute: work)
                self.applyCenterGlow(active: true, animated: true)
            } else {
                setIndicatorHidden(true, animated: false)
                setMenuTitleHighlighted(true, animated: false)
                applyCenterGlow(active: true, animated: false)
            }
            return
        } else {
            setIndicatorHidden(false, animated: animated)
            setMenuTitleHighlighted(false, animated: animated)
            applyCenterGlow(active: false, animated: animated)
        }

        let indicatorWidth = targetRect.width * indicatorRibbonWidthScale
        let indicatorHeight = max(1.5, targetRect.height * indicatorThicknessScale)
        let targetCenterX = targetRect.midX
        let baseY = targetRect.midY

        if indicatorCurrentCenterX == nil || indicatorCurrentBaseY == nil || !animated {
            indicatorCurrentCenterX = targetCenterX
            indicatorCurrentBaseY = baseY
            indicatorCurrentWidth = indicatorWidth
            indicatorCurrentHeight = indicatorHeight
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layoutIndicatorSegments(centerX: targetCenterX, baseY: baseY, width: indicatorWidth, height: indicatorHeight)
            CATransaction.commit()
            return
        }

        let fromX = indicatorCurrentCenterX ?? targetCenterX
        let fromBaseY = indicatorCurrentBaseY ?? baseY
        indicatorCurrentCenterX = targetCenterX
        indicatorCurrentBaseY = baseY
        indicatorCurrentWidth = indicatorWidth
        indicatorCurrentHeight = indicatorHeight

        // Оновлюємо кінцевий стан без implicit-анімацій.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layoutIndicatorSegments(centerX: targetCenterX, baseY: baseY, width: indicatorWidth, height: indicatorHeight)
        CATransaction.commit()

        animateIndicatorSegments(fromCenterX: fromX, fromBaseY: fromBaseY, toCenterX: targetCenterX, toBaseY: baseY, width: indicatorWidth, height: indicatorHeight, duration: indicatorMoveDuration)
        animateShimmer(from: oldTab, to: tab)
    }

    private func setIndicatorHidden(_ hidden: Bool, animated: Bool) {
        let targetOpacity: Float = hidden ? 0.0 : 1.0
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            indicatorSegmentsContainer.opacity = targetOpacity
            CATransaction.commit()
            return
        }

        let anim = CABasicAnimation(keyPath: "opacity")
        anim.duration = 0.12
        anim.fromValue = indicatorSegmentsContainer.presentation()?.opacity ?? indicatorSegmentsContainer.opacity
        anim.toValue = targetOpacity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        indicatorSegmentsContainer.opacity = targetOpacity
        CATransaction.commit()

        indicatorSegmentsContainer.add(anim, forKey: "indicatorFade")
    }

    private func setMenuTitleHighlighted(_ highlighted: Bool, animated: Bool) {
        guard let label = titleLabelsByTab[.create] else { return }
        let target = highlighted ? UIColor.systemYellow : UIColor(white: 0.55, alpha: 1.0)
        if !animated {
            label.textColor = target
            return
        }
        UIView.transition(with: label, duration: 0.12, options: [.transitionCrossDissolve, .allowUserInteraction]) {
            label.textColor = target
        }
    }

    private func indicatorAngle(forCenterX x: CGFloat) -> CGFloat {
        // Кут дотичної до кривої заглиблення в точці x.
        // Поза заглибленням — 0 (горизонтально).
        guard notchSamples.count >= 2 else { return 0 }
        if x <= notchSamples[0].x || x >= notchSamples[notchSamples.count - 1].x { return 0 }

        // Знаходимо сусідні точки для оцінки похідної.
        var lo = 0
        var hi = notchSamples.count - 1
        while hi - lo > 1 {
            let mid = (lo + hi) / 2
            if notchSamples[mid].x < x { lo = mid } else { hi = mid }
        }

        let i0 = max(0, lo - 1)
        let i1 = min(notchSamples.count - 1, hi + 1)
        let p0 = notchSamples[i0]
        let p1 = notchSamples[i1]
        let dx = p1.x - p0.x
        if abs(dx) < 0.0001 { return 0 }
        let dy = p1.y - p0.y
        // y у notchSamples — це localYOffset, тож кут коректний.
        return atan2(dy, dx)
    }

    private func indicatorYOffset(forCenterX x: CGFloat) -> CGFloat {
        // Точне слідування по кривій заглиблення: інтерполюємо yOffset
        // по precomputed семплах тієї ж Bézier-кривої.
        guard notchSamples.count >= 2 else { return 0 }
        if x <= notchSamples[0].x { return notchSamples[0].y }
        if x >= notchSamples[notchSamples.count - 1].x { return notchSamples[notchSamples.count - 1].y }

        var lo = 0
        var hi = notchSamples.count - 1
        while hi - lo > 1 {
            let mid = (lo + hi) / 2
            if notchSamples[mid].x < x { lo = mid } else { hi = mid }
        }

        let p0 = notchSamples[lo]
        let p1 = notchSamples[hi]
        let dx = p1.x - p0.x
        if dx <= 0.0001 { return p0.y }
        let t = (x - p0.x) / dx
        return p0.y + (p1.y - p0.y) * t
    }

    private func animateShimmer(from oldTab: TabIdentifier?, to newTab: TabIdentifier) {
        // Для сегментів shimmer робимо як легку пульсацію яскравості.
        indicatorSegmentsContainer.removeAllAnimations()

        // “Перелив” — швидкий зсув градієнта в межах лінії.
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.duration = 0.28
        pulse.fromValue = 0.75
        pulse.toValue = 1.0
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        indicatorSegmentsContainer.add(pulse, forKey: "shimmerPulse")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Фон TabBar має займати всю ширину екрану (як у старих iOS-версіях),
        // тому без горизонтальних інсетів.
        let outerInsetX: CGFloat = 0
        let outerInsetTop: CGFloat = 8
        let outerInsetBottom: CGFloat = -35

        // Коли фон опускаємо вниз (negative bottom inset), контент також “їде” вниз через
        // прив'язки до `barBottomY`. Щоб кнопки виглядали вище — піднімаємо їх на величину,
        // яка залежить від того, наскільки ми опустили фон.
        // При `outerInsetBottom = -35` => contentLift ≈ 15.
        let contentLift: CGFloat = max(0, (-outerInsetBottom) - 20)

        backgroundView.frame = CGRect(
            x: outerInsetX,
            y: outerInsetTop,
            width: bounds.width - outerInsetX * 2,
            height: bounds.height - outerInsetTop - outerInsetBottom
        )

        let contentWidth = backgroundView.frame.width
        let slotCount = items.count // 5
        let slotWidth = contentWidth / CGFloat(slotCount)

        let barTopY = backgroundView.frame.minY
        let barBottomY = backgroundView.frame.maxY

        indicatorSegmentsContainer.frame = bounds

        // “Яма” під середньою кнопкою: малюємо ввігнуту форму верхнього краю TabBar.
        let centerIndex = items.firstIndex(where: { $0.isCenter }) ?? 0
        let centerX = backgroundView.frame.minX + slotWidth * (CGFloat(centerIndex) + 0.5)
        let localCenterX = centerX - backgroundView.frame.minX

        let notchWidth = min(backgroundView.bounds.width, slotWidth * 1.65)
        let notchDepth = min(34, max(20, 42 - contentLift))
        let xLeft = max(0, localCenterX - notchWidth / 2)
        let xRight = min(backgroundView.bounds.width, localCenterX + notchWidth / 2)
        let yTop: CGFloat = 12 // регулює, наскільки “опущена” виямка
        let yBottom: CGFloat = yTop + notchDepth

        let w = backgroundView.bounds.width
        let h = backgroundView.bounds.height
        let bgPath = UIBezierPath()
        bgPath.move(to: CGPoint(x: 0, y: 0))
        bgPath.addLine(to: CGPoint(x: xLeft, y: 0))
        bgPath.addCurve(
            to: CGPoint(x: localCenterX, y: yBottom),
            controlPoint1: CGPoint(x: xLeft + notchWidth * 0.25, y: 0),
            controlPoint2: CGPoint(x: localCenterX - notchWidth * 0.25, y: yBottom)
        )
        bgPath.addCurve(
            to: CGPoint(x: xRight, y: 0),
            controlPoint1: CGPoint(x: localCenterX + notchWidth * 0.25, y: yBottom),
            controlPoint2: CGPoint(x: xRight - notchWidth * 0.25, y: 0)
        )
        bgPath.addLine(to: CGPoint(x: w, y: 0))
        bgPath.addLine(to: CGPoint(x: w, y: h))
        bgPath.addLine(to: CGPoint(x: 0, y: h))
        bgPath.close()
        backgroundShapeLayer.path = bgPath.cgPath
        backgroundShapeLayer.frame = backgroundView.bounds

        // Верхній stroke повторює ту ж криву (лише верхній контур).
        let topPath = UIBezierPath()
        topPath.move(to: CGPoint(x: 0, y: 0))
        topPath.addLine(to: CGPoint(x: xLeft, y: 0))
        topPath.addCurve(
            to: CGPoint(x: localCenterX, y: yBottom),
            controlPoint1: CGPoint(x: xLeft + notchWidth * 0.25, y: 0),
            controlPoint2: CGPoint(x: localCenterX - notchWidth * 0.25, y: yBottom)
        )
        topPath.addCurve(
            to: CGPoint(x: xRight, y: 0),
            controlPoint1: CGPoint(x: localCenterX + notchWidth * 0.25, y: yBottom),
            controlPoint2: CGPoint(x: xRight - notchWidth * 0.25, y: 0)
        )
        topPath.addLine(to: CGPoint(x: w, y: 0))
        backgroundTopStrokeLayer.path = topPath.cgPath
        backgroundTopStrokeLayer.frame = backgroundView.bounds

        // Зберігаємо геометрію заглиблення в координатах Self (для індикатора).
        self.notchXLeft = backgroundView.frame.minX + xLeft
        self.notchXRight = backgroundView.frame.minX + xRight
        self.notchDepth = notchDepth

        // Семпли кривої заглиблення для індикатора (y = localYOffset, x = координати Self)
        self.notchSamples = makeNotchSamples(
            bgMinX: backgroundView.frame.minX,
            xLeft: xLeft,
            xRight: xRight,
            xMid: localCenterX,
            yTop: 0,
            yBottom: yBottom,
            notchWidth: notchWidth
        )

        // Лінія підсвітки зверху (як на фото).
        let indicatorY = barTopY + 14 - contentLift
        let indicatorHeight: CGFloat = 3.5

        // Позиціонуємо кнопки, іконки, лейбли, а також слоти для індикатора.
        let iconsDrop: CGFloat = 8
        let labelsLift: CGFloat = 8
        for (index, item) in items.enumerated() {
            let tab = item.tab
            let centerX = backgroundView.frame.minX + slotWidth * (CGFloat(index) + 0.5)

            if item.isCenter {
                let circleSize: CGFloat = 63
                // Вертикаль кола: базовий зсув від `barTopY`; `centerCircleExtraDown` опускає коло вниз.
                let circleY = barTopY - 18 - contentLift + centerCircleExtraDown
                if let circle = centerCircleByTab[tab] {
                    circle.frame = CGRect(x: centerX - circleSize / 2, y: circleY, width: circleSize, height: circleSize)
                    circle.layer.cornerRadius = circleSize / 2
                }

                // Центральна іконка трохи менша, щоб "список" виглядав акуратно.
                let iconSize: CGFloat = 22
                iconViewsByTab[tab]?.frame = CGRect(
                    x: centerX - iconSize / 2,
                    y: circleY + circleSize / 2 - iconSize / 2,
                    width: iconSize,
                    height: iconSize
                )

                // Tap area включає іконку + підпис.
                let tapH: CGFloat = (barBottomY - barTopY) + 10
                let tapY = barTopY - 22 + centerCircleExtraDown
                tapButtonsByTab[tab]?.frame = CGRect(x: centerX - slotWidth / 2, y: tapY, width: slotWidth, height: tapH)

                // Підпис нижче, як на фото.
                let labelH: CGFloat = 22
                titleLabelsByTab[tab]?.frame = CGRect(
                    x: centerX - slotWidth / 2,
                    y: barBottomY - labelH - 2 - contentLift - 10 - labelsLift,
                    width: slotWidth,
                    height: labelH
                )

                // Індикація для center — все одно існує, але зазвичай на фото вибрана не вона.
                let indicatorWidth: CGFloat = 38
                slotRects[tab] = CGRect(x: centerX - indicatorWidth / 2, y: indicatorY, width: indicatorWidth, height: indicatorHeight)
            } else {
                let iconSize: CGFloat = tab == .home ? 31 : 26
                let iconBaseY = barTopY + 22 - contentLift + iconsDrop
                // Лише «Головна»: трохи більша іконка; піднімаємо, щоб центр лишався на лінії з іншими.
                let iconY = iconBaseY - (iconSize - 26) / 2
                iconViewsByTab[tab]?.frame = CGRect(x: centerX - iconSize / 2, y: iconY, width: iconSize, height: iconSize)

                // Tap area.
                let tapY = barTopY
                let tapH = barBottomY - barTopY
                tapButtonsByTab[tab]?.frame = CGRect(x: centerX - slotWidth / 2, y: tapY, width: slotWidth, height: tapH)

                // Підпис.
                let labelH: CGFloat = 22
                titleLabelsByTab[tab]?.frame = CGRect(
                    x: centerX - slotWidth / 2,
                    y: barBottomY - labelH - 2 - contentLift - 10 - labelsLift,
                    width: slotWidth,
                    height: labelH
                )

                let indicatorWidth: CGFloat = 42
                slotRects[tab] = CGRect(x: centerX - indicatorWidth / 2, y: indicatorY, width: indicatorWidth, height: indicatorHeight)
            }
        }

        // Підтягнемо індикатор у поточний стан після layout.
        if let tab = selectedTab {
            setSelectedTab(tab, animated: false)
        }
    }

    private func ensureIndicatorSegments() {
        if !indicatorSegments.isEmpty { return }
        for _ in 0..<indicatorSegmentsCount {
            let seg = CALayer()
            seg.backgroundColor = UIColor.systemYellow.cgColor
            indicatorSegmentsContainer.addSublayer(seg)
            indicatorSegments.append(seg)
        }
    }

    private func layoutIndicatorSegments(centerX: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        ensureIndicatorSegments()

        let n = indicatorSegmentsCount
        let spacing = (n > 1) ? (width / CGFloat(n - 1)) : 0
        let segLength = max(6, width / CGFloat(n) * indicatorSegmentFillFactor)
        let segHeight = height
        let radius = segHeight / 2

        for i in 0..<n {
            let rel = CGFloat(i) - CGFloat(n - 1) / 2
            let x = centerX + rel * spacing
            let y = baseY + indicatorYOffset(forCenterX: x)
            let angle = indicatorAngle(forCenterX: x)

            let seg = indicatorSegments[i]
            seg.bounds = CGRect(x: 0, y: 0, width: segLength, height: segHeight)
            seg.cornerRadius = radius
            seg.position = CGPoint(x: x, y: y)
            seg.setAffineTransform(CGAffineTransform(rotationAngle: angle))
        }
    }

    private func animateIndicatorSegments(
        fromCenterX: CGFloat,
        fromBaseY: CGFloat,
        toCenterX: CGFloat,
        toBaseY: CGFloat,
        width: CGFloat,
        height: CGFloat,
        duration: CFTimeInterval
    ) {
        let n = indicatorSegmentsCount
        let spacing = (n > 1) ? (width / CGFloat(n - 1)) : 0

        let steps = 36
        for i in 0..<n {
            let rel = CGFloat(i) - CGFloat(n - 1) / 2

            var posValues: [NSValue] = []
            var rotValues: [NSNumber] = []
            posValues.reserveCapacity(steps + 1)
            rotValues.reserveCapacity(steps + 1)

            for s in 0...steps {
                let t = CGFloat(s) / CGFloat(steps)
                let cx = fromCenterX + (toCenterX - fromCenterX) * t
                let by = fromBaseY + (toBaseY - fromBaseY) * t
                let x = cx + rel * spacing
                let y = by + indicatorYOffset(forCenterX: x)
                let a = indicatorAngle(forCenterX: x)
                posValues.append(NSValue(cgPoint: CGPoint(x: x, y: y)))
                rotValues.append(NSNumber(value: Double(a)))
            }

            let pos = CAKeyframeAnimation(keyPath: "position")
            pos.values = posValues
            pos.duration = duration
            pos.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            let rot = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            rot.values = rotValues
            rot.duration = duration
            rot.timingFunction = pos.timingFunction

            let seg = indicatorSegments[i]
            seg.add(pos, forKey: "segPos")
            seg.add(rot, forKey: "segRot")
        }
    }

    private func makeNotchSamples(
        bgMinX: CGFloat,
        xLeft: CGFloat,
        xRight: CGFloat,
        xMid: CGFloat,
        yTop: CGFloat,
        yBottom: CGFloat,
        notchWidth: CGFloat
    ) -> [CGPoint] {
        func cubic(_ t: CGFloat, _ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGPoint {
            let mt = 1 - t
            let a = mt * mt * mt
            let b = 3 * mt * mt * t
            let c = 3 * mt * t * t
            let d = t * t * t
            return CGPoint(
                x: a * p0.x + b * p1.x + c * p2.x + d * p3.x,
                y: a * p0.y + b * p1.y + c * p2.y + d * p3.y
            )
        }

        let leftP0 = CGPoint(x: xLeft, y: yTop)
        let leftP1 = CGPoint(x: xLeft + notchWidth * 0.25, y: yTop)
        let leftP2 = CGPoint(x: xMid - notchWidth * 0.25, y: yBottom)
        let leftP3 = CGPoint(x: xMid, y: yBottom)

        let rightP0 = CGPoint(x: xMid, y: yBottom)
        let rightP1 = CGPoint(x: xMid + notchWidth * 0.25, y: yBottom)
        let rightP2 = CGPoint(x: xRight - notchWidth * 0.25, y: yTop)
        let rightP3 = CGPoint(x: xRight, y: yTop)

        let n = 72
        var pts: [CGPoint] = []
        pts.reserveCapacity(n * 2 + 1)

        for i in 0...n {
            let t = CGFloat(i) / CGFloat(n)
            let p = cubic(t, leftP0, leftP1, leftP2, leftP3)
            pts.append(CGPoint(x: bgMinX + p.x, y: p.y))
        }
        for i in 1...n {
            let t = CGFloat(i) / CGFloat(n)
            let p = cubic(t, rightP0, rightP1, rightP2, rightP3)
            pts.append(CGPoint(x: bgMinX + p.x, y: p.y))
        }

        pts.sort { $0.x < $1.x }
        return pts
    }
}

