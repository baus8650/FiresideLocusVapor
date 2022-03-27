//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/21/22.
//

import Fluent
import Foundation


final class CamperGroupPivot: Model {
    static let schema = "camper-group-pivot"
      
      // 2
      @ID
      var id: UUID?
      
      // 3
      @Parent(key: "camperID")
      var camper: Camper
      
      @Parent(key: "groupID")
      var group: Groups
      
      // 4
      init() {}
      
      // 5
      init(
        id: UUID? = nil,
        camper: Camper,
        group: Groups
      ) throws {
        self.id = id
        self.$camper.id = try camper.requireID()
        self.$group.id = try group.requireID()
      }
}
