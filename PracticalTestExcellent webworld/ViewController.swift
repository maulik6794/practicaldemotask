
import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
class movieListtableviewCell:UITableViewCell{
    
    @IBOutlet weak var imgMovielist: UIImageView!
    
    @IBOutlet weak var lblMovieName: UILabel!
    
    @IBOutlet weak var lblMovieDate: UILabel!
    @IBOutlet weak var lblMovieDescription: UILabel!
}


class ViewController: UIViewController {
    var objURLManager = URLManager()
    @IBOutlet weak var tableviewMovie: UITableView!
    var pageNo : Int = 1
    var limit : Int = 10
    var totalPages : Int = 0
    var idMovieArray = NSMutableArray()
   var titleArray = NSMutableArray()
    var overViewArray = NSMutableArray()
    var releseDateaArray = NSMutableArray()
    var imageArray = [String]()
    var isLoadingList : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableviewMovie.dataSource = self
        tableviewMovie.delegate = self
      
    AlamofireGetCode()
        // Do any additional setup after loading the view.
    }
    
  

    
    func AlamofireGetCode()
    {
        self.idMovieArray.removeAllObjects()
        self.titleArray.removeAllObjects()
        self.overViewArray.removeAllObjects()
        self.releseDateaArray.removeAllObjects()
        var url:String!
        url = "https://api.themoviedb.org/3/movie/upcoming?api_key=14bc774791d9d20b3a138bb6e26e2579&language=en-US&page=\(pageNo)"

        AF.request(url, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                    case .success(let json):
                        print(json)
                        DispatchQueue.main.async {
                           print(json)

          
                            if let JsonArray = json as? NSDictionary{
                             if let JsonDict =   JsonArray.value(forKey: "results") as? NSArray{
                                 
                                 self.totalPages  =   JsonArray.value(forKey: "total_pages") as! Int

                                 if let idArray =  JsonDict.value(forKey: "id") as? NSArray{
                                     self.idMovieArray = (idArray).mutableCopy() as! NSMutableArray
                                 }
                                 if let Title =  JsonDict.value(forKey: "original_title") as? NSArray{
                                     self.titleArray = (Title).mutableCopy() as! NSMutableArray
                                 }

                                 if let Overview =  JsonDict.value(forKey: "overview") as? NSArray{
                                     self.overViewArray = (Overview).mutableCopy() as! NSMutableArray
                                 }
                                 if let releseDate =  JsonDict.value(forKey: "release_date") as? NSArray{
                                     self.releseDateaArray = (releseDate).mutableCopy() as! NSMutableArray
                                 }
                                 if let imagess = JsonDict.value(forKey: "poster_path") as? [String]{
                                     self.imageArray = imagess
                                 }
                                 
                                 
                                 
                                 self.tableviewMovie.reloadData()
                                }
                            }



                        }
                    case .failure(let error):
                        print(error)
                    }
            }
    }

}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieListtableviewCell") as! movieListtableviewCell
        
        cell.lblMovieName.text = titleArray[indexPath.row] as! String
        cell.lblMovieDate.text = releseDateaArray[indexPath.row] as! String
        cell.lblMovieDescription.text = overViewArray[indexPath.row] as! String
       //hPps://image.tmdb.org/t/p/w200
      
     
      //  cell.imgMovielist.setImageWithURL("\("https://image.tmdb.org/t/p/w200") \(imageArray)", placeholderImage: "")

        let objImgRow = imageArray[indexPath.row]
        
        cell.imgMovielist.setImage("\("https://image.tmdb.org/t/p/w200") \(objImgRow)")
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
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
