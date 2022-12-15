//
//  Model.swift
//  ModelPicker
//
//  Created by admin on 12/14/22.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        
        let filename = self.modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename).sink(receiveCompletion: { loadCompletion in
            // handle our error
            print("DEBUG: Unable to Load ModelEntity for \(self.modelName)")
        }, receiveValue: {
            modelEntity in
            // get our entity
            self.modelEntity = modelEntity
            print("DEBUG: Successfully loaded the model")
        })
    }
}
