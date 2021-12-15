//
//  MovieList+CoreDataProperties.swift
//  
//
//  Created by Pratik Patel on 15/12/21.
//
//

import Foundation
import CoreData


extension MovieList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieList> {
        return NSFetchRequest<MovieList>(entityName: "MovieList")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var date: String?
    @NSManaged public var descriptions: String?
    @NSManaged public var image: String?

}
