//
//  ViewController.swift
//  AlertViewController
//
//  Created by Arpit Soni on 7/28/17.
//  Copyright © 2017 Arpit Soni. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var alert: AlertViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        alert = AlertViewController(title: "Hello", message: "Arpit")
        alert.isCancelButtonEnabled = false
        
        alert.cancelButtonStyle = { (button,height) in
            button.tintColor = UIColor.red
            button.setTitle("CANCEL", for: [])
        }
        alert.show(in: self, withLoading: true)
        
        self.alert.cancelButtonStyle = { (button,height) in
            button.tintColor = UIColor.green
            button.setTitle("CANCEL", for: [])
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.alert.addAction(AlertAction(title: "OK", handler: { (alertVC) in
                self.alert.msg = "You presssed OK"
            }))
            self.alert.isCancelButtonEnabled = true
            self.alert.isLoadingEnabled = false
        }
    }


}

