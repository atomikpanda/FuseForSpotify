//
//  FuseUITests.swift
//  FuseUITests
//
//  Created by Bailey Seymour on 11/13/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import XCTest

class FuseUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        snapshot("04Playlists", timeWaitingForIdle: 2)
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["52 Tracks"]/*[[".cells.staticTexts[\"52 Tracks\"]",".staticTexts[\"52 Tracks\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("03Tracks", timeWaitingForIdle: 2)
        app.navigationBars["Fuse.PlaylistView"].buttons["statsIcon"].tap()
        snapshot("01Stats", timeWaitingForIdle: 2)
        app.navigationBars["FSOE & Uplifting Stats"].buttons["Playlist"].tap()
        app.toolbars["Toolbar"].buttons["operationIcon"].tap()
        app.staticTexts["Intersect"].tap()
        app.buttons["Choose Playlist..."].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Best of 2018"]/*[[".cells.staticTexts[\"Best of 2018\"]",".staticTexts[\"Best of 2018\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Select Playlist"].buttons["Done"].tap()
        snapshot("02Operations", timeWaitingForIdle: 2)
                // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
