package game;

import kha.Color;
import kha.Assets;
import kha.graphics2.Graphics;
import khm.Types.Point;
import khm.Screen;

enum AiState {
	Shooting;
	CatchingBall;
	DodgingBall;
	MakingCloneTo(pos:Point);
	Transforming(pos:Point);
	MovingTo(pos:Point);
}

class Bot extends Panel {

	static inline var RELOAD_MAX = 20;
	static inline var RELOAD_MAX2 = 400;
	static inline var DAMAGE_ANIM_MAX = 10;
	var aiState = AiState.Shooting;
	var shotAngle = 0.0;
	var shotReload = RELOAD_MAX;
	var damageAnim = 0;
	var nextY = 0;

	public function new(game:Game, x:Float, y:Float, w:Int, h:Int, color:Color) {
		super(game, x, y, w, h, color);
		switch (game.stage) {
			case One:
			case Two:
				aiState = CatchingBall;
			case Three:
				aiState = DodgingBall;
		}
	}

	override function update() {
		switch (game.stage) {
			case One:
				stageOneLogic();
			case Two, Three:
				stageTwoLogic();
			// case Three:
			// 	stageThreeLogic();
		}
		super.update();
	}

	function stageOneLogic():Void {
		switch (aiState) {
			case Shooting:
				if (shotReload == RELOAD_MAX) {
					shotAngle = Math.atan2(
						Screen.h * Math.random() - (y + h / 2),
						Screen.w / 2 - (x + w / 2)
					);
				}
				shotReload--;
				if (shotReload < 0) {
					shotReload = RELOAD_MAX;
					game.addBall(this, Std.int(x + w / 2), Std.int(y + h / 2), shotAngle);
					Sound.play(Assets.sounds.sounds_hit);
					aiState = CatchingBall;
				}
			case CatchingBall:
				final ball:Null<Ball> = game.getClosestBall(x);
				if (ball == null) return;
				final diff = ball.y + ball.size / 2 - (y + h / 2);
				y += diff / 10;
			case DodgingBall:
			case MakingCloneTo(pos):
			case Transforming(pos):
			case MovingTo(pos):
		}
	}

	function stageTwoLogic():Void {
		switch (aiState) {
			case CatchingBall:
				shotReload = Std.int(RELOAD_MAX * 2);
				final player = game.player;
				shotAngle = Math.atan2(
					player.y + (player.h / 2) - (y + h / 2),
					player.x + (player.w / 2) - (x + w / 2)
				);
				aiState = Shooting;
				setNextRandomPosition();
			case Shooting:
				var time = RELOAD_MAX2 / 2;
				if (game.ballsCount() < 4) time /= 2;
				shotReload = Std.int(time + RELOAD_MAX2 * Math.random());
				if (game.moreBalls) shotReload = Std.int(shotReload / 2);
				game.addBall(this, Std.int(x + w / 2), Std.int(y + h / 2), shotAngle);
				Sound.play(Assets.sounds.sounds_hit);
				aiState = DodgingBall;
			case DodgingBall:
				final diff = nextY - y;
				y += diff / 40;
				if (Math.abs(y - nextY) < 1) setNextRandomPosition();

				final player = game.player;
				shotAngle = Math.atan2(
					player.y + (player.h / 2) - (y + h / 2),
					player.x + (player.w / 2) - (x + w / 2)
				);
				if (shotReload < 0) setShotingState();
				if (game.ballsCount() < 2) {
					if (shotReload > 50) shotReload = 50;
				}
				if (game.stage3Type == 0 && game.ballsCount() > 0) {
					shotReload = RELOAD_MAX + 1;
				}
				if (game.stage3Type == 2 && game.ballsCount() < 3) {
					if (shotReload > 50) shotReload = 50;
				}
			case MakingCloneTo(pos):
			case Transforming(pos):
			case MovingTo(pos):
		}
		shotReload--;
	}

	function setNextRandomPosition():Void {
		nextY = Std.int((Screen.h - h) * Math.random());
	}

	function setShotingState():Void {
		aiState = Shooting;
		final player = game.player;
		shotAngle = Math.atan2(
			player.y + (player.h / 2) - (y + h / 2),
			player.x + (player.w / 2) - (x + w / 2)
		);
	}

	function stageThreeLogic():Void {}

	override function damage() {
		if (game.goingEnd && color == Game.RED) {
			slowDeath();
			return;
		}
		Game.playerScore++;
		damageAnim = DAMAGE_ANIM_MAX;
	}

	public function slowDeath():Void {
		game.removePanel(this);
		game.explodeAllBalls();
		explParticles(true);
		game.setStage(Three);
	}

	public function explParticles(isLong = false):Void {
		final lifeTime = isLong ? 1000 : 200;
		game.particler.angleArea(
			Std.int(x), Std.int(y), w, h,
			0, Math.PI * 2, {
				x: 0, y: 0,
				color: color,
				lifeTime: lifeTime,
				gravity: {
					x: 0, y: 0
				},
				speed: {
					x: 0.5, y: 0.5
				}
			}
		);
	}

	function glow(color:Color, percent:Float):Color {
		final max = 255;
		final r = Std.int(color.Rb + (max - color.Rb) * percent);
		color.Rb = r > max ? max : r;
		final g = Std.int(color.Gb + (max - color.Gb) * percent);
		color.Gb = g > max ? max : g;
		final b = Std.int(color.Bb + (max - color.Bb) * percent);
		color.Bb = b > max ? max : b;
		return color;
	}

	override function render(g:Graphics) {
		var dist = (RELOAD_MAX - shotReload) * 2;
		if (dist > 0) {
			g.color = color;
			g.drawLine(
				x + w / 2 + Math.cos(shotAngle) * w,
				y + h / 2 + Math.sin(shotAngle) * w,
				x + w / 2 + Math.cos(shotAngle) * dist * w / 10,
				y + h / 2 + Math.sin(shotAngle) * dist * w / 10
			);
		}

		if (damageAnim > 0) {
			var percent = (DAMAGE_ANIM_MAX - damageAnim) / DAMAGE_ANIM_MAX;
			percent *= 2;
			if (percent > 1) percent = 2 - percent;
			g.color = glow(color, percent);
			damageAnim--;
		} else g.color = color;
		g.fillRect(x, y, w, h);
	}

}
