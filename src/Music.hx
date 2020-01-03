package;

import kha.Sound;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;

class Music {

	public static var isEnabled = true;
	public static var volume(default, null) = 1.0;
	static var channel:AudioChannel;

	public static function play(sound:Sound, loop = false):Void {
		if (!isEnabled) return;
		if (sound == null) return;
		stop();
		if (sound.uncompressedData != null) {
			trace("music is uncompressed");
			channel = Audio.play(sound, loop);
		} else {
			channel = Audio.stream(sound, loop);
		}
		setVolume(volume);
	}

	public static function setVolume(value:Float):Void {
		volume = value;
		isEnabled = volume > 0;
		if (channel == null) return;
		channel.volume = value;
	}

	public static function getPosition():Float {
		if (channel == null) return 0.0;
		return channel.position;
	}

	public static function setPosition(seconds:Float):Void {
		if (channel == null) return;
		#if !kha_html5
		channel.pause();
		#end
		channel.position = seconds;
		if (!isEnabled) return;
		channel.play();
	}

	public static function stop():Void {
		if (channel == null) return;
		channel.pause();
		channel.stop();
	}

}
