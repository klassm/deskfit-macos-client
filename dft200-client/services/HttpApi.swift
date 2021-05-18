import Foundation
import Embassy


func startHttpServer(bleConnection: BLEConnection) {
    let loop = try! SelectorEventLoop(selector: try! KqueueSelector())
    let server = DefaultHTTPServer(eventLoop: loop, port: 4934) {
        (
            environ: [String: Any],
            startResponse: @escaping ((String, [(String, String)]) -> Void),
            sendBody: @escaping ((Data) -> Void)
        ) in
        
        let sendStatus = { (status: Int, statusText: String) in
            startResponse("\(status) \(statusText)", [])
            sendBody(Data())
        }
        
        let sendSuccess = { () in
            sendStatus(200, "OK")
        }
        
        if environ["REQUEST_METHOD"] as? String != "POST"  {
            sendStatus(404, "Not found")
            return
        }
        
        let path = environ["PATH_INFO"] as! String
        
        guard let treadmill = bleConnection.device else {
            sendStatus(428, "Treadmill not connected")
            return
        }
        
        if (path == "/treadmill/stop") {
            treadmill.stop()
            sendSuccess()
        }
        
        if (path == "/treadmill/start") {
            treadmill.start()
            sendSuccess()
        }
        
        if (path == "/treadmill/pause") {
            treadmill.pause()
            sendSuccess()
        }
        
        let speedRegex = try! NSRegularExpression(pattern: "/treadmill/speed/([1-8]0)")
        guard let match = speedRegex.firstMatch(in: path, options: [], range: NSRange(path.startIndex..., in: path)) else {
            sendStatus(404, "Not found")
            return
        }
        
        let range = Range(match.range(at: 1), in: path)!
        let speedMatch = path[range]
        let speed = UInt8(speedMatch)!
        treadmill.setSpeed(speed: speed)
    
        sendSuccess()
        sendBody(Data())
    }

    // Start HTTP server to listen on the port
    try! server.start()

    // Run event loop
    loop.runForever()
}
