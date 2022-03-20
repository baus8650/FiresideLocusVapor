//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

//cycle = models.CharField(max_length=10, blank=False)
//    app_id = models.IntegerField()
//    first_name = models.CharField(max_length=100, blank=False)
//    last_name = models.CharField(max_length=100, blank=False)
//    age = models.IntegerField(blank=False)
//    gender = models.CharField(max_length=50, choices=GENDER, default='u')
//    instrument = models.CharField(max_length=50, blank=False)
//    tags = models.CharField(max_length=200, blank=True)
//    program = models.CharField(max_length=200, blank=True)
//    cabin = models.ForeignKey('Cabin', on_delete=models.CASCADE, null=True)
//    ensemble = models.ForeignKey('Ensemble', on_delete=models.CASCADE, null=True)
//    chamber = models.ManyToManyField('ChamberGroup', blank=True)
//    group = models.ManyToManyField('Grouping')


import Fluent
import Vapor

//final class Camper: Model {
//    static let schema = "campers"
//    
//    @ID
//    var id: UUID?
//    
//    @Field(key: "firstName")
//    var firstName: String
//    
//    @Field(key: "lastName")
//    var lastName: String
//    
//    @Field(key: "age")
//    var age: Int
//    
//    @Field(key: "instrument")
//    var instrument: String
//    
//    @Field(key: "tags")
//    var tags: [String]?
//    
//    @Field(key: "program")
//    var program: String
//    
//    @Parent(key: "cabin")
//    var cabin: Cabin
//    
//    @Field(key: "ensemble")
//    var ensemble: String
//    
////    @Children(for: \.$camper)
////    var events: [Event]?
//    
//    init() {}
//    
//    init(id: UUID? = nil, firstName: String, lastName: String, age: Int, instrument: String, tags: [String]? = [], program: String, cabin: Cabin? = nil, ensemble: String) {
//        self.id = id
//        self.firstName = firstName
//        self.lastName = lastName
//        self.age = age
//        self.instrument = instrument
////        self.events = events
//    }
//}
