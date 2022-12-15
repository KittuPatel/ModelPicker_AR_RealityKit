//
//  ContentView.swift
//  ModelPicker
//
//  Created by admin on 12/14/22.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelAfterConfirm: Model?
    
    var models: [Model] = [Model(modelName: "flower_tulip"), Model(modelName: "toy_biplane"), Model(modelName: "toy_drummer"), Model(modelName: "guitar")]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelAfterConfirm: self.$modelAfterConfirm)
            
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelAfterConfirm: self.$modelAfterConfirm)
            } else {
                ModelPickerView(models: self.models, isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var modelAfterConfirm: Model?
    
    func makeUIView(context: Context) -> ARView {
        let arView = CustomFocusARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelAfterConfirm {
            if let modelEntity = model.modelEntity {
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("DEBUG: Unable to load model")
            }
        }
        
        DispatchQueue.main.async {
            self.modelAfterConfirm = nil
        }
        
    }
    
}

class CustomFocusARView: ARView, FocusEntityDelegate {
    
    enum FocusStyleChoices {
        case classic
        case material
        case color
    }
    var focusEntity: FocusEntity?
    let focusStyle: FocusStyleChoices = .classic
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        self.setupConfig()

        switch self.focusStyle {
        case .color:
            self.focusEntity = FocusEntity(on: self, focus: .plane)
        case .material:
            do {
                let onColor: MaterialColorParameter = try .texture(.load(named: "Add"))
                let offColor: MaterialColorParameter = try .texture(.load(named: "Open"))
                self.focusEntity = FocusEntity(
                    on: self,
                    style: .colored(
                        onColor: onColor, offColor: offColor,
                        nonTrackingColor: offColor
                    )
                )
            } catch {
                self.focusEntity = FocusEntity(on: self, focus: .classic)
                print("Unable to load plane textures")
                print(error.localizedDescription)
            }
        default:
            self.focusEntity = FocusEntity(on: self, focus: .classic)
        }
    }
    
    func setupConfig() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        session.run(config)
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}

struct ModelPickerView: View {
    
    var models: [Model]
    
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(alignment: .bottom, spacing: 30){
                ForEach(0 ..< self.models.count, id: \.self) {
                    index in
                    Button(action: {
                        self.isPlacementEnabled = true
                        self.selectedModel = self.models[index]
                    }, label: {
                        Image(uiImage: self.models[index].image).resizable().frame(height:60)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.blue)
                            .cornerRadius(15)
                            
                    }).buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding([.top, .leading, .trailing], 20)
        .background(Color.black.opacity(0.4))
    }
}

struct PlacementButtonsView: View {
    
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelAfterConfirm: Model?
    
    var body: some View {
        HStack {
            Button(action: {
                self.isPlacementEnabled = false
                self.selectedModel = nil
            }) {
                Image(systemName: "xmark")
                    .frame(width: 40, height: 40)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(20)
                    .padding(20)
            }
            
            Button(action: {
                self.modelAfterConfirm = self.selectedModel
                
                self.isPlacementEnabled = false
                self.selectedModel = nil
                print(self.modelAfterConfirm!)
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 40, height: 40)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(20)
                    .padding(20)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
