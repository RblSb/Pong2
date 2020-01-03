package game;

import kha.graphics2.Graphics;
import haxe.Timer;
import kha.Assets;
import kha.input.KeyCode;
import kha.Canvas;
import khm.Screen;
using kha.graphics2.GraphicsExtension;

class LoseScreen extends Screen {

	final isWin:Bool;
	final text = "LOSER";
	var showScore = false;
	var keysDisabled = false;

	public function new(isWin = false) {
		this.isWin = isWin;
		keysDisabled = isWin;
		super();
	}

	public function init():Void {
		Music.stop();
		if (isWin) Sound.play(Assets.sounds.sounds_win);
		else Sound.play(Assets.sounds.sounds_loser, 0.5);
		if (isWin) Timer.delay(scoreScreen, 4000);
	}

	function scoreScreen():Void {
		keysDisabled = false;
		showScore = !showScore;
		Timer.delay(scoreScreen, 2000);
	}

	override function onRender(frame:Canvas) {
		final g = frame.g2;
		g.begin(true, 0xff000000);

		g.color = 0xFFC42C36;
		g.fontSize = Loader.defFontSize * 5;
		g.font = Loader.defFont;
		if (!showScore) drawTitle(g);
		else {
			var offY = 0.0;
			if (isWin) {
				final h = g.font.height(g.fontSize);
				offY = h;
				g.color = 0xFF7BCF5C;
				g.drawAlignedString("SCORE:", Screen.w / 2, Screen.h / 2 - h / 2, TextCenter, TextMiddle);
				offY = h / 2;
			}
			final text = '${Game.playerScore}';
			g.drawAlignedString(text, Screen.w / 2, Screen.h / 2 + offY, TextCenter, TextMiddle);
		}
		g.end();
	}

	function drawTitle(g:Graphics):Void {
		var offY = 0.0;
		if (isWin) {
			final h = g.font.height(g.fontSize);
			offY = h;
			g.color = 0xFF7BCF5C;
			g.drawAlignedString("NOT", Screen.w / 2, Screen.h / 2 - h / 2, TextCenter, TextMiddle);
			offY = h / 2;
		}
		g.drawAlignedString(text, Screen.w / 2, Screen.h / 2 + offY, TextCenter, TextMiddle);
	}

	override function onMouseDown(p:Pointer) newGame();
	override function onKeyDown(key:KeyCode) newGame();

	function newGame():Void {
		if (keysDisabled) return;
		if (isWin) {
			final game = new Menu();
			game.show();
			game.init();
			return;
		}
		final game = new Game();
		game.show();
		game.init();
	}

}
