package game;

import khm.Types.Rect;
import khm.utils.Utils;
import kha.Assets;
import khm.Screen;
import kha.graphics2.Graphics;
import kha.Color;
import khm.Types.Point;
import khm.utils.Collision;
using kha.graphics2.GraphicsExtension;
using khm.utils.MathExtension;

enum BallType {
	Basic;
	Heal;
	Repulsion;
	Explosive;
	LaserLines;
}

class Ball {

	static inline var EXPL_MAX = 60 * 5;
	static inline var EXPL_DIST = 7;
	final game:Game;
	var parent:Panel;
	public var x(default, null):Float;
	public var y(default, null):Float;
	public final speed:Point;
	var defSpeed:Float;
	public final color:Color;
	public final size:Int;
	public final type = BallType.Basic;
	var glowAnimMax = 60;
	var glowAnim = 0;
	var explTimer = -1;

	public function new(game:Game, parent:Panel, x:Float, y:Float, ang:Float, speed:Float, color:Color, size:Int) {
		this.game = game;
		this.parent = parent;
		this.x = x;
		this.y = y;
		defSpeed = speed;
		this.speed = {
			x: defSpeed * Math.cos(ang),
			y: defSpeed * Math.sin(ang)
		}
		this.color = color;
		this.size = size;
		switch (game.stage) {
			case One:
			case Two:
				final player = game.player;
				final diff = Player.MAX_HP - player.hp;
				if (diff > 0) {
					if (Std.random(15 - diff) == 0) {
						type = Heal;
					}
				}
				if (type != Heal && game.extendedBalls) {
					if (!game.moreBalls || Std.random(2) == 0) {
						type = Std.random(15) == 0 ? Repulsion : Explosive;
						if (game.player.hasRepulsionBonus()) type = Explosive;
					}
				}
			case Three:
				final player = game.player;
				final diff = Player.MAX_HP - player.hp;
				type = LaserLines;
				if (game.stage3Type == 2) {
					if (!game.hasBasicBall()) type = Basic;
					else if (Std.random(2) == 0) type = Explosive;
				}
				if (diff > 0) {
					if (Std.random(15 - diff) == 0) {
						type = Heal;
					}
				}
				if (type != Heal) {
					if (Std.random(15) == 0) {
						type = Repulsion;
						if (game.player.hasRepulsionBonus()) type = LaserLines;
					}
				}
		}
		switch (type) {
			case Basic:
			case Heal:
				this.color = 0xFFE38DD6;
			case Repulsion:
				this.color = 0xFF67708B;
			case Explosive, LaserLines:
				explTimer = EXPL_MAX;
		}
	}

	public function update(panels:Array<Panel>):Void {
		this.x += speed.x;
		this.y += speed.y;

		switch (game.stage) {
			case One:
				stageOneLogic(panels);
			case Two, Three:
				stageTwoLogic(panels);
		}
	}

	function stageOneLogic(panels:Array<Panel>):Void {
		wallCollisionY();

		for (panel in panels) {
			if (panel == parent) continue;
			if (Collision.aabb(
				{x: x, y: y, w: size, h: size},
				{x: panel.x, y: panel.y, w: panel.w, h: panel.h}
			)) {
				Sound.play(Assets.sounds.sounds_hit);
				addParticles();
				parent = panel;
				stageOneSpeedUp(panel);
				break;
			}
		}
		final player = game.player;
		if (parent == panels[0] && x > player.x + player.w * 2) {
			Game.leftScore++;
			game.lose();
		}
		if (parent == panels[2] && x < player.x - player.w * 2) {
			Game.rightScore++;
			game.lose();
		}
		if (parent == game.player && (x < 0 || x > Screen.w)) {
			game.removeBall(this);
			if (game.ballsCount() == 0) {
				game.stageOneToTwo();
			}
		}
	}

	function addParticles():Void {
		var rectX = Std.int(x) + (speed.x > 0 ? size : 0);
		var rectY = Std.int(y);
		var rectW = 2;
		var rectH = size;
		if (y < 0 || y > Screen.h) {
			rectX = Std.int(x);
			rectY = Std.int(y) + (speed.y > 0 ? size : 0);
			rectW = size;
			rectH = 2;
		}

		game.particler.angleArea(rectX, rectY, rectW, rectH, 0, Math.PI * 2, {
			x: 0, y: 0,
			color: color,
			lifeTime: 50,
			gravity: {
				x: 0, y: 0.1
			},
			speed: {
				x: -speed.x * 0.5, y: -speed.y * 0.5
			}
		});
	}

	function stageOneSpeedUp(panel:Panel):Void {
		if (game.player == panel) {
			speed.x = -speed.x;
			final screenX = speed.x > 0 ? Screen.w : 0;
			var ang = Math.atan2(
				Screen.h * Math.random() - (y + size / 2),
				screenX - (x + size / 2)
			);
			speed.x = defSpeed * Math.cos(ang);
			speed.y = defSpeed * Math.sin(ang);
			if (isScriptedSpeed()) {
				var newH = game.player.h - Std.int(game.player.h / 10);
				if (newH < game.player.w) newH = game.player.w;
				game.player.setH(newH);
			}
			return;
		}

		defSpeed += size / 25;
		var ang = Math.atan2(
			Screen.h * Math.random() - (y + size / 2),
			Screen.w / 2 - (x + size / 2)
		);
		if (isScriptedSpeed()) ang = Math.atan2(
			Screen.h / 2 - (y + size / 2),
			Screen.w / 2 - (x + size / 2)
		);
		speed.x = defSpeed * Math.cos(ang);
		speed.y = defSpeed * Math.sin(ang);
	}

	function isScriptedSpeed():Bool {
		return defSpeed > size / 2.5;
	}

	function wallCollisionY():Void {
		if (y < 0 || y > Screen.h) {
			Sound.play(Assets.sounds.sounds_hit);
			addParticles();
			speed.y = -speed.y;
		}
		if (y < 0) y = 0;
		if (y > Screen.h) y = Screen.h;
	}

	function wallCollisionX():Void {
		if (x < 0 || x > Screen.w) {
			Sound.play(Assets.sounds.sounds_hit);
			addParticles();
			speed.x = -speed.x;
		}
		if (x < 0) x = 0;
		if (x > Screen.w) x = Screen.w;
	}

	function stageTwoLogic(panels:Array<Panel>):Void {
		switch (type) {
			case Basic, Explosive, LaserLines:
				followPlayer(false);
			case Heal, Repulsion:
				followPlayer(true);
		}

		wallCollisionY();
		wallCollisionX();

		for (panel in panels) {
			if (panel == parent) continue;
			if (Collision.aabb(
				{x: x, y: y, w: size, h: size},
				{x: panel.x, y: panel.y, w: panel.w, h: panel.h}
			)) {
				switch (type) {
					case Basic, Explosive, LaserLines:
						panel.damage();
						Sound.play(Assets.sounds.sounds_hit2);
					case Heal:
						if (panel != game.player) continue;
						game.player.heal();
						Sound.play(Assets.sounds.sounds_blip);
					case Repulsion:
						if (panel != game.player) continue;
						game.player.addRepulsion();
						Sound.play(Assets.sounds.sounds_blip);
				}
				game.removeBall(this);
				break;
			}
		}

		if (explTimer > 0) {
			explTimer--;
			glowAnimMax = Std.int(explTimer / 5);
			if (glowAnimMax < 1) glowAnimMax = 1;
		}
		if (explTimer == 0) {
			for (panel in panels) {
				switch (type) {
					case Basic, Heal, Repulsion:
					case Explosive:
						var dist = Utils.dist({
							x: panel.x + panel.w / 2,
							y: panel.y + panel.h / 2
							}, {
								x: x + size / 2,
								y: y + size / 2
							}
						);
						if (panel != game.player) dist -= panel.h / 2;
						if (dist < size * EXPL_DIST) panel.damage();
					case LaserLines:
						final rect:Rect = {x: panel.x, y: panel.y, w: panel.w, h: panel.h};
						for (i in 0...8) {
							final ang = 360 / 8 * i;
							final collide = Collision.lineRect(
								{x: x + size / 2, y: y + size / 2}, {
									x: x + size / 2 + Math.cos(ang.toRad()) * Screen.w * 2,
									y: y + size / 2 + Math.sin(ang.toRad()) * Screen.w * 2
								}, rect
							);
							if (collide) {
								panel.damage();
								break;
							}
						}
				}
			}
			if (type == Explosive) explParticles();
			// if (type == LaserLines) linesParticles();
			Sound.play(Assets.sounds.sounds_hit2);
			if (type != LaserLines) game.removeBall(this);
		}
	}

	function explParticles():Void {
		game.particler.angleArea(Std.int(x), Std.int(y), size, size, 0, Math.PI * 2, {
			x: 0, y: 0,
			color: color,
			lifeTime: 25,
			gravity: {
				x: 0, y: 0
			},
			speed: {
				x: size / 2.5, y: size / 2.5
			}
		});
	}

	function linesParticles():Void {
		for (i in 0...8) {
			final ang = 360 / 8 * i;
			final minX = x + size / 2;
			final minY = y + size / 2;
			final maxX = x + size / 2 + Math.cos(ang.toRad()) * Screen.w;
			final maxY = y + size / 2 + Math.sin(ang.toRad()) * Screen.w;
			game.particler.line(
				Std.int(minX), Std.int(minY),
				Std.int(maxX), Std.int(maxY), 0, Math.PI * 2, {
				x: 0, y: 0,
				color: color,
				lifeTime: 10,
				gravity: {
					x: 0, y: 0
				},
				speed: {
					x: size / 20, y: size / 20
				}
			});
		}
	}

	function followPlayer(reverse:Bool) {
		final player = game.player;
		if (player.hasRepulsionBonus()) reverse = !reverse;
		final ang = Math.atan2(
			player.y + (player.h / 2) - (y + size / 2),
			player.x + (player.w / 2) - (x + size / 2)
		);
		final dist = Utils.dist({x: player.x, y: player.y}, {x: x, y: y});
		final power = dist / (Screen.w / 2);
		if (power < 1) {
			var sx = Math.cos(ang) / 10 * (1 - power);
			var sy = Math.sin(ang) / 10 * (1 - power);
			if (reverse) {
				sx = -sx;
				sy = -sy;
			}
			speed.x += sx * size / 10;
			speed.y += sy * size / 10;
		}
		final max = size;
		if (speed.x > max) speed.x = max;
		if (speed.y > max) speed.y = max;
		if (speed.x < -max) speed.x = -max;
		if (speed.y < -max) speed.y = -max;
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

	public function render(g:Graphics):Void {
		switch (type) {
			case Basic:
				g.color = color;
			case Heal, Repulsion, Explosive, LaserLines:
					if (glowAnim > 0) {
					var percent = (glowAnimMax - glowAnim) / glowAnimMax;
					percent *= 2;
					if (percent > 1) percent = 2 - percent;
					g.color = glow(color, percent);
					glowAnim--;
				} else {
					glowAnim = glowAnimMax;
					g.color = color;
				}
		}

		g.fillRect(x, y, size, size);
	}

	public function drawCircle(g:Graphics):Void {
		if (type != Explosive && type != LaserLines) return;
		final color = color;
		color.A = 1 - (explTimer / EXPL_MAX);
		g.color = color;
		if (type == Explosive) {
			g.drawCircle(x + size / 2, y + size / 2, size * EXPL_DIST);
		}
		if (type == LaserLines) {
			var strength = 1;
			if (explTimer == 0) {
				g.color = 0xFFFF9090;
				strength = 3;
				game.removeBall(this);
			}
			for (i in 0...8) {
				final ang = 360 / 8 * i;
				g.drawLine(
					x + size / 2,
					y + size / 2,
					x + size / 2 + Math.cos(ang.toRad()) * Screen.w * 2,
					y + size / 2 + Math.sin(ang.toRad()) * Screen.w * 2,
					strength
				);
			}
		}
	}

}
