

import UIKit
import Alamofire
class MovieDetailVC: UIViewController {

    //MARK: OUTLET
    @IBOutlet weak var imgMoviebackround: UIImageView!
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblMovieDesc: UILabel!
    
    @IBOutlet weak var lblMovieTitle: UILabel!
    
    @IBOutlet weak var lblOverView: UILabel!
    @IBOutlet weak var lblGenres: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblReleseDate: UILabel!
    @IBOutlet weak var lblProductCompanies: UILabel!
    @IBOutlet weak var lblProductBudget: UILabel!
    @IBOutlet weak var lblproductRevenue: UILabel!
    @IBOutlet weak var lblLanguages: UILabel!
    var movieID:Int!
    var movieTitle:String!
    var genersValues = [NSDictionary]()
   var companyValue = [NSDictionary]()
    var genrName = [String]()
    var compNames = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getMovieDetails()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnbackClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getMovieDetails()
    {
        
        var url:String!
        url = "https://api.themoviedb.org/3/movie/\(movieID!)?api_key=14bc774791d9d20b3a138bb6e26e2579&language=en-US"
        
        AF.request(url, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success(let json):
                    print(json)
                    DispatchQueue.main.async {
                        print(json)
                        let responseDict = json as! NSDictionary
                        self.lblMovieTitle.text = self.movieTitle
                        if  responseDict.value(forKey: "title") as! String != ""{
                            self.lblMovieName.text = (responseDict.value(forKey: "title") as! String)
                        }
                        if  responseDict.value(forKey: "tagline") as! String != ""{
                            self.lblMovieDesc.text = (responseDict.value(forKey: "tagline") as! String)
                        }
                        if  responseDict.value(forKey: "poster_path") as! String != ""{
                         //   self.imgMovie.image = (responseDict.value(forKey: "poster_path") as! String)
                            self.imgMovie.setImage("\("https://image.tmdb.org/t/p/w200")\(responseDict.value(forKey: "poster_path") as! String)")
                        }
                        
                        if  responseDict.value(forKey: "backdrop_path") as? String != nil{
                         //   self.imgMovie.image = (responseDict.value(forKey: "poster_path") as! String)
                            self.imgMoviebackround.setImage("\("https://image.tmdb.org/t/p/w500")\(responseDict.value(forKey: "backdrop_path") as! String)")
                        }
                        
                        
                        
                        
                        if  responseDict.value(forKey: "overview") as! String != ""{
                            self.lblOverView.text = (responseDict.value(forKey: "overview") as! String)
                            
                        }
                        
                        let genersArr = responseDict.value(forKey: "genres") as! [NSDictionary]
                        for i in 0..<genersArr.count
                        {
                       
                            self.genersValues.append(genersArr[i] as! NSDictionary)
                            
                          
                            
                        }
                        for i in 0..<genersArr.count{
                            
                            self.genrName.append(genersArr[i].value(forKey: "name") as! String)
                        }
            
                        let string = self.genrName.joined(separator: ", ")
                        self.lblGenres.text = string
                        
                        
                        if  responseDict.value(forKey: "runtime") as! Int != 0{
                            self.lblDuration.text =  "\((responseDict.value(forKey: "runtime") as! Int))\("  Minutes")"
                        
                        }
                        
                        if  responseDict.value(forKey: "release_date") as! String != ""{
                            self.lblReleseDate.text = (responseDict.value(forKey: "release_date") as! String)
                            
                        }
                        if  responseDict.value(forKey: "revenue") as! Int != 0{
                            self.lblproductRevenue.text = "\("$ ")\((responseDict.value(forKey: "revenue") as! Int))"
                            
                        }
                      
                        //......
                        
                        let companyName = responseDict.value(forKey: "production_companies") as! [NSDictionary]
                        for i in 0..<companyName.count
                        {
                       
                            self.companyValue.append(companyName[i] as! NSDictionary)

                            
                        }
                        for i in 0..<self.companyValue.count{
                            
                            self.compNames.append(self.companyValue[i].value(forKey: "name") as! String)
                        }
                        
                        let strings = self.compNames.joined(separator: ", ")
                        self.lblProductCompanies.text = strings
                        
                        
                        if  responseDict.value(forKey: "original_language") as! String != ""{
                            self.lblLanguages.text = responseDict.value(forKey: "original_language") as! String
                            
                        }
                       
                        
                        
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
 

}
