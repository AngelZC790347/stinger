# stinger

This is a minimal swift web framwork like flask or express


## Set up 
if you are in macos or linux
```
swift run 
```
if you are in windows you can use docker
```
cd <path to your project>
```
```
docker build -t stinger .
```
```
docker run -p 3000:3000 stinger
```
then you can go to http://localhost:3000

Then go to stinger.swift

modify the port if 3000 is unviavle in the stinger.swift
```swift
 try app.listen(config:ApplicationConfiguration(addr: .Bind(host: "0.0.0.0", port: 3000)))
 ```

add more routes like this
```swift
let app = Application()
app.router.get("/") { req in
    Response(resposeType: .text, body: .init(string: "Hello stinger"))
}
```

