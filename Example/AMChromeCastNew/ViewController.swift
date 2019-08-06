//
//  ViewController.swift
//  AMChromeCastNew
//
//  Created by sarath.yarra1300@gmail.com on 08/06/2019.
//  Copyright (c) 2019 sarath.yarra1300@gmail.com. All rights reserved.
//

import UIKit
import AMChromeCastNew

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        AMChromeCastHelper.sharedInstance.InitilizeChromeCast()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

