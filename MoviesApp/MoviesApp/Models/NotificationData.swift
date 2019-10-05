//
//  NotificationData.swift
//  MoviesApp
//
//  Created by Miller on 04/10/19.
//  Copyright © 2019 Miller. All rights reserved.
//

import Foundation

class NotificationData {
    var fromLayout: LayoutMode
    var indexPath: IndexPath
    
    init(from layout: LayoutMode, indexPath index: IndexPath) {
        self.fromLayout = layout
        self.indexPath = index
    }
}
