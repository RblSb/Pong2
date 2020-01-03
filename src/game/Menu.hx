package game;

import kha.input.Mouse;
import kha.input.KeyCode;
import kha.Canvas;
import khm.Screen;

class Menu extends Screen {

	final logoName = "PONG 2";
	var descText = "CLICK TO START";

	public function init() {}

	override function onMouseLock():Void {
		#if debug
		Mouse.get().unlock();
		#end
		newGame();
	}

	override function onMouseLockError():Void {
		final newText = "CLICK BETTER THIS TIME";
		if (descText != newText) descText = newText;
		else newGame();
	}

	override function onRender(canvas:Canvas):Void {
		final g = canvas.g2;
		g.begin(true, 0xff000000);
		g.color = 0xFFFFFFFF;
		g.fontSize = Loader.defFontSize * 5;
		g.font = Loader.defFont;
		final fontH = g.font.height(g.fontSize);
		final logoW = g.font.width(g.fontSize, logoName);
		g.drawString(logoName, Screen.w / 2 - logoW / 2, Screen.h / 2 - fontH);
		g.fontSize = Loader.defFontSize;
		final descW = g.font.width(g.fontSize, descText);
		g.drawString(descText, Screen.w / 2 - descW / 2, Screen.h / 2);
		g.end();
	}

	override function onMouseDown(p:Pointer):Void {
		if (Screen.isTouch) {
			newGame();
			return;
		}
		if (!Mouse.get().isLocked()) Mouse.get().lock();
		else onMouseLock();
	}

	function newGame():Void {
		final game = new Game();
		game.show();
		game.init();
	}

}
