
import UIKit
import Alamofire
import SDWebImage

class ViewController: UIViewController {
    
    // MARK:- outlets.
    @IBOutlet weak var tableviewMovie: UITableView!
    
    // MARK:- variables.
    var pageNo : Int = 1
    var limit : Int = 10
    var totalPages : Int = 0
   
    var imageArray = [String]()
    var isLoadingList : Bool = false
    
    var movieListArray = [MovieModel]()
    
    // MARK:- view cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieListArray.removeAll()
        self.AlamofireGetCode()
    }
    
    
    
    
    func AlamofireGetCode()
    {
       
        var url:String!
        url = "https://api.themoviedb.org/3/movie/upcoming?api_key=14bc774791d9d20b3a138bb6e26e2579&language=en-US&page=\(pageNo)"
        
        AF.request(url, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success(let json):
                    print(json)
                    DispatchQueue.main.async {
                        print(json)
                        let responseDict = json as! NSDictionary
                        let resultDic = responseDict.value(forKey: "results") as! [[String:AnyObject]]
                        print(resultDic)
                        
                        for json in resultDic
                        {
                            let item = MovieModel.init(MovieId: (json["id"] as? AnyObject? as? Int) ?? 0, MovieImage: (json["poster_path"] as? AnyObject? as? String) ?? "", MovieTitle: (json["original_title"] as? AnyObject? as? String) ?? "", MovieReleaseDate: (json["release_date"] as? AnyObject? as? String) ?? "", MovieOverView: (json["overview"] as? AnyObject? as? String) ?? "")
                            
                            self.movieListArray.append(item)
                        }
                        
                        self.tableviewMovie.delegate = self
                        self.tableviewMovie.dataSource = self
                        self.tableviewMovie.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
    
}

class movieListtableviewCell:UITableViewCell{
    
    @IBOutlet weak var imgMovielist: UIImageView!
    
    @IBOutlet weak var lblMovieName: UILabel!
    
    @IBOutlet weak var lblMovieDate: UILabel!
    @IBOutlet weak var lblMovieDescription: UILabel!
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieListtableviewCell") as! movieListtableviewCell
        cell.selectionStyle = .none
        cell.lblMovieName.text = self.movieListArray[indexPath.row].movieTitle
        cell.lblMovieDate.text = self.movieListArray[indexPath.row].movieReleaseDate
        cell.lblMovieDescription.text = self.movieListArray[indexPath.row].movieOverview
            
       
        
        let objImgRow = self.movieListArray[indexPath.row].movieImage
        
        cell.imgMovielist.setImage("\("https://image.tmdb.org/t/p/w200")\(objImgRow)")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailVC") as! MovieDetailVC
        vc.movieID = movieListArray[indexPath.row].movieId!
        vc.movieTitle = movieListArray[indexPath.row].movieTitle!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //pagination
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isLoadingList = false
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((tableviewMovie.contentOffset.y + tableviewMovie.frame.size.height) >= tableviewMovie.contentSize.height)
        {
            if !isLoadingList
            {
                isLoadingList = true
                if self.totalPages == pageNo
                {
                    return
                }
                pageNo = pageNo + 1
                AlamofireGetCode()
                
            }
        }
    }
    
    
}

//MARK: - UIImageView
extension UIImageView{
    func setImage(_ url: String?, placeHolder: UIImage? = nil){
        //        guard let url = url else{return}
        if url != ""
        {
            self.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.sd_setImage(with: URL(string: url ?? ""), placeholderImage: placeHolder, completed: nil)
        }
    }
    //    func setGradient(colorTop: UIColor, colorBottom: UIColor)
    //      {
    //          let view = UIView(frame: self.bounds)
    //          let gradientLayer = CAGradientLayer()
    //          gradientLayer.frame = bounds
    //          gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
    //          gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
    //          gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
    //          gradientLayer.locations = [0, 1]
    //          view.layer.insertSublayer(gradientLayer, at: 0)
    //          self.addSubview(view)
    //          self.bringSubviewToFront(view)
    //      }
    func applyshadowWithCorner(containerView : UIView, cornerRadious : CGFloat){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor =  UIColor.init(red: 198/255, green: 198/255, blue: 198/255, alpha: 0.2).cgColor
        containerView.layer.shadowOpacity = 0.8
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 10
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
}
