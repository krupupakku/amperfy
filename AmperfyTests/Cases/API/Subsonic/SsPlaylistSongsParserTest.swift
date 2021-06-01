import XCTest
@testable import Amperfy

class SsPlaylistSongsParserTest: AbstractSsParserTest {
    
    var playlist: Playlist!
    var createdSongCount = 0
    
    override func setUp() {
        super.setUp()
        xmlData = getTestFileData(name: "playlist_example_1")
        playlist = library.createPlaylist()
        recreateParserDelegate()
        createTestArtists()
        createTestAlbums()
    }
    
    override func recreateParserDelegate() {
        ssParserDelegate = SsPlaylistSongsParserDelegate(playlist: playlist, libraryStorage: library, syncWave: syncWave, subsonicUrlCreator: subsonicUrlCreator)
    }

    func createTestArtists() {
        var artist = library.createArtist()
        artist.id = "45"
        artist.name = "Brad Sucks"
        
        artist = library.createArtist()
        artist.id = "54"
        artist.name = "PeerGynt Lobogris"
    }
    
    func createTestAlbums() {
        var album = library.createAlbum()
        album.id = "58"
        album.name = "I Don't Know What I'm Doing"
        
        album = library.createAlbum()
        album.id = "68"
        album.name = "Between two worlds"
    }
    
    func testPlaylistContainsBeforeLessSongsThenAfter() {
        for i in 1...3 {
            let song = library.createSong()
            song.id = i.description
            song.title = i.description
            playlist.append(song: song)
        }
        createdSongCount = 3
        recreateParserDelegate()
        testParsing()
    }
    
    func testPlaylistContainsBeforeSameSongCountThenAfter() {
        for i in 1...6 {
            let song = library.createSong()
            song.id = i.description
            song.title = i.description
            playlist.append(song: song)
        }
        createdSongCount = 6
        recreateParserDelegate()
        testParsing()
    }
    
    func testPlaylistContainsBeforeMoreSongsThenAfter() {
        for i in 1...20 {
            let song = library.createSong()
            song.id = i.description
            song.title = i.description
            playlist.append(song: song)
        }
        createdSongCount = 20
        recreateParserDelegate()
        testParsing()
    }
    
    override func checkCorrectParsing() {
        library.saveContext()
        XCTAssertEqual(playlist.songs.count, 6)
        XCTAssertEqual(playlist.songs[0].id, "657")
        XCTAssertEqual(playlist.songs[1].id, "823")
        XCTAssertEqual(playlist.songs[2].id, "748")
        XCTAssertEqual(playlist.songs[3].id, "848")
        XCTAssertEqual(playlist.songs[4].id, "884")
        XCTAssertEqual(playlist.songs[5].id, "805")
        
        XCTAssertEqual(library.songCount, 6+createdSongCount)
        
        var song = playlist.songs[0]
        XCTAssertEqual(song.id, "657")
        XCTAssertEqual(song.title, "Making Me Nervous")
        XCTAssertEqual(song.artist?.id, "45")
        XCTAssertEqual(song.artist?.name, "Brad Sucks")
        XCTAssertEqual(song.album?.id, "58")
        XCTAssertEqual(song.album?.name, "I Don't Know What I'm Doing")
        XCTAssertNil(song.disk)
        XCTAssertEqual(song.track, 1)
        XCTAssertNil(song.genre)
        XCTAssertEqual(song.duration, 159)
        XCTAssertEqual(song.year, 2003)
        XCTAssertEqual(song.bitrate, 202000)
        XCTAssertEqual(song.contentType, "audio/mpeg")
        XCTAssertNil(song.url)
        XCTAssertEqual(song.size, 4060113)
        XCTAssertEqual(song.artwork?.url, "")
        
        song = playlist.songs[2]
        XCTAssertEqual(song.id, "748")
        XCTAssertEqual(song.title, "Stories from Emona II")
        XCTAssertNil(song.artist) // artist not pre created
        XCTAssertEqual(song.album?.id, "68")
        XCTAssertEqual(song.album?.name, "Between two worlds")
        XCTAssertEqual(song.track, 2)
        XCTAssertEqual(song.genre?.id, "")
        XCTAssertEqual(song.genre?.name, "Classical")
        XCTAssertEqual(song.duration, 335)
        XCTAssertEqual(song.year, 2008)
        XCTAssertEqual(song.bitrate, 176000)
        XCTAssertEqual(song.contentType, "audio/mpeg")
        XCTAssertNil(song.url)
        XCTAssertEqual(song.size, 7458214)
        XCTAssertEqual(song.artwork?.url, "")
        
        song = playlist.songs[5]
        XCTAssertEqual(song.id, "805")
        XCTAssertEqual(song.title, "Bajo siete lunas (intro)")
        XCTAssertEqual(song.artist?.id, "54")
        XCTAssertEqual(song.artist?.name, "PeerGynt Lobogris")
        XCTAssertNil(song.album) // Album not pre created
        XCTAssertEqual(song.track, 1)
        XCTAssertEqual(song.genre?.id, "")
        XCTAssertEqual(song.genre?.name, "Blues")
        XCTAssertEqual(song.duration, 117)
        XCTAssertEqual(song.year, 2008)
        XCTAssertEqual(song.bitrate, 225000)
        XCTAssertEqual(song.contentType, "audio/mpeg")
        XCTAssertNil(song.url)
        XCTAssertEqual(song.size, 3363271)
        XCTAssertEqual(song.artwork?.url, "783")
    }

}
