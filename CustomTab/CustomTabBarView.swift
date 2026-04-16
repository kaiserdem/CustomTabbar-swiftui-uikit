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

    private let indicatorLineView = UIView()
    private let indicatorGradient = CAGradientLayer()

    private var tapButtonsByTab: [TabIdentifier: UIButton] = [:]
    private var iconViewsByTab: [TabIdentifier: UIImageView] = [:]
    private var titleLabelsByTab: [TabIdentifier: UILabel] = [:]
    private var centerCircleByTab: [TabIdentifier: UIView] = [:]

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

        // Малюємо фон через shape layer (не mask), щоб “виямка” була темною,
        // а не прозорою (і не показувала білий контент позаду).
        backgroundView.backgroundColor = .clear
        backgroundShapeLayer.fillColor = UIColor(white: 0.12, alpha: 1.0).cgColor
        backgroundShapeLayer.strokeColor = nil
        backgroundView.layer.insertSublayer(backgroundShapeLayer, at: 0)
        addSubview(backgroundView)

        indicatorLineView.backgroundColor = .clear
        indicatorLineView.isUserInteractionEnabled = false
        indicatorLineView.layer.cornerRadius = 2
        addSubview(indicatorLineView)

        indicatorGradient.colors = [
            UIColor.systemYellow.withAlphaComponent(0.2).cgColor,
            UIColor.systemYellow.withAlphaComponent(1.0).cgColor,
            UIColor.systemYellow.withAlphaComponent(0.2).cgColor
        ]
        indicatorGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        indicatorGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        indicatorLineView.layer.addSublayer(indicatorGradient)

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
            label.font = .systemFont(ofSize: 16, weight: .semibold)
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
                addSubview(circle)
                centerCircleByTab[item.tab] = circle
            }
        }
    }

    @objc private func didTap(_ sender: UIButton) {
        guard let tab = TabIdentifier(rawValue: sender.tag) else { return }
        onSelect?(tab)
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

        for item in items {
            let t = item.tab
            let isSelected = t == tab

            let iconColor: UIColor
            let titleColor: UIColor

            if item.isCenter {
                iconColor = .black
                titleColor = isSelected ? selectedColor : unselectedColor
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

        let indicatorWidth = targetRect.width
        let targetFrame = CGRect(x: targetRect.midX - indicatorWidth / 2, y: targetRect.minY, width: indicatorWidth, height: targetRect.height)

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) { [weak self] in
                guard let self else { return }
                self.indicatorLineView.frame = targetFrame
                self.indicatorGradient.frame = self.indicatorLineView.bounds
            }
            animateShimmer(from: oldTab, to: tab)
        } else {
            indicatorLineView.frame = targetFrame
            indicatorGradient.frame = indicatorLineView.bounds
        }
    }

    private func animateShimmer(from oldTab: TabIdentifier?, to newTab: TabIdentifier) {
        indicatorGradient.removeAllAnimations()

        // “Перелив” — швидкий зсув градієнта в межах лінії.
        let anim = CABasicAnimation(keyPath: "locations")
        anim.duration = 0.28
        anim.fromValue = [0.0, 0.45, 1.0]
        anim.toValue = [0.2, 0.65, 1.15]
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        indicatorGradient.add(anim, forKey: "shimmer")
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

        indicatorGradient.frame = indicatorLineView.bounds

        // “Яма” під середньою кнопкою: малюємо ввігнуту форму верхнього краю TabBar.
        let centerIndex = items.firstIndex(where: { $0.isCenter }) ?? 0
        let circleSize: CGFloat = 60
        let circleY = barTopY - 40 - contentLift
        let centerX = backgroundView.frame.minX + slotWidth * (CGFloat(centerIndex) + 0.5)
        let localCenterX = centerX - backgroundView.frame.minX
        _ = circleY // використовується для вирівнювання кнопки відносно trough

        let notchWidth = min(backgroundView.bounds.width, slotWidth * 1.65)
        let notchDepth = min(34, max(20, 42 - contentLift))
        let xLeft = max(0, localCenterX - notchWidth / 2)
        let xRight = min(backgroundView.bounds.width, localCenterX + notchWidth / 2)
        let yTop: CGFloat = 13 // регулює, наскільки “опущена” виямка
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

        // Лінія підсвітки зверху (як на фото).
        let indicatorY = barTopY + 14 - contentLift
        let indicatorHeight: CGFloat = 4

        // Позиціонуємо кнопки, іконки, лейбли, а також слоти для індикатора.
        for (index, item) in items.enumerated() {
            let tab = item.tab
            let centerX = backgroundView.frame.minX + slotWidth * (CGFloat(index) + 0.5)

            if item.isCenter {
                let circleSize: CGFloat = 66
                let circleY = barTopY - 18 - contentLift
                centerCircleByTab[tab]?.frame = CGRect(x: centerX - circleSize / 2, y: circleY, width: circleSize, height: circleSize)

                let iconSize: CGFloat = 26
                iconViewsByTab[tab]?.frame = CGRect(x: centerX - iconSize / 2, y: circleY + circleSize / 2 - iconSize / 2, width: iconSize, height: iconSize)

                // Tap area включає іконку + підпис.
                let tapH: CGFloat = (barBottomY - barTopY) + 10
                let tapY = barTopY - 22
                tapButtonsByTab[tab]?.frame = CGRect(x: centerX - slotWidth / 2, y: tapY, width: slotWidth, height: tapH)

                // Підпис нижче, як на фото.
                let labelH: CGFloat = 22
                titleLabelsByTab[tab]?.frame = CGRect(
                    x: centerX - slotWidth / 2,
                    y: barBottomY - labelH - 2 - contentLift - 10,
                    width: slotWidth,
                    height: labelH
                )

                // Індикація для center — все одно існує, але зазвичай на фото вибрана не вона.
                let indicatorWidth: CGFloat = 44
                slotRects[tab] = CGRect(x: centerX - indicatorWidth / 2, y: indicatorY, width: indicatorWidth, height: indicatorHeight)
            } else {
                let iconSize: CGFloat = 26
                let iconY = barTopY + 22 - contentLift
                iconViewsByTab[tab]?.frame = CGRect(x: centerX - iconSize / 2, y: iconY, width: iconSize, height: iconSize)

                // Tap area.
                let tapY = barTopY
                let tapH = barBottomY - barTopY
                tapButtonsByTab[tab]?.frame = CGRect(x: centerX - slotWidth / 2, y: tapY, width: slotWidth, height: tapH)

                // Підпис.
                let labelH: CGFloat = 22
                titleLabelsByTab[tab]?.frame = CGRect(
                    x: centerX - slotWidth / 2,
                    y: barBottomY - labelH - 2 - contentLift - 10,
                    width: slotWidth,
                    height: labelH
                )

                let indicatorWidth: CGFloat = 48
                slotRects[tab] = CGRect(x: centerX - indicatorWidth / 2, y: indicatorY, width: indicatorWidth, height: indicatorHeight)
            }
        }

        indicatorLineView.layer.cornerRadius = indicatorHeight / 2
        indicatorGradient.frame = indicatorLineView.bounds

        // Підтягнемо індикатор у поточний стан після layout.
        if let tab = selectedTab {
            if indicatorLineView.frame == .zero {
                setSelectedTab(tab, animated: false)
            } else {
                setSelectedTab(tab, animated: false)
            }
        }
    }
}

