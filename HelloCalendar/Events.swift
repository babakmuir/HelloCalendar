//
//  Events.swift
//  HelloCalendar
//
//  Created by B.Mossavi on 2/19/19.
//  Copyright © 2019 B.Mossavi. All rights reserved.
//

import UIKit

class Events {
    
    var holiday = false

    var year = 1900
    
    var month = 01
    
    var day = 01
    
    var type = ""
    
    var title = ""
    
    init() {
        
    }

    init(year: Int, month: Int, day: Int) {
        
        self.year = year
        
        self.month = month
        
        self.day = day
        
    }
    
}

