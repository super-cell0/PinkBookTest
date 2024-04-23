//
//  POIViewController.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/18.
//
// 1 绑定appleID 申请key
// 2 定位SDK pod安装 AMapLocation
// 3 获取位置 单次定位 引入oc桥接文件
// 4 配置Key
// 5 设置期望定位精度
// 6 请求定位并拿到结果

import UIKit

class POIViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var locationManager = AMapLocationManager()
    lazy var mapSearch = AMapSearchAPI()
    
    let kPOITypes = "汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施"
    
    // 周边搜索POI请求
    lazy var aroundSearchRequest: AMapPOIAroundSearchRequest = {
        let request = AMapPOIAroundSearchRequest()
        //request.types = kPOITypes
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(self.latitude), longitude: CGFloat(self.longitude))
        //request.showFieldsType = .all
        return request
    }()
    
    lazy var keywordsSearchRequest: AMapPOIKeywordsSearchRequest = {
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = self.keywords
        
        return request
    }()
    
    
    var pois = [["不显示位置", ""]]
    var aroundSearchPOIS = [["不显示位置", ""]]
    var latitude = 0.0 // 纬度
    var longitude = 0.0 // 经度
    var keywords = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.requestLocationConfig()
        
        self.mapSearch?.delegate = self
        
        self.searchBar.delegate = self
        self.searchBar.becomeFirstResponder()
        self.tableView.keyboardDismissMode = .onDrag
        
    }
    
    
}

extension POIViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isBlank else { return }
        self.keywords = searchText
        self.pois.removeAll()
        self.keywordsSearchRequest.keywords = self.keywords
        self.mapSearch?.aMapPOIKeywordsSearch(self.keywordsSearchRequest)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.pois = self.aroundSearchPOIS
            self.tableView.reloadData()
        }
    }
    
}

extension POIViewController: AMapSearchDelegate {
    // 周边搜索
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        //print("response: \(response.pois)")
        self.hideLoadHUD()
        if response.pois.count == 0 {
            return
        }
        
        for poi in response.pois {
            let province = poi.province == poi.city ? "" : poi.province
            let address = poi.district == poi.address ? "" : poi.address
            let poi = [
                poi.name ?? "未知地点",
                "\(province.unWrappedText)\(poi.city.unWrappedText)\(poi.district.unWrappedText)\(address.unWrappedText)"
            ]
            self.pois.append(poi)
            if request is AMapPOIAroundSearchRequest {
                self.aroundSearchPOIS.append(poi)
            }
        }
        
        tableView.reloadData()
    }
    
}

extension POIViewController {
    /// 实时定位
    func requestLocationConfig() {
        // 5
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // 定位超时时间，最低2s，此处设置为2s
        locationManager.locationTimeout = 5
        // 逆地理请求超时时间，最低2s，此处设置为2s
        locationManager.reGeocodeTimeout = 5
        
        self.showLoadHUD()
        // 6
        locationManager.requestLocation(withReGeocode: true) { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            guard let self = self else { fatalError() }
            
            if let error = error {
                let error = error as NSError
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    print("定位错误: { \(error.code) - \(error.localizedDescription)};")
                    self.hideLoadHUD()
                    return
                } else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                            || error.code == AMapLocationErrorCode.timeOut.rawValue
                            || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                            || error.code == AMapLocationErrorCode.badURL.rawValue
                            || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                            || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，reGeocode无返回值，进行annotation的添加
                    print("逆地理错误: { \(error.code) - \(error.localizedDescription)};")
                    self.hideLoadHUD()
                    return
                } else {
                    // 没有错误 location有返回值 reGeocode是否有返回值取决于是否进行逆地理操作 进行 annotation的添加
                }
                
            }
            
            //location: <+29.58476101,+106.49354329> +/- 44.00m (speed -1.00 mps / course -1.00) @ 2024/4/19 中国标准时间 14:08:52
            if let location = location {
                //print("location: \(location)")
                //print("latitude: \(location.coordinate.latitude)")
                //print("longitude: \(location.coordinate.longitude)")
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                // 检索周边POI
                self.mapSearch?.aMapPOIAroundSearch(self.aroundSearchRequest)
            }
            
            //reGeocode: AMapLocationReGeocode:{formattedAddress:重庆市渝北区余松路靠近安泰佳苑(余松一支路); country:中国;province:重庆市; city:重庆市; district:渝北区; citycode:023; adcode:500112; street:余松路; number:111号; POIName:安泰佳苑(余松一支路); AOIName:安泰佳苑(余松一支路);}
            if let reGeocode = reGeocode {
                //print("reGeocode: \(reGeocode)")
                guard let formattedAdress = reGeocode.formattedAddress, !formattedAdress.isEmpty else { return }
                let province = reGeocode.province == reGeocode.city ? "" : reGeocode.province
                
                //print("\(province)\(regeocode.city!)\(regeocode.district!)\(regeocode.street ?? "")\(regeocode.number ?? "")")
                let currentPOI = [
                    reGeocode.poiName ?? "未知地点",
                    "\(province.unWrappedText)\(reGeocode.city.unWrappedText)\(reGeocode.district.unWrappedText)\(reGeocode.street.unWrappedText)\(reGeocode.number.unWrappedText)"
                ]
                
                self.pois.append(currentPOI)
                self.aroundSearchPOIS.append(currentPOI)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
}

extension POIViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pois.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kPOICellID, for: indexPath) as! POICell
        
        let poi = pois[indexPath.row]
        cell.poi = poi
        
        return cell
    }

}

extension POIViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
