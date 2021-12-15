
import UIKit
import Alamofire
import SDWebImage
import MBProgressHUD
import SystemConfiguration
import CoreData
class MovieListVC: UIViewController {
    
    //MARK: OUTLET
    @IBOutlet weak var tableviewMovie: UITableView!
    
    //MARK: VARIABLE
    var pageNo : Int = 1
    var limit : Int = 10
    var totalPages : Int = 0
    var imageArray = [String]()
    var isLoadingList : Bool = false
    var movieListArray = [MovieModel]()
    var App = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: View Didload
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieListArray.removeAll()
        self.AlamofireGetCode()
    }
    //MARK: FUNCATION DEFINE
    func GetFetch(){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieList")
        let contex = self.App.persistentContainer.viewContext
        do {
            
            let result = try contex.fetch(fetch)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "name") as! String)
                
                let objS = MovieModel(MovieId: (Int(data.value(forKey: "id") as! String)!), MovieImage: (data.value(forKey: "image") as! String), MovieTitle: (data.value(forKey: "name") as! String), MovieReleaseDate: (data.value(forKey: "date") as! String), MovieOverView: (data.value(forKey: "descriptions") as! String))

                objS.dataFT = data
                print(objS.dataFT)
                self.movieListArray.append(objS)
                self.tableviewMovie.delegate = self
                self.tableviewMovie.dataSource = self
                tableviewMovie.reloadData()
                self.hidehud()
            }
        } catch {
            print("Failed")
        }
    }
    func showhud()
    {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = MBProgressHUDMode.indeterminate
        loading.bezelView.color = UIColor.clear
    }
    func hidehud()
    {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func showAlert(message:String)
    {
        let alertController = UIAlertController(title: "Network error", message: "Unable to contact the server", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
            
            //MARK : core data method Update
            self.GetFetch()
            
        }
        action1.setValue(UIColor.black, forKey: "titleTextColor")
        alertController.addAction(action1)
        if UIApplication.shared.windows[0].rootViewController != nil
        {
            DispatchQueue.main.async {
                UIApplication.shared.windows[0].rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func AlamofireGetCode()
    {
        if(!self.isInternetAvailable())
        {
            showAlert(message:"The Internet connection appears to be offline")
            
        }
        
        DispatchQueue.main.async {
            self.showhud()
        }
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
                        
                        // Core data Store
                        let contex = self.App.persistentContainer.viewContext
                        for i in  self.movieListArray{
                            
                            let obj = NSEntityDescription.insertNewObject(forEntityName: "MovieList", into: contex)
                            
                            obj.setValue(i.movieTitle, forKey: "name")
                            obj.setValue(String(i.movieId), forKey: "id")
                            obj.setValue(i.movieOverview, forKey: "descriptions")
                            obj.setValue(i.movieReleaseDate, forKey: "date")
                            obj.setValue(i.movieImage, forKey: "image")
   
                            do{
                                try contex.save()
                                
                            }
                            catch{
                                
                            }
                  
                        }
                
                        self.hidehud()
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

extension MovieListVC:UITableViewDelegate,UITableViewDataSource{
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
        
        if(!self.isInternetAvailable())
        {
            showAlert(message:"Unable to contact the server")
            
        }else{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailVC") as! MovieDetailVC
            vc.movieID = movieListArray[indexPath.row].movieId!
            vc.movieTitle = movieListArray[indexPath.row].movieTitle!
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
