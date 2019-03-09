//
//  CustomCell.swift
//  HelloCalendar
//
//  Created by B.Mossavi on 1/11/19.
//  Copyright © 2019 B.Mossavi. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var eventDotView: UIView!
}
