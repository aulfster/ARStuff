//
//  Model.swift
//  ModelPickerDemo
//
//  Created by Chander Siddarth on 2020-12-08.
//

import UIKit
import RealityKit
import Combine // Some sort of an async framework?

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                // Handle Error
                print("DEBUG: Unable to load model entity for modelName: \(self.modelName)")
                
            }, receiveValue: { modelEntity in
                // Get model entity
                self.modelEntity = modelEntity
                print("DEBUG: Successfully loaded modelEntity for modelName: \(self.modelName)")
            })
        
    }
}

