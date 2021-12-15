//
//    RootClass.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

class MovieModel {
    
    var movieId:String!
    var movieImage:String
    var movieTitle:String!
    var movieReleaseDate:String!
    var movieOverview:String!
    
    init(MovieId:String,MovieImage:String,MovieTitle:String,MovieReleaseDate:String,MovieOverView:String)
    {
        self.movieId = MovieId
        self.movieImage = MovieImage
        self.movieTitle = MovieTitle
        self.movieReleaseDate = MovieReleaseDate
        self.movieOverview = MovieOverView
    }
    
}
