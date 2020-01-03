package;

import kha.Sound as Snd;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;

class Sound {

	public static var soundVolume = 1.0;

	public static function play(sound:Snd, loop = false, volume = 1.0):Void {
		volume *= soundVolume;
		if (volume == 0) return;
		var channel:AudioChannel;
		if (sound.uncompressedData != null) {
			channel = Audio.play(sound, loop);
		} else {
			trace("sound is compressed");
			channel = Audio.stream(sound, loop);
		}
		channel.volume = volume;
	}

}

