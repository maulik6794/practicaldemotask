
import Foundation
import CoreData
class MovieModel {
    
    var movieId:Int!
    var movieImage:String
    var movieTitle:String!
    var movieReleaseDate:String!
    var movieOverview:String!
    var dataFT = NSManagedObject()
    init(MovieId:Int,MovieImage:String,MovieTitle:String,MovieReleaseDate:String,MovieOverView:String)
    {
        self.movieId = MovieId
        self.movieImage = MovieImage
        self.movieTitle = MovieTitle
        self.movieReleaseDate = MovieReleaseDate
        self.movieOverview = MovieOverView
    }
    
}
