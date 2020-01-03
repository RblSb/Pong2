package;

import kha.System;
import kha.Window;
import khm.Macro;
#if kha_html5
import kha.Macros;
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
#end

class Main {

	static function main():Void {
		#if debug
		#if hotml new hotml.client.Client(); #end
		#end
		#if (kha_html5 && !hotml)
		haxe.Log.trace(Macro.getBuildTime());
		#end
		setFullWindowCanvas();
		System.start({title: Macro.getDefine("kha_project_name"), width: 800, height: 600}, init);
	}

	static function init(window:Window):Void {
		#if kha_debug_html5
		untyped {
			require('electron').remote.BrowserWindow.getAllWindows()[0].setBounds({
				x: 0, y: 0, width: 275, height: 294
			});
		}
		#end
		final loader = new Loader();
		loader.init();
	}

	static function setFullWindowCanvas():Void {
		#if kha_html5
		// make html5 canvas resizable
		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.body.style.padding = "0";
		document.body.style.margin = "0";
		final canvas:CanvasElement = cast document.getElementById(Macros.canvasId());
		canvas.style.display = "block";

		final resize = function() {
			canvas.width = Std.int(window.innerWidth * window.devicePixelRatio);
			canvas.height = Std.int(window.innerHeight * window.devicePixelRatio);
			canvas.style.width = document.documentElement.clientWidth + "px";
			canvas.style.height = document.documentElement.clientHeight + "px";
		}
		window.onresize = resize;
		resize();
		#end
	}

}
