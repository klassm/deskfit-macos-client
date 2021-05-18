import SwiftUI

struct FooterView: View {
    @EnvironmentObject var bleConnection: BLEConnection
    @EnvironmentObject var workout: Workout
    
    var body: some View {
        HStack {
            Spacer()
            LoginLogoutButton()
            Button(action: {
                bleConnection.stop()
                workout.save()
                exit(0)
            }) {
                Text("Quit")
            }
        }
    }
}

struct FooterView_Previews: PreviewProvider {
    static var previews: some View {
        FooterView()
    }
}
