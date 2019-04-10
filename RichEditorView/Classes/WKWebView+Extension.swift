//
//  WKWebView+Extension.swift
//  Pods-Test_RichTextEditor
//
//  Created by Yiqiang Zeng on 2019/4/10.
//

import WebKit

fileprivate typealias OlderClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Any?) -> Void
fileprivate typealias NewerClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void

extension WKWebView {
    
    var keyboardDisplayRequiresUserAction: Bool? {
        get {
            return self.keyboardDisplayRequiresUserAction
        }
        set {
            self.setKeyboardRequiresUserInteraction(newValue ?? true)
        }
    }
    
    func setKeyboardRequiresUserInteraction( _ value: Bool) {
        guard
            let WKContentViewClass: AnyClass = NSClassFromString("WKContentView") else {
                print("Cannot find the WKContentView class")
                return
        }
        
        let olderSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:")
        let newerSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        
        if let method = class_getInstanceMethod(WKContentViewClass, olderSelector) {
            
            let originalImp: IMP = method_getImplementation(method)
            let original: OlderClosureType = unsafeBitCast(originalImp, to: OlderClosureType.self)
            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3) in
                original(me, olderSelector, arg0, !value, arg2, arg3)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }
        
        if let method = class_getInstanceMethod(WKContentViewClass, newerSelector) {
            
            let originalImp: IMP = method_getImplementation(method)
            let original: NewerClosureType = unsafeBitCast(originalImp, to: NewerClosureType.self)
            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3, arg4) in
                original(me, newerSelector, arg0, !value, arg2, arg3, arg4)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }
    }
}

/// https://robopress.robotsandpencils.com/swift-swizzling-wkwebview-168d7e657106
fileprivate var ToolbarHandler: UInt8 = 0
extension WKWebView {
    
    func getRichEditorInputAccessoryView() -> UIView? {
        return objc_getAssociatedObject(self, &ToolbarHandler) as? UIView
    }
    
    func addRichEditorInputAccessoryView(toolbar: UIView?) {
        guard let toolbar = toolbar else { return }
        objc_setAssociatedObject(self, &ToolbarHandler, toolbar, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        var candidateView: UIView? = nil
        for view in self.scrollView.subviews {
            if view.classForCoder.description().hasPrefix("WKContent") {
                candidateView = view
            }
        }
        guard let targetView = candidateView else { return }
        let newClass: AnyClass? = classWithCustomAccessoryView(targetView: targetView)
        object_setClass(targetView, newClass!)
    }
    
    private func classWithCustomAccessoryView(targetView: UIView) -> AnyClass? {
        guard let targetSuperClass = targetView.superclass else { return nil }
        let customInputAccessoryViewClassName = "\(targetSuperClass)_CustomInputAccessoryView"
        
        var newClass: AnyClass? = NSClassFromString(customInputAccessoryViewClassName)
        if newClass == nil {
            newClass = objc_allocateClassPair(object_getClass(targetView), customInputAccessoryViewClassName, 0)
        } else {
            return newClass
        }
        
        let newMethod = class_getInstanceMethod(WKWebView.self, #selector(WKWebView.getCustomInputAccessoryView))
        class_addMethod(newClass.self, #selector(getter: UIResponder.inputAccessoryView), method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))
        
        objc_registerClassPair(newClass!)
        
        return newClass
    }
    
    @objc func getCustomInputAccessoryView() -> UIView? {
        var superWebView: UIView? = self
        while (superWebView != nil) && !(superWebView is WKWebView) {
            superWebView = superWebView?.superview
        }
        let customInputAccessory = objc_getAssociatedObject(superWebView!, &ToolbarHandler)
        return customInputAccessory as? UIView
    }
}
