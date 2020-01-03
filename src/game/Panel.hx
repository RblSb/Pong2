package game;

import khm.Screen;
import kha.graphics2.Graphics;
import kha.Color;
import khm.Types.Point;

class Panel {

	final game:Game;
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var w(default, null):Int;
	public var h(default, null):Int;
	public var color(default, null):Color;
	final speed:Point;

	public function new(game:Game, x:Float, y:Float, w:Int, h:Int, color:Color) {
		this.game = game;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.speed = {x: 0, y: 0};
		this.color = color;
	}

	public function damage():Void {}

	public function update():Void {
		x += speed.x;
		y += speed.y;
		if (x < 0) x = 0;
		if (y < 0) y = 0;
		if (x + w > Screen.w) x = Screen.w - w;
		if (y + h > Screen.h) y = Screen.h - h;
	}

	public function render(g:Graphics):Void {
		g.color = color;
		g.fillRect(x, y, w, h);
	}

}
