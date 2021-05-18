import SwiftUI
import CoreBluetooth

func distanceTextFor(_ meters: Double) -> String {
    if (meters < 10000) {
        let rounded = Int(meters.rounded())
        return "\(rounded) m"
    }
    return String(format: "%.00f km", meters / 1000.0)
}


func stepsTextFor(_ steps: Double) -> String {
    return String(Int(steps.rounded()))
}


struct RunningView: View {
    @EnvironmentObject
    var device: DFT200
    @EnvironmentObject
    var workout: Workout

    var body: some View {
        let speedLevel = self.device.status.speedLevel
        let steps = workout.steps
        let meters = workout.distanceMeters
        
        let renderButton = { (speed: Int) in
            Button(action: {
                device.setSpeed(speed: UInt8(speed))
            }) {
                Text("\(speed)")
            }
            .background(speedLevel == speed ? Color.blue : Color.secondary)
            .foregroundColor(speedLevel == speed ? Color.white : Color.black)
            .cornerRadius(5)
        }
        
        VStack {
            Text("\(stepsTextFor(steps)) Steps")
            Text("\(distanceTextFor(meters))")
            
            HStack {
                ForEach(1..<5) { index in
                    renderButton(index * 10)
                }
            }
            HStack {
                ForEach(5..<9) { index in
                    renderButton(index * 10)
                }
            }
            HStack {
                Button(action: {
                    self.device.stop()
                }) {
                    Text("Stop")
                }
                
                Button(action: {
                    self.device.pause()
                }) {
                    Text("Pause")
                }
            }
        }
    }
}
