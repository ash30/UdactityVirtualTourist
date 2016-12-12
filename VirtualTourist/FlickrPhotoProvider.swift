//
//  FlickrPhotoProvider.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 12/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation

// MARK: MODELS

enum FlickrProviderError: Error {
    case badPhotoUrl
    case unrecognisedSearchResult
}

struct FlickrPhotoReference {
    
    let id: String // really this is an int but I think its too big?
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    
    var url: URL? {
        return URL.init(string:"https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_z.jpg")
    }
    
}

extension FlickrPhotoReference {
    
    init?(jsonResponse:[String:Any]) {
        
        guard
            let id = jsonResponse["id"] as? String,
            let owner = jsonResponse["owner"] as? String,
            let secret = jsonResponse["secret"] as? String,
            let server = jsonResponse["server"] as? String,
            let farm = jsonResponse["farm"] as? Int,
            let title = jsonResponse["title"] as? String
            else {
                return nil
        }
        self.init(id: id, owner: owner, secret: secret, server: server, farm: farm, title: title)
    }
    
}

// MARK: FLICKR SERVICE PROVIDER

struct FlickServiceConfig: ResourceServerDetails {
    enum Path: String, RawRepresentableAsString {
        case root = "/services/rest"
    }
    
    enum Params: String {
        case method
        case api_key
        case format
        case nojsoncallback
        case auth_token
        case lat
        case lon
        case page
        case per_page
    }
    
    enum Methods: String {
        case photoSearch = "flickr.photos.search"
    }
    
    enum Formats: String {
        case json
    }
    
    let scheme : String = "https"
    let host: String = "api.flickr.com"
    let Key: String = "92b39eb447a17d8dca0d4e606cd039c6"
}

struct FlickrPhotoProvider: ServiceClient {
    
    var resourceServerDetails = FlickServiceConfig()
    var network: HTTPClient
    
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int) -> Promise<[FlickrPhotoReference]> {
        
        // 1) Build up URL for photo searchPhotos_byLocation
        
        let baseURL = resourceServerDetails.url(forResource: FlickServiceConfig.Path.root)
        baseURL.queryItems = []
        baseURL.queryItems?.append(
            URLQueryItem(name: FlickServiceConfig.Params.method.rawValue,
                         value: FlickServiceConfig.Methods.photoSearch.rawValue
            )
        )
        baseURL.queryItems?.append(
            URLQueryItem(name: FlickServiceConfig.Params.api_key.rawValue,
                         value: resourceServerDetails.Key)
        )
        baseURL.queryItems?.append(
            URLQueryItem(name: FlickServiceConfig.Params.format.rawValue,
                         value: FlickServiceConfig.Formats.json.rawValue
            )
        )
        baseURL.queryItems?.append(
            URLQueryItem(name: FlickServiceConfig.Params.nojsoncallback.rawValue, value: "1")
        )
        baseURL.queryItems?.append(
            URLQueryItem(name: FlickServiceConfig.Params.lat.rawValue, value: "\(lat)")
        )
        baseURL.queryItems?.append(
            URLQueryItem(name: FlickServiceConfig.Params.lon.rawValue, value: "\(long)")
        )
        baseURL.queryItems?.append(
            URLQueryItem(name: FlickServiceConfig.Params.page.rawValue, value: "\(seed)")
        )
        baseURL.queryItems?.append(
            URLQueryItem(name: FlickServiceConfig.Params.per_page.rawValue, value: "\(10)")
        )
    
        // 2) Send of the request an parse the result
        
        var request = URLRequest(url: baseURL.url!)   // FIXME: GAURD AGAINST BAD URLS
        // request.cachePolicy = .returnCacheDataElseLoad


        let photoList = network.send(request: request)
        
        return photoList.then(onSuccess: { (d:Data) throws -> [FlickrPhotoReference] in
            
            guard
                let json = self.decodeJson(d, jsonBuffering:0),
                let photos = json["photos"] as? [String:Any],
                let photoUrls = photos["photo"] as? [[String:Any]]
                else {
                    
                    // FIXME: WE NEED TO THROW
                    throw FlickrProviderError.unrecognisedSearchResult
            }
            
            return photoUrls.map{
                FlickrPhotoReference.init(jsonResponse: $0)!

            }

            }, onReject: nil
        )
    }
    
    func getPhoto(_ ref:FlickrPhotoReference) -> Promise<Data> {
        
        guard let url = ref.url else {
            let result = Promise<Data>()
            result.reject(error: FlickrProviderError.badPhotoUrl)
            return result
        }
        
        var request = URLRequest(url: url)
        
        // if we have prefetched it already, reuse the data 
        // request.cachePolicy = .returnCacheDataElseLoad
        
        return network.send(request: URLRequest(url: url))
        
    }
}


