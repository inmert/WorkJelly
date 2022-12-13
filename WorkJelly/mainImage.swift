//
//  mainImage.swift
//  Pineapple
//
//  Created by Priyan Rai on 12/12/22.
//

import SwiftUI

struct mainImage: View {
    var body: some View {
        Image("pineApple")
            .resizable().frame(width: 200, height: 200)
            .offset(y: -100)
        
    }
}

struct mainImage_Previews: PreviewProvider {
    static var previews: some View {
        mainImage()
    }
}
