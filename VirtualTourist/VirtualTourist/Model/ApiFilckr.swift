//
//  ApiFilckr.swift
//  VirtualTourist
//
//  Created by Asmahero on ١٨ شوال، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Asmahero. All rights reserved.
//

import CoreLocation
import Foundation
class ApiFilckr {
    enum Endpoint {
        
        struct parameterKeys{
            static let apiKey = "api_key"
            static let bbox = "bbox"
            static let  method = "method"
            static let extras = "extras" //Currently supported fields are: description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o
            static let perPage = "per_page" // how much photos per page to display
            static let page = "page" // navigate between pages to get all the results
            // static let format = "format"
            static let safeSearch = "safe_search" //1 for safe. 2 for moderate. 3 for restricted. (Please note: Un-authed calls can only see Safe content.)
            static let text = "text" //A free text search. Photos who's title, description or tags contain the text will be returned. You can exclude results that match a term by prepending it with a - character.
            static let responseFormat = "format"
            //https://www.flickr.com/services/api/response.json.html callback function
            static let NoJasonCallBack = "nojsoncallback"
            
        }
        struct parameterValues{
            static let apiKey = "cbe4717c4fe7b7c34a33bd6c0587b959"
            //https://api.flickr.com/services/rest/?method=flickr.photos.search in photos category
            static let searchMethod = "flickr.photos.search"
            static let getPhotosMethod = "flickr.galleries.getPhotos" //needed later
            static let responseFormat = "json"
            static let extras = "url_m"
            static let safeSearch = "1"
            static let NoJasonCallBack = "1" //means Yes just want the raw JSON
        }
        static func getBboxValues(from coordinate: CLLocationCoordinate2D) -> String
        {
            //Longitude has a range of -180 to 180 , latitude of -90 to 90. Defaults to -180, -90, 180, 90 if not specified.
            //The 4 values represent the bottom-left corner of the box and the top-right corner, minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude.
            //(width)
            let bboxv1w = 1.8
            //(height)
            let bboxv2h = 1.8
            let lat = coordinate.latitude
            let long = coordinate.longitude
            let maxLon =   min(long + bboxv1w, 180)
            let minlon = max(long - bboxv1w, -180)
            let maxLat =   min(lat + bboxv2h, 90)
            let minlat = max(lat - bboxv2h, -90)
            return "\(minlon),\(minlat),\(maxLon),\(maxLat)"
        }
        
    }
    // "https://www.flickr.com/services/rest?method= 1....etc"
    static func geturl(from parametersurl: [String:Any]) -> URL {
        //The REST request Endpoint URL is base variable for GET AND POST ACTIONS
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        //this will go for every [key:value] in parametersurl and then append it as queryitem
        for (key, value) in parametersurl
        {
            
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    static func getSearchPwithinBbox(with coordinate: CLLocationCoordinate2D, pageNumber: Int, completion: @escaping ([URL]?, Error?, String?) -> ())
    {
        //guard scentences to make sure, it will not continue without making sure guard situation is met otherwise return error without continue.
        let parametersurl = [
            Endpoint.parameterKeys.method : Endpoint.parameterValues.searchMethod,
            Endpoint.parameterKeys.apiKey : Endpoint.parameterValues.apiKey,
            Endpoint.parameterKeys.bbox : Endpoint.getBboxValues(from: coordinate),
            Endpoint.parameterKeys.safeSearch : Endpoint.parameterValues.safeSearch,
            Endpoint.parameterKeys.extras : Endpoint.parameterValues.extras,
            Endpoint.parameterKeys.responseFormat : Endpoint.parameterValues.responseFormat,
            Endpoint.parameterKeys.NoJasonCallBack : Endpoint.parameterValues.NoJasonCallBack,
            Endpoint.parameterKeys.page : pageNumber,
            Endpoint.parameterKeys.perPage : 9 // 9 photos per page
            ] as [String:Any]
        let request = URLRequest(url: geturl(from: parametersurl))
        let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
            
            guard (error == nil) else{
                completion(nil, nil, error?.localizedDescription)
                return
                
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299  else {
                // TODO: Call the completion handler and send the error so it can be handled on the UI, also call "return" so the code next to this block won't be executed (you need to call return in let guard's else body anyway)
                let statusCodeE = (response as? HTTPURLResponse)?.statusCode
                var errorMessage : String!
                switch statusCodeE{
                case 1:
                    errorMessage = "Too many tags in ALL query"
                    break;
                case 3 :
                    errorMessage = "Parameterless searches have been disabled"
                    break;
                case 4 :
                    errorMessage = "You don't have permission to view this pool"
                    break;
                case 10 :
                    errorMessage = "Sorry, the Flickr search API is not currently available."
                    break;
                case 100 :
                    errorMessage = "Invalid API Key"
                    break;
                case 105 :
                    errorMessage = "The requested service is temporarily unavailable."
                    break;
                case 111 :
                    errorMessage = "The requested response format was not found."
                    break;
                case 112 :
                    errorMessage = "The requested method was not found."
                    break;
                case 116 :
                    errorMessage = "One or more arguments contained a URL that has been used for abuse on Flickr."
                    break;
                    
                default:
                    errorMessage = "UnknownError"
                }
                completion (nil,nil,"the error is  \(errorMessage) ,the code is  \(statusCodeE)")
                return
            }
            
            
            //to check if there is a data to download
            guard let data = data else{
                completion(nil, nil,"the request has data" )
                return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] else{
                completion(nil, nil,"could not convert data to json" )
                return
            }
            //REST Response Format
            guard let stat = result["stat"] as? String, stat == "ok" else{
                completion(nil, nil ,"flicker api returned error")
                return
            }
            guard let photosDic = result["photos"] as? [String:Any] else{
                completion(nil, nil,"could not find photos in result dictionary" )
                return
            }
            //convert the photosDic to array
            guard let photosArray = photosDic["photo"] as? [[String:Any]] else{
                completion(nil, nil,"could not find key 'photo' in photo dictionary" )
                return
            }

             let photosUrls = photosArray.compactMap{photosDic -> URL? in
             guard let url = photosDic["url_m"] as? String else {return nil}
             return URL(string: url)
             }
 
            completion(photosUrls,nil,nil)
            
        }
        //Start the task
        task.resume()
        
        
    }
}


