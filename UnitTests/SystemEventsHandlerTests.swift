//
//  SystemEventsHandlerTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 31.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import UIKit
@testable import CountriesSwiftUI

class SystemEventsHandlerTests: XCTestCase {
    
    var sut: RealSystemEventsHandler!

    override func setUp() {
        sut = RealSystemEventsHandler(appState: AppState())
    }

    func test_didBecomeActive() {
        sut.sceneDidBecomeActive()
        let reference = AppState()
        XCTAssertFalse(reference.system.isActive)
        reference.system.isActive = true
        XCTAssertEqual(sut.appState, reference)
    }
    
    func test_willResignActive() {
        sut.sceneDidBecomeActive()
        sut.sceneWillResignActive()
        let reference = AppState()
        XCTAssertEqual(sut.appState, reference)
    }

    func test_openURLContexts_countryDeepLink() {
        let countries = Country.mockedData
        let deepLinkURL = "https://www.example.com/?alpha3code=\(countries[0].alpha3Code)"
        let contexts = UIOpenURLContext.contexts(deepLinkURL)
        XCTAssertNil(sut.appState.routing.countriesList.countryDetails)
        XCTAssertFalse(sut.appState.routing.countryDetails.detailsSheet)
        sut.sceneOpenURLContexts(contexts)
        XCTAssertEqual(sut.appState.routing.countriesList.countryDetails, countries[0].alpha3Code)
        XCTAssertTrue(sut.appState.routing.countryDetails.detailsSheet)
    }
    
    func test_openURLContexts_randomURL() {
        let url1 = "https://www.example.com/link/?param=USD"
        let contexts1 = UIOpenURLContext.contexts(url1)
        let url2 = "https://www.domain.com/test/?alpha3code=USD"
        let contexts2 = UIOpenURLContext.contexts(url2)
        let reference = AppState()
        sut.sceneOpenURLContexts(contexts1)
        XCTAssertEqual(sut.appState, reference)
        sut.sceneOpenURLContexts(contexts2)
        XCTAssertEqual(sut.appState, reference)
    }
    
    func test_openURLContexts_emptyContexts() {
        let reference = AppState()
        sut.sceneOpenURLContexts(Set<UIOpenURLContext>())
        XCTAssertEqual(sut.appState, reference)
    }
}

private extension UIOpenURLContext {
    static func contexts(_ urlString: String) -> Set<UIOpenURLContext> {
        return Set([Test(urlString)])
    }
}

private extension UIOpenURLContext {
    class Test: UIOpenURLContext {
        
        let urlString: String
        override var url: URL { URL(string: urlString)! }
        
        init(_ urlString: String) {
            self.urlString = urlString
        }
    }

}
