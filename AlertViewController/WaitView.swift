//  WaitView.swift
//
//  Created by Arpit Soni on 8/20/17.
//  Copyright © 2017 Arpit Soni. All rights reserved.

import UIKit

open class ProgressView: UIView {
    
    private var _progress: CGFloat {
        return progress * (bounds.size.width - sizeOffset)
    }
    
    private let progressLayer = CALayer()
    
    private var timer = Timer()
    
    private var stopwatch: TimeInterval = 0.0
    
    private var timeoutInterval: TimeInterval = 0.0
    
    private let pointOffset: CGFloat = 1.0
    
    private let sizeOffset: CGFloat = 2.0
    
    private let intrinsicHeight: CGFloat = 8.0
    
    private let intrinsicWidth: CGFloat = 100.0
    
    open private(set) var progress : CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var trackColor: UIColor = #colorLiteral(red: 0.1137254902, green: 0.1176470588, blue: 0.1294117647, alpha: 1)
    
    open var progressColor: UIColor = #colorLiteral(red: 0, green: 0.5843137255, blue: 0.7921568627, alpha: 1)
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: intrinsicWidth, height: intrinsicHeight)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // We have corrent bounds here
        layer.cornerRadius = bounds.height / 2.0
        progressLayer.frame = CGRect(x: pointOffset, y: pointOffset, width: _progress, height: bounds.size.height - sizeOffset)
        progressLayer.cornerRadius = (bounds.size.height - sizeOffset) / 2.0
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
    }
    
    /**
     updateConstraints method only gets called when someone sets constraints on this view. If you want to call updateConstraints on start then uncomment this part.
     */
    //    open override class var requiresConstraintBasedLayout: Bool {
    //        return true
    //    }
    
    private func setup() {
        backgroundColor = trackColor
        progressLayer.backgroundColor = progressColor.cgColor
        layer.addSublayer(progressLayer)
    }
    
    @objc private func updateProgress() {
        stopwatch += 0.1
        setProgress(CGFloat(stopwatch/timeoutInterval))
        
        if stopwatch >= timeoutInterval {
            timer.invalidate()
        }
    }
    
    private func setProgress(_ progress: CGFloat) {
        if progress > 1.0 {
            self.progress = 1.0
        } else if progress < 0.0 {
            self.progress = 0.0
        } else {
            self.progress = progress
        }
    }
    
    open func start(with timeoutInterval: TimeInterval = 10) {
        self.timeoutInterval = timeoutInterval
        
        if timer.isValid {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    open func stop() {
        timer.invalidate()
        setProgress(1.0)
    }
    
}

public enum WaitIndicatorType {
    case progress
    case intermediate
}

open class WaitView: UIView {
    
    open var indicatorType: WaitIndicatorType
    
    open var activityIndicatorView: UIActivityIndicatorView?
    
    open var progressView: ProgressView?
    
    public init(with indicatorType : WaitIndicatorType) {
        
        self.indicatorType = indicatorType
        
        super.init(frame: .zero)
        
        switch indicatorType {
        case .intermediate:
            activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        case .progress:
            progressView = ProgressView()
        }
        
        setup()
    }
    
    open override var intrinsicContentSize: CGSize {
        
        if indicatorType == .intermediate {
            return activityIndicatorView?.intrinsicContentSize ?? .zero
        } else {
            return progressView?.intrinsicContentSize ?? .zero
        }
    }
    
    private func setup() {
        //        backgroundColor = UIColor.green
        
        if let activityIndicatorView = activityIndicatorView {
            addSubview(activityIndicatorView)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            let activityIndicatoCenterX = activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
            let activityIndicatoCenterY = activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
            NSLayoutConstraint.activate([activityIndicatoCenterX, activityIndicatoCenterY])
        }
        
        if let progressView = progressView {
            addSubview(progressView)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            let progressWidth = progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9)
            let progressHeight = progressView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0)
            let progressCenterX = progressView.centerXAnchor.constraint(equalTo: centerXAnchor)
            let progressCenterY = progressView.centerYAnchor.constraint(equalTo: centerYAnchor)
            NSLayoutConstraint.activate([progressCenterX, progressCenterY, progressWidth, progressHeight])
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func start(with timeoutInterval: TimeInterval = 10) {
        switch indicatorType {
        case .intermediate:
            activityIndicatorView?.startAnimating()
        case .progress:
            progressView?.start(with: timeoutInterval)
        }
    }
    
    open func stop() {
        switch indicatorType {
        case .intermediate:
            activityIndicatorView?.stopAnimating()
        case .progress:
            progressView?.stop()
        }
    }
}

//let waitView = WaitView(with: .progress)
//waitView.start()
//view.addSubview(waitView)
//waitView.translatesAutoresizingMaskIntoConstraints = false
//waitView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
////waitView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true
//waitView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//waitView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//
//DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//    waitView.stop()
//}

