//
//  ContentView.swift
//  ModelPickerDemo
//
//  Created by Chander Siddarth on 2020-12-08.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    
    @State private var isPlacementEnabled = false // swift ui monitors this variable.
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    private var models: [Model] = {
       // Dynamically get our model filenames
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModels: [Model] = []
        
        for fileName in files where fileName.hasSuffix("usdz") {
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        
        return availableModels
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            
            if self.isPlacementEnabled == false {
                ModelPickerView(isPlaceEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            } else {
                PlacementButtonsView(isPlaceEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var modelConfirmedForPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        //let arView = ARView(frame: .zero)
        let arView = CustomARView(frame: .zero)
        
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal, .vertical]
//        config.environmentTexturing = .automatic
//
//        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
//            config.sceneReconstruction = .mesh
//
//        }
//
//        arView.session.run(config)
        
        return arView
    }
    
    // here is where the usdz files get in ...
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedForPlacement {
            print("DEBUG: Adding model to scene: \(model.modelName)")
            
//            let filename = modelName + ".usdz"
//            let modelEntity = try! ModelEntity.loadModel(named: modelName)
//
//            // In realityKit all objects should be attached to an anchor.
//            let anchorEntity = AnchorEntity(plane: .any) // allows you to add it to any entity.
//            anchorEntity.addChild(modelEntity)
//            uiView.scene.addAnchor(anchorEntity)
            
            if let modelEntity = model.modelEntity {
                let anchorEntity = AnchorEntity(plane: .any) // allows you to add it to any entity.
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("DEBUG: Unable to load model entity for \(model.modelName)")
            }
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
}

class CustomARView : ARView {
    var focusEntity: FocusEntity?
    required init(frame frameRect: CGRect) {
      super.init(frame: frameRect)
        
        
    
      self.setupConfig()
      self.focusEntity = FocusEntity(on: self, focus: .classic)
  //    self.focusEntity = FocusEntity(on: self, style: .colored(onColor: .red, offColor: .blue, nonTrackingColor: .orange))
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

extension CustomARView : FocusEntityDelegate {
    func toTrackingState() {
        print("tracking")
    }
    
    func toInitializingState() {
        print("Initializing")
    }
}

struct ModelPickerView : View {
    // Passing as a binding variable allows it to have read write access => reference var
    @Binding var isPlaceEnabled: Bool // Binding variable has a source fo truth outside the struct
    @Binding var selectedModel: Model?
    
    // these parameters get initialized with the ctor?
    var models: [Model]
    
    var body: some View {

            ScrollView(.horizontal, showsIndicators:false) {
                HStack(spacing: 10) {
                    ForEach(0..<self.models.count) {
                        index in
                        //Text(self.models[index])
                        Button(action: {
                            print("DEBUG: selected model: \(self.models[index])")
                            self.isPlaceEnabled = true
                            self.selectedModel = self.models[index]
                        }) {
                            // what the button looks like
                            // by default the images are not resizable.
                            Image(uiImage: self.models[index].image)
                                .resizable()
                                .frame(height: 80)
                                .aspectRatio(1/1, contentMode: .fit)
                                .background(Color.white)
                                .cornerRadius(12)
                            
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(20)
                .background(Color.black.opacity(0.5))
            }
        }
    }

struct PlacementButtonsView : View {
    @Binding var isPlaceEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack {
            // Cancel Button
            Button(action: {
                print("DEBUG: Cancel model placement")
                resetPlacementParameters()
            }, label: {
                Image(systemName: "xmark")
                    .frame(width:60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30) // usualy half the width or the height
                    .padding(20)
            })
            
            // Confirm Button
            
            Button(action: {
                print("DEBUG: Model placement confirmed")
                self.modelConfirmedForPlacement = self.selectedModel
                resetPlacementParameters()
            }, label: {
                Image(systemName: "checkmark")
                    .frame(width:60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30) // usualy half the width or the height
                    .padding(20)
            })
        }
    }
    
    func resetPlacementParameters() {
        self.isPlaceEnabled = false
        self.selectedModel = nil
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
