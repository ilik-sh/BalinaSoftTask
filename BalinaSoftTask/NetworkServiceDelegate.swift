//
//  NetworkServiceDelegate.swift
//  BalinaSoftTask
//
//  Created by Ilya on 24.08.22.
//

import Foundation
import UIKit

protocol NetworkServiceDelegate {
    func onData(_ data: PhotoInfo)
    func onImage(_ image: UIImage?)
}
