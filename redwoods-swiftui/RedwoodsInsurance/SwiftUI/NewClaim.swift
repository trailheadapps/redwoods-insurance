//
//  NewClaim.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/9/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI

struct NewClaim: View {
  
  var body: some View {
    VStack{
      IncidentLocationCmp()
      Spacer()
    }
  }
}

struct NewClaim_Previews: PreviewProvider {
    static var previews: some View {
        NewClaim()
    }
}
