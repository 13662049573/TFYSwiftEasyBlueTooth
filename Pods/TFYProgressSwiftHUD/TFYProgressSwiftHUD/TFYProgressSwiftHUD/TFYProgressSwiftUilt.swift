//
//  TFYProgressSwiftUilt.swift
//  TFYProgressSwiftHUD
//
//  Created by 田风有 on 2021/4/11.
//

import Foundation
import UIKit

///动画1 设置
func animationSystemActivityIndicator(_ view:UIView,color:UIColor) {
    let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    spinner.frame = view.bounds
    spinner.color = color
    spinner.hidesWhenStopped = true
    spinner.startAnimating()
    spinner.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
    view.addSubview(spinner)
}

///动画2 设置
func animationHorizontalCirclesPulsc(_ view:UIView,color:UIColor) {
    let width = view.frame.size.width
    let height = view.frame.size.height
    let spacing:CGFloat = 3
    let radius:CGFloat = (width - spacing * 2)/3
    let ypos:CGFloat = (height - radius)/2
    
    let beginTime = CACurrentMediaTime()
    let beginTimes = [0.36,0.24,0.12]
    let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)
    
    let animation = CAKeyframeAnimation(keyPath: "transform.scale")
    animation.keyTimes = [0,0.5,1]
    animation.timingFunctions = [timingFunction,timingFunction]
    animation.values = [1,0.3,1]
    animation.duration = 1
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false
    
    let path = UIBezierPath(arcCenter: CGPoint(x: radius/2, y: radius/2), radius: radius/2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
    
    for i in 0..<3 {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: (radius + spacing) * CGFloat(i), y: ypos, width: radius, height: radius)
        layer.path = path.cgPath
        layer.fillColor = color.cgColor
        animation.beginTime = beginTime - beginTimes[i]
        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
}
///动画3 设置
func animationLineScaling(_ view:UIView,color:UIColor) {
    let width = view.frame.size.width
    let height = view.frame.size.height
    let lineWidth = width/9
    
    let beginTime = CACurrentMediaTime()
    let beginTimes = [0.5,0.4,0.3,0.2,0.1]
    let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)
    
    let animation = CAKeyframeAnimation(keyPath: "transform.scale.y")
    animation.keyTimes = [0,0.5,1]
    animation.timingFunctions = [timingFunction,timingFunction]
    animation.values = [1,0.4,1]
    animation.duration = 1
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false
    
    let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: lineWidth, height: height), cornerRadius: width/2)
    
    for i in 0..<5 {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: lineWidth * 2 * CGFloat(i), y: 0, width: lineWidth, height: height)
        layer.path = path.cgPath
        layer.backgroundColor = nil
        layer.fillColor = color.cgColor
        
        animation.beginTime = beginTime - beginTimes[i]
        
        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
}
///动画4 设置
func animationSingleCirclePulse(_ view: UIView,color:UIColor) {

    let width = view.frame.size.width
    let height = view.frame.size.height

    let duration: CFTimeInterval = 1.0

    let animationScale = CABasicAnimation(keyPath: "transform.scale")
    animationScale.duration = duration
    animationScale.fromValue = 0
    animationScale.toValue = 1

    let animationOpacity = CABasicAnimation(keyPath: "opacity")
    animationOpacity.duration = duration
    animationOpacity.fromValue = 1
    animationOpacity.toValue = 0

    let animation = CAAnimationGroup()
    animation.animations = [animationScale, animationOpacity]
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.duration = duration
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false

    let path = UIBezierPath(arcCenter: CGPoint(x: width/2, y: height/2), radius: width/2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)

    let layer = CAShapeLayer()
    layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    layer.path = path.cgPath
    layer.fillColor = color.cgColor

    layer.add(animation, forKey: "animation")
    view.layer.addSublayer(layer)
}
///动画5 设置
func animationMultipleCirclePulse(_ view: UIView,color:UIColor) {

    let width = view.frame.size.width
    let height = view.frame.size.height

    let duration = 1.0
    let beginTime = CACurrentMediaTime()
    let beginTimes = [0, 0.3, 0.6]

    let animationScale = CABasicAnimation(keyPath: "transform.scale")
    animationScale.duration = duration
    animationScale.fromValue = 0
    animationScale.toValue = 1

    let animationOpacity = CAKeyframeAnimation(keyPath: "opacity")
    animationOpacity.duration = duration
    animationOpacity.keyTimes = [0, 0.05, 1]
    animationOpacity.values = [0, 1, 0]

    let animation = CAAnimationGroup()
    animation.animations = [animationScale, animationOpacity]
    animation.timingFunction = CAMediaTimingFunction(name: .linear)
    animation.duration = duration
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false

    let path = UIBezierPath(arcCenter: CGPoint(x: width/2, y: height/2), radius: width/2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)

    for i in 0..<3 {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        layer.path = path.cgPath
        layer.fillColor = color.cgColor
        layer.opacity = 0

        animation.beginTime = beginTime + beginTimes[i]

        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
}
///动画6 设置
func animationSingleCircleScaleRipple(_ view: UIView,color:UIColor) {

    let width = view.frame.size.width
    let height = view.frame.size.height

    let duration: CFTimeInterval = 1.0
    let timingFunction = CAMediaTimingFunction(controlPoints: 0.21, 0.53, 0.56, 0.8)

    let animationScale = CAKeyframeAnimation(keyPath: "transform.scale")
    animationScale.keyTimes = [0, 0.7]
    animationScale.timingFunction = timingFunction
    animationScale.values = [0.1, 1]
    animationScale.duration = duration

    let animationOpacity = CAKeyframeAnimation(keyPath: "opacity")
    animationOpacity.keyTimes = [0, 0.7, 1]
    animationOpacity.timingFunctions = [timingFunction, timingFunction]
    animationOpacity.values = [1, 0.7, 0]
    animationOpacity.duration = duration

    let animation = CAAnimationGroup()
    animation.animations = [animationScale, animationOpacity]
    animation.duration = duration
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false

    let path = UIBezierPath(arcCenter: CGPoint(x: width/2, y: height/2), radius: width/2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)

    let layer = CAShapeLayer()
    layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    layer.path = path.cgPath
    layer.backgroundColor = nil
    layer.fillColor = nil
    layer.strokeColor = color.cgColor
    layer.lineWidth = 3

    layer.add(animation, forKey: "animation")
    view.layer.addSublayer(layer)
}
///动画7 设置
func animationMultipleCircleScaleRipple(_ view: UIView,color:UIColor) {

    let width = view.frame.size.width
    let height = view.frame.size.height

    let duration = 1.25
    let beginTime = CACurrentMediaTime()
    let beginTimes = [0, 0.2, 0.4]
    let timingFunction = CAMediaTimingFunction(controlPoints: 0.21, 0.53, 0.56, 0.8)

    let animationScale = CAKeyframeAnimation(keyPath: "transform.scale")
    animationScale.keyTimes = [0, 0.7]
    animationScale.timingFunction = timingFunction
    animationScale.values = [0, 1]
    animationScale.duration = duration

    let animationOpacity = CAKeyframeAnimation(keyPath: "opacity")
    animationOpacity.keyTimes = [0, 0.7, 1]
    animationOpacity.timingFunctions = [timingFunction, timingFunction]
    animationOpacity.values = [1, 0.7, 0]
    animationOpacity.duration = duration

    let animation = CAAnimationGroup()
    animation.animations = [animationScale, animationOpacity]
    animation.duration = duration
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false

    let path = UIBezierPath(arcCenter: CGPoint(x: width/2, y: height/2), radius: width/2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)

    for i in 0..<3 {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        layer.path = path.cgPath
        layer.backgroundColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = 3
        layer.fillColor = nil

        animation.beginTime = beginTime + beginTimes[i]

        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
}
///动画8 设置
func animationCircleSpinFade(_ view: UIView,color:UIColor) {

    let width = view.frame.size.width

    let spacing: CGFloat = 3
    let radius = (width - 4 * spacing) / 3.5
    let radiusX = (width - radius) / 2

    let duration = 1.0
    let beginTime = CACurrentMediaTime()
    let beginTimes: [CFTimeInterval] = [0.84, 0.72, 0.6, 0.48, 0.36, 0.24, 0.12, 0]

    let animationScale = CAKeyframeAnimation(keyPath: "transform.scale")
    animationScale.keyTimes = [0, 0.5, 1]
    animationScale.values = [1, 0.4, 1]
    animationScale.duration = duration

    let animationOpacity = CAKeyframeAnimation(keyPath: "opacity")
    animationOpacity.keyTimes = [0, 0.5, 1]
    animationOpacity.values = [1, 0.3, 1]
    animationOpacity.duration = duration

    let animation = CAAnimationGroup()
    animation.animations = [animationScale, animationOpacity]
    animation.timingFunction = CAMediaTimingFunction(name: .linear)
    animation.duration = duration
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false

    let path = UIBezierPath(arcCenter: CGPoint(x: radius/2, y: radius/2), radius: radius/2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)

    for i in 0..<8 {
        let angle = .pi / 4 * CGFloat(i)

        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = color.cgColor
        layer.backgroundColor = nil
        layer.frame = CGRect(x: radiusX * (cos(angle) + 1), y: radiusX * (sin(angle) + 1), width: radius, height: radius)

        animation.beginTime = beginTime - beginTimes[i]

        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
}
///动画9 设置
func animationLineSpinFade(_ view: UIView,color:UIColor) {

    let width = view.frame.size.width
    let height = view.frame.size.height

    let spacing: CGFloat = 3
    let lineWidth = (width - 4 * spacing) / 5
    let lineHeight = (height - 2 * spacing) / 3
    let containerSize = max(lineWidth, lineHeight)
    let radius = width / 2 - containerSize / 2

    let duration = 1.2
    let beginTime = CACurrentMediaTime()
    let beginTimes: [CFTimeInterval] = [0.96, 0.84, 0.72, 0.6, 0.48, 0.36, 0.24, 0.12]
    let timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    let animation = CAKeyframeAnimation(keyPath: "opacity")
    animation.keyTimes = [0, 0.5, 1]
    animation.timingFunctions = [timingFunction, timingFunction]
    animation.values = [1, 0.3, 1]
    animation.duration = duration
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false

    let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: lineWidth, height: lineHeight), cornerRadius: lineWidth/2)

    for i in 0..<8 {
        let angle = .pi / 4 * CGFloat(i)

        let line = CAShapeLayer()
        line.frame = CGRect(x: (containerSize-lineWidth)/2, y: (containerSize-lineHeight)/2, width: lineWidth, height: lineHeight)
        line.path = path.cgPath
        line.backgroundColor = nil
        line.fillColor = color.cgColor

        let container = CALayer()
        container.frame = CGRect(x: radius * (cos(angle) + 1), y: radius * (sin(angle) + 1), width: containerSize, height: containerSize)
        container.addSublayer(line)
        container.sublayerTransform = CATransform3DMakeRotation(.pi / 2 + angle, 0, 0, 1)

        animation.beginTime = beginTime - beginTimes[i]

        container.add(animation, forKey: "animation")
        view.layer.addSublayer(container)
    }
}
///动画10 设置
func animationCircleRotateChase(_ view: UIView,color:UIColor) {

    let width = view.frame.size.width
    let height = view.frame.size.height

    let spacing: CGFloat = 3
    let radius = (width - 4 * spacing) / 3.5
    let radiusX = (width - radius) / 2

    let duration: CFTimeInterval = 1.5

    let path = UIBezierPath(arcCenter: CGPoint(x: radius/2, y: radius/2), radius: radius/2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)

    let pathPosition = UIBezierPath(arcCenter: CGPoint(x: width/2, y: height/2), radius: radiusX, startAngle: 1.5 * .pi, endAngle: 3.5 * .pi, clockwise: true)

    for i in 0..<5 {
        let rate = Float(i) * 1 / 5
        let fromScale = 1 - rate
        let toScale = 0.2 + rate
        let timeFunc = CAMediaTimingFunction(controlPoints: 0.5, 0.15 + rate, 0.25, 1)

        let animationScale = CABasicAnimation(keyPath: "transform.scale")
        animationScale.duration = duration
        animationScale.repeatCount = HUGE
        animationScale.fromValue = fromScale
        animationScale.toValue = toScale

        let animationPosition = CAKeyframeAnimation(keyPath: "position")
        animationPosition.duration = duration
        animationPosition.repeatCount = HUGE
        animationPosition.path = pathPosition.cgPath

        let animation = CAAnimationGroup()
        animation.animations = [animationScale, animationPosition]
        animation.timingFunction = timeFunc
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        layer.path = path.cgPath
        layer.fillColor = color.cgColor

        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
}
///动画11 设置
func animationCircleStrokeSpin(_ view: UIView,color:UIColor) {

    let width = view.frame.size.width
    let height = view.frame.size.height

    let beginTime: Double = 0.5
    let durationStart: Double = 1.2
    let durationStop: Double = 0.7

    let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
    animationRotation.byValue = 2 * Float.pi
    animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)

    let animationStart = CABasicAnimation(keyPath: "strokeStart")
    animationStart.duration = durationStart
    animationStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
    animationStart.fromValue = 0
    animationStart.toValue = 1
    animationStart.beginTime = beginTime

    let animationStop = CABasicAnimation(keyPath: "strokeEnd")
    animationStop.duration = durationStop
    animationStop.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
    animationStop.fromValue = 0
    animationStop.toValue = 1

    let animation = CAAnimationGroup()
    animation.animations = [animationRotation, animationStop, animationStart]
    animation.duration = durationStart + beginTime
    animation.repeatCount = .infinity
    animation.isRemovedOnCompletion = false
    animation.fillMode = .forwards

    let path = UIBezierPath(arcCenter: CGPoint(x: width/2, y: height/2), radius: width/2, startAngle: -0.5 * .pi, endAngle: 1.5 * .pi, clockwise: true)

    let layer = CAShapeLayer()
    layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    layer.path = path.cgPath
    layer.fillColor = nil
    layer.strokeColor = color.cgColor
    layer.lineWidth = 3

    layer.add(animation, forKey: "animation")
    view.layer.addSublayer(layer)
}

///图片动画 1
func animatedIconSucceed(_ view: UIView,color:UIColor,alpha:CGFloat) {

    let length = view.frame.width
    let delay = (alpha == 0) ? 0.25 : 0.0

    let path = UIBezierPath()
    path.move(to: CGPoint(x: length * 0.15, y: length * 0.50))
    path.addLine(to: CGPoint(x: length * 0.5, y: length * 0.80))
    path.addLine(to: CGPoint(x: length * 1.0, y: length * 0.25))

    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = 0.25
    animation.fromValue = 0
    animation.toValue = 1
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    animation.beginTime = CACurrentMediaTime() + delay

    let layer = CAShapeLayer()
    layer.path = path.cgPath
    layer.fillColor = UIColor.clear.cgColor
    layer.strokeColor = color.cgColor
    layer.lineWidth = 9
    layer.lineCap = .round
    layer.lineJoin = .round
    layer.strokeEnd = 0

    layer.add(animation, forKey: "animation")
    view.layer.addSublayer(layer)
}
///图片动画 2
func animatedIconFailed(_ view: UIView,color:UIColor,alpha:CGFloat) {

    let length = view.frame.width
    let delay = (alpha == 0) ? 0.25 : 0.0

    let path1 = UIBezierPath()
    let path2 = UIBezierPath()

    path1.move(to: CGPoint(x: length * 0.15, y: length * 0.15))
    path2.move(to: CGPoint(x: length * 0.15, y: length * 0.85))

    path1.addLine(to: CGPoint(x: length * 0.85, y: length * 0.85))
    path2.addLine(to: CGPoint(x: length * 0.85, y: length * 0.15))

    let paths = [path1, path2]

    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = 0.15
    animation.fromValue = 0
    animation.toValue = 1
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false

    for i in 0..<2 {
        let layer = CAShapeLayer()
        layer.path = paths[i].cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = 9
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeEnd = 0

        animation.beginTime = CACurrentMediaTime() + 0.25 * Double(i) + delay

        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
}
///图片动画 3
func animatedIconAdded(_ view: UIView,color:UIColor,alpha:CGFloat) {

    let length = view.frame.width
    let delay = (alpha == 0) ? 0.25 : 0.0

    let path1 = UIBezierPath()
    let path2 = UIBezierPath()

    path1.move(to: CGPoint(x: length * 0.1, y: length * 0.5))
    path2.move(to: CGPoint(x: length * 0.5, y: length * 0.1))

    path1.addLine(to: CGPoint(x: length * 0.9, y: length * 0.5))
    path2.addLine(to: CGPoint(x: length * 0.5, y: length * 0.9))

    let paths = [path1, path2]

    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.duration = 0.15
    animation.fromValue = 0
    animation.toValue = 1
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false

    for i in 0..<2 {
        let layer = CAShapeLayer()
        layer.path = paths[i].cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = 9
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeEnd = 0

        animation.beginTime = CACurrentMediaTime() + 0.25 * Double(i) + delay

        layer.add(animation, forKey: "animation")
        view.layer.addSublayer(layer)
    }
}
