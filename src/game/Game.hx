package game;

import haxe.Timer;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.Mouse;
import kha.Canvas;
import khm.Screen;
import khm.Screen.Pointer;
import kha.input.KeyCode;
using kha.graphics2.GraphicsExtension;

enum abstract GameStage(Int) {
	var One;
	var Two;
	var Three;
}

class Game extends Screen {

	public static inline var BLUE = 0xFF0050FF;
	public static inline var RED = 0xFFFF0000;
	static inline var STAGE3 = 3 * 60 + 7;
	static var save = GameStage.One;
	static final timers:Array<Timer> = [];
	static var stageScore = 0;
	public var stage(default, null):GameStage;
	final balls:Array<Ball> = [];
	final panels:Array<Panel> = [];
	var panelW:Int;
	var panelH:Int;
	var ballSize:Int;
	public var extendedBalls(default, null) = false;
	public var moreBalls(default, null) = false;
	public var goingEnd(default, null) = false;
	public var stage3Type(default, null) = -1;
	public var player(default, null):Player;
	public final particler = new Particler();
	public static var leftScore = 0;
	public static var playerScore = 0;
	public static var rightScore = 0;
	var showBorders = true;
	var showScore = true;

	public function init() {
		stage = save;
		// stage = One;
		// stage = Two;
		// stage = Three;
		clearTimers();
		Music.stop();
		if (stage == One && playerScore > 0) {
			leftScore = 0;
			playerScore = 0;
			rightScore = 0;
			stageScore = 0;
		} else playerScore = stageScore;
		final min = Math.min(Screen.w, Screen.h);
		panelW = Std.int(min / 30);
		panelH = Std.int(min / 5);
		ballSize = panelW;
		player = new Player(this, Screen.w / 2 - panelW / 2, Screen.h / 2, panelW, panelH, 0xFF00FF00);
		if (stage != Three) panels.push(new Bot(this, panelW, Screen.h / 2, panelW, panelH, BLUE));
		panels.push(player);
		panels.push(new Bot(this, Screen.w - panelW * 2, Screen.h / 2, panelW, panelH, RED));

		// Music.isEnabled = false;
		Music.isEnabled = true;
		// stageOneToTwo();
		switch (stage) {
			case One:
			case Two:
				Music.play(Assets.sounds.music_Smile);
				Music.setPosition(7.42);
				// Music.setPosition(180.42);
				setStage(Two);
			case Three:
				Music.play(Assets.sounds.music_Smile);
				Music.setPosition(STAGE3);
				// Music.setPosition(STAGE3 + 2 * 60 - 5);
				setStage(Three);
		}
	}

	public function addBall(parent:Panel, x:Int, y:Int, ang:Float):Void {
		final speed = switch (stage) {
			case One: ballSize / 7;
			case Two: ballSize / 12;
			case Three: ballSize / 8;
		}
		final color = switch (stage) {
			case One: 0xFF41F3FC;
			case Two, Three: parent.color;
		}
		balls.push(new Ball(this, parent, x, y, ang, speed, color, ballSize));
	}

	public function removeBall(ball:Ball):Void {
		balls.remove(ball);
	}

	public function removePanel(panel:Panel):Void {
		panels.remove(panel);
	}

	public function explodeAllBalls():Void {
		for (ball in balls) {
			particler.angleArea(Std.int(ball.x), Std.int(ball.y), ball.size, ball.size, 0, Math.PI * 2, {
				x: 0, y: 0,
				color: ball.color,
				lifeTime: 50,
				gravity: {
					x: 0, y: 0
				},
				speed: {
					x: ball.size / 10, y: ball.size / 10
				}
			});
		}
		balls.resize(0);
	}

	public function ballsCount():Int {
		var count = 0;
		for (ball in balls) {
			if (ball.type != Repulsion && ball.type != Heal) count++;
		}
		return count;
	}

	public function hasBasicBall():Bool {
		for (ball in balls) {
			if (ball.type == Basic) return true;
		}
		return false;
	}

	public function getClosestBall(x:Float):Null<Ball> {
		var minBall:Null<Ball> = null;
		var minX:Float = Screen.w;
		for (ball in balls) {
			final dist = Math.abs(ball.x - x);
			if (dist < minX) {
				minX = dist;
				minBall = ball;
			}
		}
		return minBall;
	}

	public function lose():Void {
		clearTimers();
		save = stage;
		final screen = new LoseScreen();
		screen.init();
		screen.show();
	}

	function win():Void {
		clearTimers();
		save = One;
		stage = One;
		final screen = new LoseScreen(true);
		screen.init();
		screen.show();
	}

	public function stageOneToTwo():Void {
		#if debug
		delay(() -> balls.resize(0), 500);
		#end
		playerScore = 1;
		if (player.h != player.w) player.setH(player.w);
		Music.play(Assets.sounds.music_Smile);
		delay(() -> showScore = false, 3250);
		delay(() -> showScore = true, 3300);
		delay(() -> showScore = false, 3350);
		delay(() -> showBorders = false, 5800);
		delay(() -> showBorders = true, 6100);
		delay(() -> showBorders = false, 6350);
		delay(() -> showBorders = true, 6500);
		delay(() -> showBorders = false, 6550);
		delay(() -> {
			showScore = true;
			showBorders = true;
		}, 6800);
		delay(() -> {
			showScore = false;
			showBorders = false;
		}, 6850);
		delay(() -> setStage(Two), 7000);
	}

	public function setStage(value:GameStage):Void {
		stageScore = playerScore;
		switch (value) {
			case One:
			case Two:
				if (player.h != player.w) player.setH(player.w);
				showScore = false;
				showBorders = false;
				extendedBalls = false;
				moreBalls = false;
				goingEnd = false;
				final t = Std.int(Music.getPosition() * 1000);
				delay(() -> extendedBalls = true, 71000 - t);
				delay(() -> moreBalls = true, (2 * 60 + 14) * 1000 - t);
				delay(() -> {
					final bot:Bot = cast panels[0];
					bot.explParticles();
					removePanel(bot);
					explodeAllBalls();
					setStage(Three);
				}, STAGE3 * 1000 - t);
			case Three:
				if (player.h != player.w) player.setH(player.w);
				showScore = false;
				showBorders = false;
				extendedBalls = false;
				moreBalls = false;
				goingEnd = false;
				stage3Type = 0;
				final t = Std.int(Music.getPosition() * 1000);
				delay(() -> stage3Type = 1, (STAGE3 + 40) * 1000 - t);
				delay(() -> stage3Type = 2, (STAGE3 + 72) * 1000 - t);
				delay(() -> goingEnd = true, (STAGE3 + 2 * 60) * 1000 - t);
				delay(() -> {
					if (panels.length != 2) return;
					final bot:Bot = cast panels[1];
					bot.slowDeath();
				}, (STAGE3 + 2 * 60 + 20) * 1000 - t);
				delay(win, (STAGE3 + 2 * 60 + 29) * 1000 - t);
		}
		stage = value;
	}

	inline function delay(fn:()->Void, ms:Int):Void {
		timers.push(Timer.delay(fn, ms));
	}

	function clearTimers():Void {
		for (timer in timers) timer.stop();
		timers.resize(0);
	}

	override function onUpdate():Void {
		for (ball in balls) ball.update(panels);
		for (panel in panels) panel.update();
		particler.update();
	}

	override function onRender(canvas:Canvas):Void {
		final g = canvas.g2;
		g.begin(true, 0xff000000);
		renderBorders(g);

		for (ball in balls) ball.render(g);
		for (panel in panels) panel.render(g);
		particler.render(g, 0, 0);
		for (ball in balls) ball.drawCircle(g);
		renderScore(g);
		g.end();
	}

	function renderBorders(g:Graphics):Void {
		if (!showBorders) return;
		g.color = 0xFF351428;
		g.drawLine(Screen.w / 2 - panelW * 1.5, 0, Screen.w / 2 - panelW * 1.5, Screen.w);
		g.color = 0xFF0F2738;
		g.drawLine(Screen.w / 2 + panelW * 1.5, 0, Screen.w / 2 + panelW * 1.5, Screen.w);
		g.color = 0xFF1A453B;
		g.drawLine(1, 0, 1, Screen.w);
		g.drawLine(Screen.w, 0, Screen.w, Screen.w);
	}

	function renderScore(g:Graphics):Void {
		if (!showScore) {
			leftScore = Std.random(1000000);
			rightScore = Std.random(1000000);
			return;
		}
		g.color = 0xFFFFFFFF;
		g.fontSize = Loader.defFontSize;
		g.font = Loader.defFont;
		g.drawAlignedString('$leftScore', 0, 0, TextLeft, TextTop);
		g.drawAlignedString('$playerScore', Screen.w / 2, 0, TextCenter, TextTop);
		g.drawAlignedString('$rightScore', Screen.w, 0, TextRight, TextTop);
	}

	override function onMouseDown(p:Pointer):Void {
		if (Screen.isTouch) return;
		if (Mouse.get().isLocked()) return;
		//#if !debug
		Mouse.get().lock();
		//#else
		// Mouse.get().hideSystemCursor();
		// Mouse.get().showSystemCursor();
		//#end
	}

	override function onMouseMove(p:Pointer) {
		player.onMouseMove(p);
	}

	override function onKeyDown(key:KeyCode) {
		if (key == Escape) Mouse.get().unlock();
		#if debug
		if (key == One) {
			@:privateAccess balls[0].defSpeed = ballSize;
			@:privateAccess balls[1].defSpeed = ballSize;
		}
		if (key == R) {
			final game = new Game();
			game.show();
			game.init();
		}

		if (key == M) {
			final game = new Menu();
			game.show();
			game.init();
		}

		if (key == L) {
			Music.stop();
			final game = new Loader();
			game.init();
		}
		#end
	}

}
