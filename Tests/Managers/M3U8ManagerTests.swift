//
//  M3U8ManagerTests.swift
//  SwiftyM3U8Tests
//
//  Created by Gal Orlanczyk on 13/11/2017.
//  Copyright © 2017 Kaltura. All rights reserved.
//

import XCTest
@testable import GoSwiftyM3U8

class M3U8ManagerTests: XCTestCase {
    
    class MockPlaylistFetcher: PlaylistFetcher {

        func fetchPlaylist(from url: URL, timeoutInterval: TimeInterval) -> Result<String> {
            do {
                let playlist = try String.init(contentsOf: url)
                return .success(playlist)
            } catch {
                return .failure(error)
            }
            
        }
        
        func fetchPlaylist(from url: URL, timeoutInterval: TimeInterval, completionHandler: @escaping (Result<String>) -> Void) {
            do {
                let playlist = try String.init(contentsOf: url)
                completionHandler(.success(playlist))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    func testManagerFetchSingleMasterPlaylist() {
        let exp = expectation(description: "async expectation")
        let playlistFetcher = MockPlaylistFetcher()
        let manager = M3U8Manager()
        let params = PlaylistOperation.Params(fetcher: playlistFetcher, url: TestsHelper.masterPlaylistUrl, playlistType: .master)
        let parserExtraParams = M3U8Parser.ExtraParams(customRequiredTags: nil, extraTypes: nil, linePostProcessHandler: nil)
        let extraParams = PlaylistOperation.ExtraParams(parser: parserExtraParams)
        let operationData = M3U8Manager.PlaylistOperationData(params: params, extraParams: extraParams)
        manager.fetchAndParsePlaylist(from: operationData, playlistType: MasterPlaylist.self) { (result) in
            switch result {
            case .success(let masterPlaylist):
                TestsHelper.masterPlaylistTest(masterPlaylist: masterPlaylist)
                exp.fulfill()
            case .failure(let error): XCTFail("fetch failed with error: \(String(describing: error))")
            case .cancelled: XCTFail("fetch was cancelled")
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testManagerFetchMultiplePlaylists() {
        let exp = expectation(description: "async expectation")
        let playlistFetcher = MockPlaylistFetcher()
        let manager = M3U8Manager()
        let params = PlaylistOperation.Params(fetcher: playlistFetcher, url: TestsHelper.audioPlaylistUrl, playlistType: .audio)
        let parserExtraParams = M3U8Parser.ExtraParams(customRequiredTags: nil, extraTypes: nil, linePostProcessHandler: nil)
        let extraParams = PlaylistOperation.ExtraParams(parser: parserExtraParams)
        let operationData = M3U8Manager.PlaylistOperationData(params: params, extraParams: extraParams)
        let operationsData = [operationData, operationData]
        manager.fetchAndParseMediaPlaylists(from: operationsData) { (result) in
            switch result {
            case .success(let playlists):
                XCTAssertEqual(playlists.count, operationsData.count)
                for mediaPlaylist in playlists {
                    XCTAssertEqual(mediaPlaylist.tags.versionTag?.value, 3)
                    XCTAssertEqual(mediaPlaylist.tags.targetDurationTag.value, 6)
                    XCTAssertEqual(mediaPlaylist.tags.playlistTypeTag?.value, .vod)
                    XCTAssertEqual(mediaPlaylist.tags.mediaSegments.count, 101)
                    XCTAssertEqual(mediaPlaylist.tags.mediaSegments.first?.value, 5.99467)
                    XCTAssertEqual(mediaPlaylist.tags.mediaSegments.first?.uri, "fileSequence0.aac")
                    XCTAssertEqual(mediaPlaylist.tags.mediaSegments.last?.uri, "fileSequence100.aac")
                }
                exp.fulfill()
            case .failure(let error): XCTFail("fetch failed with error: \(String(describing: error))")
            case .cancelled: XCTFail("fetch was cancelled")
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testManagerFetchSingleMasterPlaylistCancelation() {
        let exp = expectation(description: "async expectation")
        let playlistFetcher = MockPlaylistFetcher()
        let manager = M3U8Manager()
        let params = PlaylistOperation.Params(fetcher: playlistFetcher, url: TestsHelper.masterPlaylistUrl, playlistType: .master)
        let parserExtraParams = M3U8Parser.ExtraParams(customRequiredTags: nil, extraTypes: nil, linePostProcessHandler: nil)
        let extraParams = PlaylistOperation.ExtraParams(parser: parserExtraParams)
        let operationData = M3U8Manager.PlaylistOperationData(params: params, extraParams: extraParams)
        manager.fetchAndParsePlaylist(from: operationData, playlistType: MasterPlaylist.self) { (result) in
            switch result {
            case .success(_): XCTFail("fetch should be cancelled")
            case .failure(_): XCTFail("fetch should be cancelled")
            case .cancelled: break
            }
            exp.fulfill()
        }
        manager.cancel()
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testManagerFetchMultiplePlaylistsCancelation() {
        let exp = expectation(description: "async expectation")
        let playlistFetcher = MockPlaylistFetcher()
        let manager = M3U8Manager()
        let params = PlaylistOperation.Params(fetcher: playlistFetcher, url: TestsHelper.audioPlaylistUrl, playlistType: .audio)
        let parserExtraParams = M3U8Parser.ExtraParams(customRequiredTags: nil, extraTypes: nil, linePostProcessHandler: nil)
        let extraParams = PlaylistOperation.ExtraParams(parser: parserExtraParams)
        let operationData = M3U8Manager.PlaylistOperationData(params: params, extraParams: extraParams)
        manager.fetchAndParseMediaPlaylists(from: [operationData, operationData]) { (result) in
            switch result {
            case .success(_): XCTFail("fetch should be cancelled")
            case .failure(_): XCTFail("fetch should be cancelled")
            case .cancelled: break
            }
            exp.fulfill()
        }
        manager.cancel()
        waitForExpectations(timeout: 10, handler: nil)
    }
}
