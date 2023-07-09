struct ApplicationConfiguration{
    let _serverConfiguration:(String,Int) = ("",0)
    func getServerConfiguration()->(String,Int){
        return self._serverConfiguration
    }
}
class Application{
    private var _configuration: ApplicationConfiguration?
    private let _httpServer :HTTPServer
    init(configuration:ApplicationConfiguration? = nil){
        guard let configuration = configuration else{
            self._httpServer = HTTPServer()            
            return  
        }    
        self._configuration = configuration
        self._httpServer = HTTPServer(self._configuration!.getServerConfiguration())        
    }
    func run(){        
        self._httpServer.listen()
    }
}