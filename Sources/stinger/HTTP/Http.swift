import NIOHTTP1

extension HTTPMethod:CaseIterable,Hashable{
    public static var allCases: [NIOHTTP1.HTTPMethod] {
        return [.GET,.POST,.PUT,.PATCH,.DELETE]
    }
}
