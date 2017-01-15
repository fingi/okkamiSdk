//
//  RCTOkkamiMain.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 12/29/16.
//  Copyright © 2016 michaelabadi.com. All rights reserved.
//
import UIKit
import Foundation
import Moya
import Moya_ModelMapper
import Mapper
import RxSwift
import RxCocoa

struct Repository: Mappable {
    
    let identifier: Int
    let language: String
    let name: String
    let fullName: String
    
    init(map: Mapper) throws {
        try identifier = map.from("id")
        try language = map.from("language")
        try name = map.from("name")
        try fullName = map.from("full_name")
    }
}

struct Issue: Mappable {
    
    let identifier: Int
    let number: Int
    let title: String
    let body: String
    
    init(map: Mapper) throws {
        try identifier = map.from("id")
        try number = map.from("number")
        try title = map.from("title")
        try body = map.from("body")
    }
}
@objc public class RCTOkkamiMain: NSObject {
    
    let disposeBag = DisposeBag()
    let items =  Variable([String]())
    var data = [String]()
    var provider: RxMoyaProvider<GitHub>!
    var issueTrackerModel: IssueTrackerModel!
    
    /*var latestRepositoryName: Observable<String> {
        return
            searchBar
            .rx_text
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }*/
    
    
    public class func newInstance() -> RCTOkkamiMain {
        return RCTOkkamiMain()
    }
    
    public func hello() {
        print("hello world")
    }
    
    public func setupRx() {
        // First part of the puzzle, create our Provider
        provider = RxMoyaProvider<GitHub>()
        
        // Now we will setup our model
        //issueTrackerModel = IssueTrackerModel(provider: provider, repositoryName: latestRepositoryName)
        
        provider.request(.Calendar).subscribe { event in
            switch event {
            case let .next(response):
//                data.append(response.data)
                print(response.data)
            case let .error(error):
                print(error)
            default:
                break
            }
        }
        
    }
    
    /*public func testEvent( eventName: String ) {
        self.bridge.eventDispatcher.sendAppEventWithName( eventName, body: "Woot!" )
    }*/

}
