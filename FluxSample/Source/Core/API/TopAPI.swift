//
//  TopAPI.swift
//  FluxSample
//
//  Created by RN-079 on 2017/05/01.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import RxSwift
import Alamofire
import Himotoki

struct TopAPI {
    static func getTopInfos(_ hasMore: Bool) -> Observable<RecordsResponse<TopInfo>> {
        var page = 0
        
        if (hasMore) {
            page = 1
        }
        
        let params = ["count": count, "page": page]
        let url = URL(string: topPath)!
        
        print("params = \(params)")
        
        let observable = Observable<RecordsResponse<TopInfo>>.create { observer -> Disposable in
            Alamofire.request(url, method: .get, parameters: params).responseJSON(completionHandler: { response in
                if let error = response.error {
                    observer.onError(error)
                    return
                }
                
                guard let result = response.result.value as? NSArray else {
                    let castError = NSError(domain: "fail to cast JSON", code: 1, userInfo: nil)
                    observer.onError(castError)
                    return
                }
                
                var records = [TopInfo]()
                do {
                    records = try decodeArray(result)
                } catch {
                    let decodeError = NSError(domain: "fail to decodeArray result", code: 1, userInfo: nil)
                    observer.onError(decodeError)
                    return
                }
                
                let recordResponse = RecordsResponse(records: records)
                observer.onNext(recordResponse)
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
        
        return observable.take(1)
    }

}
