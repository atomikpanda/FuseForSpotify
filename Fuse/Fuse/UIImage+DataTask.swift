//
//  UIImage+DataTask.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/8/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

extension UIImage {
    static func download(url: URL?, session: URLSession, done: @escaping (UIImage?)->())  {
        if let url = url {
            let task = session.dataTask(with: URLRequest(url: url)){ (data, response, error) in
                guard let data = data else {return}
                done(UIImage(data: data))
            }
            task.resume()
        }
    }
}
