//
//  SampleData.swift
//  samsara
//
//  Created by 이윤혜 on 2017. 11. 27..
//  Copyright © 2017년 이윤혜. All rights reserved.
//


import Foundation

struct Sample {
    let title: String
    let description: String
    let image: String
}

struct SampleData {
    let samples = [
        Sample(title: "Photo Object Detectrion", description: "불러온 이미지에 있는 사물 인식", image: "ic_photo"),
        Sample(title: "Real Time Object Detection", description: "실시간으로 카메라에 보이는 사물 인식", image: "ic_camera"),
        Sample(title: "Facial Analysis", description: "사람 얼굴로부터 나이, 성별, 감정 추측", image: "ic_emotion")
    ]
}

