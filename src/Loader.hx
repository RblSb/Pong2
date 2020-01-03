package;

import kha.Font;
import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.System;
import kha.Assets;
import khm.Screen;

typedef Save = {
	version:Int,
	?touchMode:Bool,
	?lang:String
}

class Loader {

	public static var defFont:Font;
	public static var defFontSize:Int;

	public function new() {}

	public function init():Void {
		Assets.loadFont(Assets.fonts.Bulgaria_Fantastica_CyrName, (font:Font) -> {
			defFont = font;
			final screenW = System.windowWidth();
			final screenH = System.windowHeight();
			final min = Math.min(screenW, screenH);
			defFontSize = Std.int(min / 20);
			System.notifyOnFrames(onRender);

			function loadFilter(asset:Dynamic):Bool {
				return true;
			}
			function uncompressFilter(asset:Dynamic):Bool {
				if (asset.name.indexOf("music_") != -1) return false;
				return true;
			}
			Assets.loadEverything(loadComplete, loadFilter, uncompressFilter);
		});
	}

	public function loadComplete():Void {
		System.removeFramesListener(onRender);
		Screen.init();

		#if kha_html5
		final nav = js.Browser.window.location.hash.substr(1);
		switch (nav) {
			// case "editor":
			// 	final file = Assets.blobs.tileset_json;
			// 	final tileset = new khm.tilemap.Tileset(file);
			// 	final editor = new khm.editor.Editor(tileset);
			// 	editor.show();
			// 	editor.init();
			case "game":
				newGame();
			default:
				newMenu();
		}
		#else
		newMenu();
		#end
	}

	function newGame():Void {
		final game = new game.Game();
		game.show();
		game.init();
	}

	function newMenu():Void {
		final menu = new game.Menu();
		menu.show();
		menu.init();
	}

	function onRender(fbs:Array<Framebuffer>):Void {
		final g = fbs[0].g2;
		g.begin(true, 0xFF000000);
		final screenW = System.windowWidth();
		final screenH = System.windowHeight();
		g.color = 0xFFFFFFFF;
		g.fontSize = defFontSize * 5;
		g.font = defFont;
		// final s = "Loasing... " + Std.int(Assets.progress * 100) + "%";
		final s = "" + Std.int(Assets.progress * 100);
		final w = g.font.width(g.fontSize, s);
		final h = g.font.height(g.fontSize);
		g.drawString(s, screenW / 2 - w / 2, screenH / 2 - h / 2);
		g.end();
	}

}
