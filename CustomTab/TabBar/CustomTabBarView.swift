//
//  CustomTabBarView.swift
//  CustomTab
//
//  Created by Yaroslav Holinskiy on 16/04/2026.
//

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

    private var slotRects: [TabIdentifier: CGRect] = [:] 

    private let backgroundView = UIView()
    private let backgroundShapeLayer = CAShapeLayer()
    private let backgroundTopStrokeLayer = CAShapeLayer()

    
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

    private let centerCircleExtraDown: CGFloat = 0
    private let tabBarBackgroundAlpha: CGFloat = 0.78

    private var notchXLeft: CGFloat = 0
    private var notchXRight: CGFloat = 0
    private var notchDepth: CGFloat = 0
    private var notchSamples: [CGPoint] = [] 

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

        
        backgroundView.backgroundColor = .clear
        backgroundView.isOpaque = false
        backgroundView.isUserInteractionEnabled = false
        backgroundShapeLayer.fillColor = UIColor(white: 0.12, alpha: tabBarBackgroundAlpha).cgColor
        backgroundShapeLayer.strokeColor = nil
        backgroundView.layer.insertSublayer(backgroundShapeLayer, at: 0)
        
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
            
            let tap = UIButton(type: .custom)
            tap.backgroundColor = .clear
            tap.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
            tap.tag = item.tab.rawValue
            addSubview(tap)
            tapButtonsByTab[item.tab] = tap

            let icon = UIImageView(image: UIImage(systemName: item.systemImage))
            icon.contentMode = .scaleAspectFit
            addSubview(icon)
            iconViewsByTab[item.tab] = icon

            
            let label = UILabel()
            label.text = item.title
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 11, weight: .semibold)
            addSubview(label)
            titleLabelsByTab[item.tab] = label

            if item.isCenter {
                let circle = UIView()
                circle.backgroundColor = UIColor.systemOrange
                circle.layer.cornerRadius = 30
                circle.layer.shadowColor = UIColor.black.cgColor
                circle.layer.shadowOpacity = 0.25
                circle.layer.shadowRadius = 8
                circle.layer.shadowOffset = CGSize(width: 0, height: 4)
                circle.isUserInteractionEnabled = false
                addSubview(circle)
                centerCircleByTab[item.tab] = circle

                
                
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
        guard let icon = iconViewsByTab[.menu] else { return }

        if newTab == .menu {
            if animated {
                guard oldTab != .menu else { return }
                animateCenterIconSelect()
            } else if !isCenterIconAnimating {
                centerIconScale = centerIconActiveScale
                icon.transform = centerIconViewTransform(rotation: centerIconRotation, scale: centerIconScale)
            }
            return
        }

        guard oldTab == .menu else { return }
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
        guard let icon = iconViewsByTab[.menu] else { return }
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
        guard let icon = iconViewsByTab[.menu] else { return }
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
        guard let circle = centerCircleByTab[.menu] else { return }

        let changes = {
            if active {
                circle.layer.shadowColor = UIColor.systemOrange.cgColor
                circle.layer.shadowOpacity = 0.75
                circle.layer.shadowRadius = 14
                circle.layer.shadowOffset = .zero
            } else {
                circle.layer.shadowColor = UIColor.black.cgColor
                circle.layer.shadowOpacity = 0.25
                circle.layer.shadowRadius = 0
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

        
        let selectedColor = UIColor.systemOrange
        let unselectedColor = UIColor(white: 0.55, alpha: 1.0)

        
        pendingMenuHighlight?.cancel()
        pendingMenuHighlight = nil

        for item in items {
            let t = item.tab
            let isSelected = t == tab

            let iconColor: UIColor
            let titleColor: UIColor

            if item.isCenter {
                iconColor = .black
                
                titleColor = isSelected ? unselectedColor : unselectedColor
            } else {
                iconColor = isSelected ? selectedColor : unselectedColor
                titleColor = isSelected ? selectedColor : unselectedColor
            }

            iconViewsByTab[t]?.tintColor = iconColor
            titleLabelsByTab[t]?.textColor = titleColor
        }

        guard let targetRect = slotRects[tab] else {
            
            return
        }

        updateCenterIconForSelection(from: oldTab, to: tab, animated: animated)

        
        
        if tab == .menu {
            
            setIndicatorHidden(false, animated: animated)

            
            guard let centerRect = slotRects[.menu] else { return }
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

                
                let work = DispatchWorkItem { [weak self] in
                    guard let self else { return }
                    self.setIndicatorHidden(true, animated: true)

                    
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
        guard let label = titleLabelsByTab[.menu] else { return }
        let target = highlighted ? UIColor.systemOrange : UIColor(white: 0.55, alpha: 1.0)
        if !animated {
            label.textColor = target
            return
        }
        UIView.transition(with: label, duration: 0.12, options: [.transitionCrossDissolve, .allowUserInteraction]) {
            label.textColor = target
        }
    }

    private func indicatorAngle(forCenterX x: CGFloat) -> CGFloat {
        
        guard notchSamples.count >= 2 else { return 0 }
        if x <= notchSamples[0].x || x >= notchSamples[notchSamples.count - 1].x { return 0 }
        
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
        
        return atan2(dy, dx)
    }

    private func indicatorYOffset(forCenterX x: CGFloat) -> CGFloat {
        
        
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
        
        indicatorSegmentsContainer.removeAllAnimations()

        
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.duration = 0.28
        pulse.fromValue = 0.75
        pulse.toValue = 1.0
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        indicatorSegmentsContainer.add(pulse, forKey: "shimmerPulse")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let outerInsetX: CGFloat = 0
        let outerInsetTop: CGFloat = 8
        let outerInsetBottom: CGFloat = -35

        let contentLift: CGFloat = max(0, (-outerInsetBottom) - 20)

        backgroundView.frame = CGRect(
            x: outerInsetX,
            y: outerInsetTop,
            width: bounds.width - outerInsetX * 2,
            height: bounds.height - outerInsetTop - outerInsetBottom
        )

        let contentWidth = backgroundView.frame.width
        let slotCount = items.count 
        let slotWidth = contentWidth / CGFloat(slotCount)

        let barTopY = backgroundView.frame.minY
        let barBottomY = backgroundView.frame.maxY

        indicatorSegmentsContainer.frame = bounds

        
        let centerIndex = items.firstIndex(where: { $0.isCenter }) ?? 0
        let centerX = backgroundView.frame.minX + slotWidth * (CGFloat(centerIndex) + 0.5)
        let localCenterX = centerX - backgroundView.frame.minX

        let notchWidth = min(backgroundView.bounds.width, slotWidth * 1.65)
        let notchDepth = min(34, max(20, 42 - contentLift))
        let xLeft = max(0, localCenterX - notchWidth / 2)
        let xRight = min(backgroundView.bounds.width, localCenterX + notchWidth / 2)
        let yTop: CGFloat = 12 
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

        
        self.notchXLeft = backgroundView.frame.minX + xLeft
        self.notchXRight = backgroundView.frame.minX + xRight
        self.notchDepth = notchDepth

        
        self.notchSamples = makeNotchSamples(
            bgMinX: backgroundView.frame.minX,
            xLeft: xLeft,
            xRight: xRight,
            xMid: localCenterX,
            yTop: 0,
            yBottom: yBottom,
            notchWidth: notchWidth
        )

        
        let indicatorY = barTopY + 14 - contentLift
        let indicatorHeight: CGFloat = 3.5

        
        let iconsDrop: CGFloat = 8
        let labelsLift: CGFloat = 8
        for (index, item) in items.enumerated() {
            let tab = item.tab
            let centerX = backgroundView.frame.minX + slotWidth * (CGFloat(index) + 0.5)

            if item.isCenter {
                let circleSize: CGFloat = 63
                
                let circleY = barTopY - 18 - contentLift + centerCircleExtraDown
                if let circle = centerCircleByTab[tab] {
                    circle.frame = CGRect(x: centerX - circleSize / 2, y: circleY, width: circleSize, height: circleSize)
                    circle.layer.cornerRadius = circleSize / 2
                }

                
                let iconSize: CGFloat = 22
                iconViewsByTab[tab]?.frame = CGRect(
                    x: centerX - iconSize / 2,
                    y: circleY + circleSize / 2 - iconSize / 2,
                    width: iconSize,
                    height: iconSize
                )

                
                let tapH: CGFloat = (barBottomY - barTopY) + 10
                let tapY = barTopY - 22 + centerCircleExtraDown
                tapButtonsByTab[tab]?.frame = CGRect(x: centerX - slotWidth / 2, y: tapY, width: slotWidth, height: tapH)

                
                let labelH: CGFloat = 22
                titleLabelsByTab[tab]?.frame = CGRect(
                    x: centerX - slotWidth / 2,
                    y: barBottomY - labelH - 2 - contentLift - 20 - labelsLift,
                    width: slotWidth,
                    height: labelH
                )

                
                let indicatorWidth: CGFloat = 38
                slotRects[tab] = CGRect(x: centerX - indicatorWidth / 2, y: indicatorY, width: indicatorWidth, height: indicatorHeight)
            } else {
                let iconSize: CGFloat = tab == .main ? 31 : 26
                let iconBaseY = barTopY + 22 - contentLift + iconsDrop
                
                let iconY = iconBaseY - (iconSize - 26) / 2
                iconViewsByTab[tab]?.frame = CGRect(x: centerX - iconSize / 2, y: iconY, width: iconSize, height: iconSize)

                
                let tapY = barTopY
                let tapH = barBottomY - barTopY
                tapButtonsByTab[tab]?.frame = CGRect(x: centerX - slotWidth / 2, y: tapY, width: slotWidth, height: tapH)

                
                let labelH: CGFloat = 22
                titleLabelsByTab[tab]?.frame = CGRect(
                    x: centerX - slotWidth / 2,
                    y: barBottomY - labelH - 2 - contentLift - 20 - labelsLift,
                    width: slotWidth,
                    height: labelH
                )

                let indicatorWidth: CGFloat = 42
                slotRects[tab] = CGRect(x: centerX - indicatorWidth / 2, y: indicatorY, width: indicatorWidth, height: indicatorHeight)
            }
        }

        
        if let tab = selectedTab {
            setSelectedTab(tab, animated: false)
        }
    }

    private func ensureIndicatorSegments() {
        if !indicatorSegments.isEmpty { return }
        for _ in 0..<indicatorSegmentsCount {
            let seg = CALayer()
            seg.backgroundColor = UIColor.systemOrange.cgColor
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

        let n = 82
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

