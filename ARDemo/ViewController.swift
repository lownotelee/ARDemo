//
//  ViewController.swift
//  ARDemo
//
//  Created by Lee on 9/9/20.
//  Copyright © 2020 radev. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    private var node: SCNNode!
    
    private let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show statistics such as fps and timing information
        addTapGesture()
        addPinchGesture()
        addRotationGesture()
        self.sceneView.showsStatistics = true
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    
    private func addRotationGesture() {
        let panGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        self.sceneView.addGestureRecognizer(panGesture)
    }
    
    private func addPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        self.sceneView.addGestureRecognizer(pinchGesture)
    }
    
    private var lastRotation: Float = 0
    
    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .changed:
            // 1
            self.node.eulerAngles.y = self.lastRotation - Float(gesture.rotation)
        case .ended:
            // 2
            self.lastRotation += Float(gesture.rotation)
        default:
            break
        }
    }
    
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
        
        switch gesture.state {
        // 1
        case .began:
            gesture.scale = CGFloat(node.scale.x)
        // 2
        case .changed:
            var newScale: SCNVector3
            // a
            if gesture.scale < 0.5 {
                newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
                // b
            } else if gesture.scale > 3 {
                newScale = SCNVector3(3, 3, 3)
                // c
            } else {
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            // d
            node.scale = newScale
        default:
            break
        }
    }
    
    @objc func didTap(_ gesture: UIPanGestureRecognizer) {
        // 1
        let tapLocation = gesture.location(in: self.sceneView)
        let results = self.sceneView.hitTest(tapLocation, types: .featurePoint)
        
        // 2
        guard let result = results.first else {
            return
        }
        
        // 3
        let translation = result.worldTransform.translation
        
        //4
        guard let node = self.node else {
            self.addBox(x: translation.x, y: translation.y, z: translation.z)
            return
        }
        node.position = SCNVector3Make(translation.x, translation.y, translation.z)
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        // 1
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        // 2
        let colors = [UIColor.green, // front
            UIColor.red, // right
            UIColor.blue, // back
            UIColor.yellow, // left
            UIColor.purple, // top
            UIColor.gray] // bottom
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
        box.materials = sideMaterials
        
        // 3
        self.node = SCNNode()
        self.node.geometry = box
        self.node.position = SCNVector3(x, y, z)
        
        //4
        sceneView.scene.rootNode.addChildNode(self.node)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
