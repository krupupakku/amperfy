import XCTest
@testable import Amperfy

class PlayerDataTest: XCTestCase {
    
    var cdHelper: CoreDataHelper!
    var library: LibraryStorage!
    var testPlayer: PlayerData!
    var testNormalPlaylist: Playlist!
    var testShuffledPlaylist: Playlist!
    let fillCount = 5

    override func setUp() {
        cdHelper = CoreDataHelper()
        library = cdHelper.createSeededStorage()
        testPlayer = library.getPlayerData()
        testPlayer.isShuffle = true
        testShuffledPlaylist = testPlayer.contextQueue
        testPlayer.isShuffle = false
        testNormalPlaylist = testPlayer.contextQueue
    }

    override func tearDown() {
    }
    
    func fillPlayerWithSomeSongs() {
        for i in 0...fillCount-1 {
            guard let song = library.getSong(id: cdHelper.seeder.songs[i].id) else { XCTFail(); return }
            testPlayer.appendContextQueue(playables: [song])
        }
    }
    
    func checkCorrectDefaultPlaylist() {
        for i in 0...fillCount-1 {
            checkPlaylistIndexEqualSeedIndex(playlistIndex: i, seedIndex: i)
        }
    }
    
    func checkPlaylistIndexEqualSeedIndex(playlistIndex: Int, seedIndex: Int) {
        guard let song = library.getSong(id: cdHelper.seeder.songs[seedIndex].id) else { XCTFail(); return }
        XCTAssertEqual(testPlayer.contextQueue.playables[playlistIndex].id, song.id)
    }
    
    func testCreation() {
        XCTAssertNotEqual(testNormalPlaylist, testShuffledPlaylist)
        XCTAssertEqual(testPlayer.contextQueue, testNormalPlaylist)
        XCTAssertEqual(testPlayer.currentItem, nil)
        XCTAssertFalse(testPlayer.isShuffle)
        XCTAssertEqual(testPlayer.repeatMode, RepeatMode.off)
        XCTAssertEqual(testPlayer.currentIndex, 0)
        XCTAssertEqual(testNormalPlaylist.playables.count, 0)
        XCTAssertEqual(testShuffledPlaylist.playables.count, 0)
    }
    
    func testPlaylist() {
        fillPlayerWithSomeSongs()
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount)
        checkCorrectDefaultPlaylist()
    }
    
    func testCurrentSong() {
        fillPlayerWithSomeSongs()
        
        for i in [3,2,4,1,0] {
            guard let song = library.getSong(id: cdHelper.seeder.songs[i].id) else { XCTFail(); return }
            testPlayer.currentIndex = i
            XCTAssertEqual(testPlayer.currentItem?.id, song.id)
        }
    }
    
    func testShuffle() {
        testPlayer.isShuffle = true
        XCTAssertTrue(testPlayer.isShuffle)
        XCTAssertEqual(testPlayer.contextQueue, testShuffledPlaylist)
        testPlayer.isShuffle = false
        XCTAssertFalse(testPlayer.isShuffle)
        XCTAssertEqual(testPlayer.contextQueue, testNormalPlaylist)
        testPlayer.isShuffle = true
        XCTAssertEqual(testPlayer.contextQueue, testShuffledPlaylist)
        
        fillPlayerWithSomeSongs()
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount)
        testPlayer.isShuffle = false
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount)
        checkCorrectDefaultPlaylist()
        testPlayer.isShuffle = true
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount)
        testPlayer.isShuffle = false
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount)
        checkCorrectDefaultPlaylist()
        testPlayer.isShuffle = true
    }
    
    func testRepeat() {
        testPlayer.repeatMode = RepeatMode.all
        XCTAssertEqual(testPlayer.repeatMode, RepeatMode.all)
        testPlayer.repeatMode = RepeatMode.single
        XCTAssertEqual(testPlayer.repeatMode, RepeatMode.single)
        testPlayer.repeatMode = RepeatMode.off
        XCTAssertEqual(testPlayer.repeatMode, RepeatMode.off)
    }
    
    func testCurrentSongIndexSet() {
        fillPlayerWithSomeSongs()
        let curIndex = 2
        testPlayer.currentIndex = curIndex
        XCTAssertEqual(testPlayer.currentIndex, curIndex)
        testPlayer.currentIndex = -1
        XCTAssertEqual(testPlayer.currentIndex, 0)
        testPlayer.currentIndex = -2
        XCTAssertEqual(testPlayer.currentIndex, 0)
        testPlayer.isUserQueuePlaying = true
        testPlayer.currentIndex = -1
        XCTAssertEqual(testPlayer.currentIndex, -1)
        testPlayer.currentIndex = -2
        XCTAssertEqual(testPlayer.currentIndex, -1)
        testPlayer.isUserQueuePlaying = false
        testPlayer.currentIndex = -10
        XCTAssertEqual(testPlayer.currentIndex, 0)
        testPlayer.currentIndex = fillCount-1
        XCTAssertEqual(testPlayer.currentIndex, fillCount-1)
        testPlayer.currentIndex = fillCount
        XCTAssertEqual(testPlayer.currentIndex, 0)
        testPlayer.currentIndex = 100
        XCTAssertEqual(testPlayer.currentIndex, 0)
    }
    
    func testAddToPlaylist() {
        fillPlayerWithSomeSongs()
        guard let song1 = library.getSong(id: cdHelper.seeder.songs[6].id) else { XCTFail(); return }
        guard let song2 = library.getSong(id: cdHelper.seeder.songs[7].id) else { XCTFail(); return }
        testPlayer.appendContextQueue(playables: [song1])
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount + 1)
        testPlayer.isShuffle = true
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount + 1)
        testPlayer.appendContextQueue(playables: [song2])
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount + 2)
        testPlayer.isShuffle = false
        XCTAssertEqual(testPlayer.contextQueue.playables.count, fillCount + 2)
        XCTAssertEqual(testPlayer.contextQueue.playables[fillCount].id, song1.id)
        XCTAssertEqual(testPlayer.contextQueue.playables[fillCount + 1].id, song2.id)
    }
    
    func testRemoveAllSongs() {
        fillPlayerWithSomeSongs()
        testPlayer.currentIndex = 3
        XCTAssertEqual(testPlayer.currentIndex, 3)
        testPlayer.removeAllItems()
        XCTAssertEqual(testPlayer.currentIndex, 0)
        XCTAssertEqual(testPlayer.contextQueue.playables.count, 0)
        
        guard let song1 = library.getSong(id: cdHelper.seeder.songs[6].id) else { XCTFail(); return }
        guard let song2 = library.getSong(id: cdHelper.seeder.songs[7].id) else { XCTFail(); return }
        testPlayer.appendContextQueue(playables: [song1])
        testPlayer.appendContextQueue(playables: [song2])
        testPlayer.removeAllItems()
        XCTAssertEqual(testPlayer.contextQueue.playables.count, 0)
    }

}
