import Foundation

@main
public struct stinger {
    public static func main(){
        do{
            var app = Application()
            var userRouter = Router()
            userRouter.get("/") { req in
                Response(resposeType: .text, body: .init(string: "Hola Angel"))
            }
            userRouter.get("/test") { req in
                Response(resposeType: .text, body: .init(string: "Hola Test2"))
            }
            app.use("users",router: userRouter)
            app.get("/") { req in
                Response(resposeType: .text, body: .init(string: "Hello stinger"))
            }
            app.get("/test") { req in
                Response(resposeType: .text, body: .init(string: "Hola mundo"))
            }
            app.get("/users/{user}") { req in
                let response = Response(resposeType: .text, body: .init(string: String(format: "Hello %@", req.parameter["user"] ?? "World")))
                return response
            }
            
            try app.listen(config:ApplicationConfiguration(addr: .Bind(host: "0.0.0.0", port: 3000)))
            
        }catch{
            print(error.localizedDescription)
            exit(1)
        }
        
    }    
}
