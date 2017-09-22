//
//  AlertViewController.swift
//  AlertViewController
//
//  Created by Arpit Soni on 7/28/17.
//  Copyright © 2017 Arpit Soni. All rights reserved.
//

import UIKit

open class AlertViewController: UIViewController {
    
    //MARK: Private properties
    
    fileprivate var titleLabel: UILabel!
    
    fileprivate var msgLabel: UILabel!
    
    fileprivate var cancelButton: UIButton!
    
    fileprivate var buttonsStackView: UIStackView!
    
    fileprivate var mainStackView: UIStackView!
    
    fileprivate var waitView: WaitView!
    
    fileprivate var actions: [AlertAction]!
    
    fileprivate var mainView: MainView!
    
    fileprivate var didInitAnimation = false
    
    fileprivate var mainStackViewTopConstraint: NSLayoutConstraint!
    
    fileprivate var cancelButtonHeightConstraint: NSLayoutConstraint! {
        willSet {
            if cancelButtonHeightConstraint != nil {
                cancelButtonHeightConstraint.isActive = false
            }
        } didSet {
            cancelButtonHeightConstraint.isActive = true
        }
    }
    
    fileprivate var customViewHeightAnchor: NSLayoutConstraint!{
        willSet{
            if customViewHeightAnchor != nil {
                customViewHeightAnchor.isActive = false
            }
        }didSet{
            customViewHeightAnchor.isActive = true
        }
    }
    
    fileprivate var mainViewCenterYConstraint: NSLayoutConstraint! {
        willSet {
            if mainViewCenterYConstraint != nil {
                mainViewCenterYConstraint.isActive = false
            }
        } didSet {
            mainViewCenterYConstraint.isActive = true
        }
    }
    
    fileprivate var _title: String? {
        didSet {
            if titleLabel != nil, mainStackView != nil {
                titleLabel.text = _title
                if _title == nil || _title?.characters.count == 0 {
                    titleLabel.isHidden = true
                } else {
                    titleLabel.isHidden = false
                }
                animateStackView()
            }
        }
    }
    
    fileprivate var _msg: String? {
        didSet {
            if msgLabel != nil, mainStackView != nil {
                msgLabel.text = _msg
                if _msg == nil || _msg?.characters.count == 0 {
                    msgLabel.isHidden = true
                } else {
                    msgLabel.isHidden = false
                }
                animateStackView()
            }
        }
    }
    
    fileprivate var deviceWidth: CGFloat {
        return view.bounds.width < view.bounds.height ? view.bounds.width : view.bounds.height
    }
    
    fileprivate var deviceHeight: CGFloat {
        return view.bounds.width < view.bounds.height ? view.bounds.height : view.bounds.width
    }
    
    //MARK: Getters
    
    open fileprivate(set) var spacing: CGFloat = -1.0
    
    open fileprivate(set) var stackSpacing: CGFloat = 0.0
    
    open fileprivate(set) var sideSpacing: CGFloat = 20.0
    
    open fileprivate(set) var buttonHeight: CGFloat = 0.0
    
    open fileprivate(set) var cancelButtonHeight:CGFloat = 0.0
    
    open fileprivate(set) var titleFontSize: CGFloat = 0.0
    
    open fileprivate(set) var msgFontSize: CGFloat = 0.0
    
    open fileprivate(set) var fontName: String = "AvenirNext-Medium"
    
    open fileprivate(set) var fontNameBold: String = "AvenirNext-DemiBold"
    
    open fileprivate(set) lazy var container: UIView = UIView()
    
    //MARK: Public Porperties
    
    open var buttonStyle: ((UIButton,_ height: CGFloat,_ position: Int) -> Void)?
    
    open var cancelButtonStyle: ((UIButton,CGFloat) -> Void)?
    
    open var dismissDirection: AlertDismissDirection = .both
    
    open var backgroundAlpha: Float = 0.2
    
    open var animationDuration: TimeInterval = 0.2
    
    open var contentOffset: CGFloat = 0.0 {
        didSet {
            if let mainView = self.mainView {
                mainViewCenterYConstraint = mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: contentOffset)
                let center = self.view.center
                let offset = contentOffset
                UIView.animate(withDuration: animationDuration) {
                    mainView.center = CGPoint(x: center.x, y: center.y + offset)
                }
            }
        }
    }
    
    open override var title: String? {
        get {
            return _title
        } set {
            _title = newValue
        }
    }
    
    open var msg: String? {
        get {
            return _msg
        } set {
            _msg = newValue
        }
    }
    
    open var customViewSizeRatio: CGFloat = 0.0 {
        didSet{
            customViewHeightAnchor =
                container.heightAnchor
                    .constraint(equalTo: container.widthAnchor, multiplier: customViewSizeRatio)
            
            let alpha: CGFloat = customViewSizeRatio > 0.0 ? 1.0 : 0.0
            animateStackView { [weak self] in
                self?.container.alpha = alpha
            }
        }
    }
    
    open var cancelButtonTitle: String = "Cancel" {
        didSet {
            cancelButton.setTitle(cancelButtonTitle, for: [])
        }
    }
    
    open var isLoadingEnabled: Bool = false {
        willSet {
            if newValue, waitView != nil {
                waitView.isHidden = false
                waitView.start(with: 10)
            } else if waitView != nil {
                waitView.stop()
            }
        } didSet {
            if waitView != nil {
                //constraints
                
                let newValue = isLoadingEnabled
                let alpha: CGFloat = newValue ? 1.0 : 0.0
                
                if newValue {
                    waitView.isHidden = false
                }
                
                animateStackView(withOptionalAnimations: { [weak self] in
                    if let sself = self, !newValue {
                        sself.waitView?.alpha = alpha
                    }
                }) {[weak self] in
                    if let sself = self, !newValue {
                        sself.waitView.isHidden = true
                    }
                }
            }
        }
    }
    
    open var isCancelButtonEnabled : Bool = false {
        willSet {
            if newValue, cancelButton != nil, cancelButtonHeight != 0 {
                _ = cancelButtonStyle?(cancelButton, cancelButtonHeight)
            }
        } didSet {
            if cancelButton != nil {
                cancelButtonHeightConstraint = cancelButton.heightAnchor.constraint(equalToConstant: cancelButtonHeight * (isCancelButtonEnabled ? 1.0 : 0.0))
                
                let alpha: CGFloat = isCancelButtonEnabled ? 1.0 : 0.0
                
                let newValue = isCancelButtonEnabled
                
                if newValue {
                    cancelButton.isHidden = false
                }
                
                animateStackView(withOptionalAnimations: { [weak self] in
                    if let sself = self, !newValue {
                        sself.cancelButton?.alpha = alpha
                    }
                }) {[weak self] in
                    if let sself = self, !newValue {
                        sself.cancelButton.isHidden = true
                    }
                }
            }
        }
    }
    
    //MARK: Open Methods
    
    open func addAction(_ action: AlertAction) {
        actions.append(action)
        
        if buttonsStackView != nil {
            let button = setupButton(at: actions.count - 1)
            self.buttonsStackView.addArrangedSubview(button)
            button.center = CGPoint(x: buttonsStackView.bounds.midX, y: buttonsStackView.bounds.midY)
            animateStackView()
        }
    }
    
    open func removeAction(at index: Int) {
        if actions.count <= index {
            return
        }
        
        actions.remove(at: index)
        
        guard buttonsStackView != nil else {
            return
        }
        
        buttonsStackView.arrangedSubviews.forEach { subview in
            if subview.tag == index {
                subview.removeFromSuperview()
            }
        }
        
        var newIndex = 0
        buttonsStackView.arrangedSubviews.forEach { subview in
            subview.tag = newIndex
            newIndex += 1
        }
        animateStackView()
    }
    
    open func removeAllActions() {
        actions.removeAll()
        
        buttonsStackView.arrangedSubviews.forEach { subview in
            subview.removeFromSuperview()
        }
        animateStackView()
    }
    
    open func show(in vc: UIViewController, withLoading loading: Bool = false) {
        vc.present(self, animated: false, completion: nil)
        isLoadingEnabled = loading
    }
    
    //MARK: Selector Methods
    
    @objc internal func cancelAction(_ sender: UIButton){
        dismiss(animated: true)
    }
    
    @objc internal func handleAction(_ sender: UIButton) {
        actions[sender.tag].handler?(self)
    }
    
    //MARK: Override Methods
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if flag {
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                if let sself = self, let mainView = sself.mainView, let view = sself.view {
                    mainView.center.y = view.bounds.maxY + mainView.bounds.midY
                    view.backgroundColor = .clear
                }
                }, completion: { (complete) in
                    super.dismiss(animated: false, completion: completion)
            })
        } else {
            super.dismiss(animated: false, completion: completion)
        }
    }
    
    open override func loadView() {
        super.loadView()
        
        mainView = MainView()
        mainStackView = UIStackView()
        buttonsStackView = UIStackView()
        titleLabel = UILabel()
        msgLabel = UILabel()
        cancelButton = UIButton(type: .system)
        waitView = WaitView(with: .progress)
        
        if spacing == -1 {
            spacing = deviceHeight * 0.012
        }
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        waitView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainView)
        mainView.addSubview(mainStackView)
        mainView.addSubview(cancelButton)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(msgLabel)
        mainStackView.addArrangedSubview(waitView)
        mainStackView.addArrangedSubview(container)
        mainStackView.addArrangedSubview(buttonsStackView)
        
        setupMainStackView()
        setupTitleLabel()
        setupMsgLabel()
        setupContainer()
        setupButtonsStack()
        setupCancelButton()
        setupMainView()
        setupWaitView()
    }
    
    
    //MARK: Setup Factory Methods
    
    fileprivate func setupButton(at index: Int) -> UIButton {
        
        if buttonHeight == 0 {
            buttonHeight = deviceHeight * 0.07
        }
        
        let action = actions[index]
        let button = UIButton(type: .custom)
        button.isExclusiveTouch = true
        button.setTitle(action.title, for: [])
        button.setTitleColor(button.tintColor, for: [])
        button.layer.borderColor = button.tintColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = buttonHeight/2
        button.titleLabel?.font = UIFont(name: fontName, size: buttonHeight * 0.35)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        self.buttonStyle?(button, buttonHeight, index)
        button.tag = index
        button.addTarget(self, action: #selector(AlertViewController.handleAction(_:)), for: .touchUpInside)
        return button
    }
    
    fileprivate func setupMainStackView() {
        mainStackView.distribution = .fill
        mainStackView.alignment = .center
        mainStackView.axis = .vertical
        mainStackView.spacing = stackSpacing
        
        mainStackView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        mainStackView.leftAnchor.constraint(equalTo: mainView.leftAnchor,constant: sideSpacing/2).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: mainView.rightAnchor,constant: -sideSpacing/2).isActive = true
        
        mainStackViewTopConstraint =
            mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: spacing/2)
        mainStackViewTopConstraint.isActive = true
    }
    
    fileprivate func setupTitleLabel() {
        
        if titleFontSize == 0 {
            titleFontSize = deviceHeight * 0.0269
        }
        
        let titleFont = UIFont(name: fontNameBold, size: titleFontSize)
        //let titleHeight:CGFloat = mTitle == nil ? 0 : heightForView(mTitle!, font: titleFont!, width: deviceWidth * 0.6)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.text = _title
        titleLabel.font = titleFont
        titleLabel.textAlignment = .center
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: msgLabel.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    fileprivate func setupMsgLabel() {
        if msgFontSize == 0 {
            msgFontSize = deviceHeight * 0.0239
        }
        let labelFont = UIFont(name: fontName, size: msgFontSize)!
        msgLabel.numberOfLines = 0
        msgLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        msgLabel.font = labelFont
        msgLabel.text = _msg
        msgLabel.textAlignment = .center
    }
    
    fileprivate func setupContainer() {
        container.alpha = customViewSizeRatio > 0 ? 1.0 : 0.0
        container.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 1.0).isActive = true
        customViewHeightAnchor = container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: customViewSizeRatio)
    }
    
    fileprivate func setupButtonsStack() {
        
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.alignment = .fill
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = stackSpacing
        
        buttonsStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.8).isActive = true
        
        for i in 0 ..< actions.count {
            let button = setupButton(at: i)
            buttonsStackView.addArrangedSubview(button)
        }
    }
    
    fileprivate func setupCancelButton() {
        if cancelButtonHeight == 0 {
            cancelButtonHeight = deviceHeight * 0.0449
        }
        cancelButton.setTitle(cancelButtonTitle, for: [])
        cancelButton.titleLabel?.font = UIFont(name: fontName, size: cancelButtonHeight * 0.433)
        //        let showCancelButton = (isCancelButtonEnabled || (cancelButtonStyle?(cancelButton,cancelButtonHeight) ?? false)) && isCancelButtonEnabled
        cancelButtonStyle?(cancelButton, cancelButtonHeight)
        let cancelMultiplier: CGFloat = isCancelButtonEnabled ? 1.0 : 0.0
        cancelButton.isHidden = (isCancelButtonEnabled ? cancelButtonHeight : 0) <= 0
        cancelButton.topAnchor.constraint(equalTo: mainStackView.bottomAnchor,constant: spacing).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor,constant: -spacing).isActive = true
        
        cancelButtonHeightConstraint = cancelButton.heightAnchor.constraint(equalToConstant: cancelButtonHeight  * cancelMultiplier)
        cancelButton.addTarget(self, action: #selector(AlertViewController.cancelAction(_:)), for: .touchUpInside)
    }
    
    fileprivate func setupMainView() {
        self.mainView.isExclusiveTouch = true
        mainView.widthAnchor.constraint(equalToConstant: deviceWidth * 0.7).isActive = true
        mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        mainViewCenterYConstraint =
            mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: contentOffset)
    }
    
    fileprivate func setupWaitView() {
        waitView.isHidden = true
//        waitView.centerXAnchor.constraint(equalTo: mainStackView.centerXAnchor).isActive = true
//        waitView.centerYAnchor.constraint(equalTo: mainStackView.centerYAnchor).isActive = true
        waitView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.8).isActive = true
//        waitView.heightAnchor.constraint(equalTo: waitView.widthAnchor, multiplier: 0.05).isActive = true
    }
    
    //MARK: Helper Functions
    
    fileprivate func animateStackView(withOptionalAnimations animations: (()->Void)? = nil, completionBlock: (()->Void)? = nil) {
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            animations?()
            self?.mainStackView?.setNeedsLayout()
            self?.mainStackView?.layoutIfNeeded()
            self?.mainView?.setNeedsLayout()
            self?.mainView?.layoutIfNeeded()
        }) { (bool) in
            completionBlock?()
        }
    }
    
    fileprivate func setup(){
        actions = [AlertAction]()
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.layer.cornerRadius = 15
        mainView.layer.backgroundColor = UIColor.white.cgColor
        mainView.isHidden = true
        mainView.lastLocation = self.view.center
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didInitAnimation {
            didInitAnimation = true
            mainView.center.y = self.view.bounds.maxY + mainView.bounds.midY
            mainView.isHidden = false
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 6.0, options: [], animations: { [weak self] () -> Void in
                if let sself = self {
                    sself.mainView.center = sself.view.center
                    let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(sself.backgroundAlpha))
                    sself.view.backgroundColor = backgroundColor
                }
            })
        }
    }
    
    //MARK: Init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(title: String? = nil,
                            message: String? = nil,
                            verticalSpacing spacing: CGFloat = -1,
                            stackSpacing:CGFloat = 10,
                            sideSpacing: CGFloat = 20,
                            titleFontSize: CGFloat = 0,
                            messageFontSize: CGFloat = 0,
                            buttonsHeight: CGFloat = 0,
                            cancelButtonHeight: CGFloat = 0,
                            fontName: String = "AvenirNext-Medium",
                            boldFontName: String = "AvenirNext-DemiBold") {
        self.init(nibName: nil, bundle: nil)
        _title = title
        _msg = message
        self.spacing = spacing
        self.stackSpacing = stackSpacing
        self.sideSpacing = sideSpacing
        self.titleFontSize = titleFontSize
        self.msgFontSize = messageFontSize
        self.buttonHeight = buttonsHeight
        self.cancelButtonHeight = cancelButtonHeight
        self.fontName = fontName
        self.fontNameBold = boldFontName
    }
    
}

public typealias ActionHandler = (AlertViewController) -> Void

open class AlertAction {
    open var title: String?
    open var isEnabled: Bool = true
    open var handler: ActionHandler?
    
    public init(title: String, handler: ActionHandler? = nil) {
        self.title = title
        self.handler = handler
    }
}

fileprivate class MainView: UIView {
    
    var lastLocation = CGPoint(x: 0, y: 0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLocation = self.center
        super.touchesBegan(touches, with: event)
    }
}

public enum AlertDismissDirection {
    case top, bottom, both, nones
}
