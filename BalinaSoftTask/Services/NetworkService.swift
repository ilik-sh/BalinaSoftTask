//
//  NetworkService.swift
//  BalinaSoftTask
//
//  Created by Ilya on 24.08.22.
//

import Foundation
import UIKit

final class NetworkService {
    private var task: URLSessionDataTask?
    private let urlString = "https://junior.balinasoft.com/api/v2/photo/type"
    private let sendUrlString = "https://junior.balinasoft.com/api/v2/photo"
    private var totalPages = 7
    var delegate: NetworkServiceDelegate?
    
    func getTotalPages() {
        guard let url = URL(string: urlString) else { return }
        task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let data = data else {
                return
            }
            
            guard let content = try? JSONDecoder().decode(RecievedData.self, from: data) else {
                return
            }
            
            self.totalPages = content.totalPages
        })
    }
    
    func getContent(fromPage: Int, completionHandler: @escaping ([PhotoTypeDtoOut]) -> Void) {
        let queryItem = [URLQueryItem(name: "page", value: String(fromPage))]
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = queryItem
        guard let url = urlComponents.url else { return }
        let anotherTask = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                return
            }

            guard let content = try? JSONDecoder().decode(RecievedData.self, from: data)
            else {
                return
            }
            
            completionHandler(content.content)
        })
        anotherTask.resume()
    }
    
    func getPhotoInfo() {
        let group = DispatchGroup()
        getTotalPages()
        
        group.notify(queue: .global(), execute: {
            for page in 0...self.totalPages {
                group.enter()
                self.getContent(fromPage: page, completionHandler: { data in
                    for element in data {
                        self.getImage(element, completionHandler: { photo in
                            self.delegate?.onData(photo)
                        })
                    }
                    group.leave()
                })
            }
        })

    }

    func getImage(_ photo: PhotoTypeDtoOut, completionHandler: @escaping (PhotoInfo) -> Void) {
            guard let urlString = photo.image else {
                let element = PhotoInfo(id: photo.id, name: photo.name, image: nil)
                completionHandler(element)
                return
            }
            guard let url = URL(string: urlString) else { return }
            let anotherTask = URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                guard let data = data else {
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    return
                }
                
                let element = PhotoInfo(id: photo.id, name: photo.name, image: image)
                completionHandler(element)
            })
            anotherTask.resume()
    }
    
    func sendImage(_ image: SentData, completionHandler: () -> Void) {
        guard let url = URL(string: sendUrlString) else {
            return
        }
        
        let boundary = UUID().uuidString
        let session = URLSession.shared
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(image.name)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"photo\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(image.photo)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(image.typeId)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            
            if error != nil {
                print("\(error!.localizedDescription)")
            }
            
            guard let responseData = responseData else {
                print("no response data")
                return
            }
            
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
            }
        }).resume()
        
    }
}
