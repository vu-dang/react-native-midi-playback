package com.reactnativemidiplayback

import android.media.MediaPlayer
import android.net.Uri
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod


class MidiPlaybackModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  private var mediaPlayer: MediaPlayer = MediaPlayer()

  override fun getName(): String {
    return "MidiPlayback"
  }

  // Load a MIDI file. `url` is normally a bundled asset path such as
  // "midi/ode_to_joy.mid" (the host app ships its .mid files under
  // src/main/assets/midi), but a file:// path or content Uri also works.
  // The single MediaPlayer instance is reset and reused for each file.
  @ReactMethod
  fun setPlaybackFile(url: String) {
    try {
      mediaPlayer.reset()
    } catch (e: Exception) {
      e.printStackTrace()
    }
    try {
      val afd = reactApplicationContext.assets.openFd(url)
      mediaPlayer.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
      afd.close()
      mediaPlayer.prepare()
      mediaPlayer.setVolume(1F, 1F)
    } catch (assetError: Exception) {
      // Not a bundled asset — fall back to treating `url` as a Uri / path.
      try {
        mediaPlayer.reset()
        mediaPlayer.setDataSource(reactApplicationContext, Uri.parse(url))
        mediaPlayer.prepare()
        mediaPlayer.setVolume(1F, 1F)
      } catch (uriError: Exception) {
        uriError.printStackTrace()
      }
    }
  }

  @ReactMethod
  fun play() {
    try {
      mediaPlayer.start()
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  @ReactMethod
  fun stop() {
    try {
      if (mediaPlayer.isPlaying) {
        mediaPlayer.stop()
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  @ReactMethod
  fun pause() {
    try {
      if (mediaPlayer.isPlaying) {
        mediaPlayer.pause()
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  @ReactMethod
  fun reset() {
    try {
      mediaPlayer.reset()
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  @ReactMethod(isBlockingSynchronousMethod = true)
  fun isPlaying(): Boolean {
    return try {
      mediaPlayer.isPlaying
    } catch (e: Exception) {
      false
    }
  }

}
