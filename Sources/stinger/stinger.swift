import NIO
import NIOHTTP1
import Foundation

@main
public struct stinger {    
    public static func main(){
        do{
            let app = Application()
            app.router.get("/") { req in
                Response(resposeType: .text, body: .init(string: "Hello stinger"))
            }
            app.router.get("/test") { req in
                Response(resposeType: .text, body: .init(string: "Hola mundo"))
            }
            app.router.get("/users/{Angel}") { req in
                Response(resposeType: .json, body: .init(string: "{username:Angel}"))
            }            
            try app.listen(config:ApplicationConfiguration(addr: .Bind(host: "0.0.0.0", port: 3000)))
            
                        
        }catch{
            print(error.localizedDescription)
            exit(1)
        }
        
    }    
}
