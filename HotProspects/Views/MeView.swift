//
//  MeView.swift
//  HotProspects
//
//  Created by Hari krishna on 17/05/23.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct MeView: View {
    @State var name = "Hari"
    @State var email = "harikrishnakesineni@gmail.com"
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter your name", text: $name)
                TextField("Enter your email", text: $email)
                Image(uiImage: generateQrCode(string: "\(name) \n \(email)"))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
    }
    
    func generateQrCode(string: String) -> UIImage {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
