package game;

import kha.Color;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import kha.input.Mouse;
import khm.Screen.Pointer;
using khm.utils.MathExtension;

class Player extends Panel {

	public static inline var MAX_HP = 5;
	public static inline var REPULSION_MAX = 6 * 60;
	public var endTimer = 1190;
	public var hp(default, null) = MAX_HP;
	var repulsion = 0;
	var repulsionAngle = 0;

	public function onMouseMove(p:Pointer):Void {
		if (Mouse.get().isLocked()) {
			y += p.moveY;
			if (game.stage != One) x += p.moveX;
		} else {
			y = p.y - Std.int(h / 2);
			if (game.stage != One) x = p.x - Std.int(w / 2);
		}
	}

	public function setH(newH:Int):Void {
		final diff = Std.int((h - newH) / 2);
		y += diff;
		h = newH;
		addParticlesH(y);
		addParticlesH(y + h);
	}

	function addParticlesH(rectY:Float):Void {
		game.particler.angleArea(
			Std.int(x), Std.int(rectY), w, 1, 0,
			Math.PI * 2, {
				x: 0, y: 0,
				color: color,
				lifeTime: 50,
				gravity: {
					x: 0, y: 0.1
				},
				speed: {
					x: 0.5, y: 0.5
				}
			}
		);
	}

	public function heal():Void {
		if (hp >= MAX_HP) return;
		hp++;
		updateColor();
	}

	public function addRepulsion():Void {
		repulsion = REPULSION_MAX;
	}

	public function hasRepulsionBonus():Bool {
		return repulsion > 0;
	}

	override function damage():Void {
		game.particler.angleArea(
			Std.int(x), Std.int(y), w, h,
			0, Math.PI * 2, {
				x: 0, y: 0,
				color: color,
				lifeTime: 50,
				gravity: {
					x: 0, y: 0
				},
				speed: {
					x: 0.5, y: 0.5
				}
			}
		);

		hp--;
		updateColor();
	}

	function updateColor():Void {
		switch (hp) {
			case 5:
				color = 0xFF00FF00;
			case 4:
				color = 0xFF2E6A42;
			case 3:
				color = 0xFFF7AC37;
			case 2:
				color = 0xFF97432A;
			case 1:
				color = 0xFF781F2C;
			case 0:
				game.lose();
		}
	}

	override function update() {
		super.update();
		if (repulsion > 0) repulsion--;
		if (game.goingEnd) {
			if (endTimer > 0) {
				game.particler.angleArea(
					Std.int(x) + Std.random(w),
					Std.int(y) + Std.random(h),
					1, 1, 0, Math.PI * 2, {
						x: 0, y: 0,
						color: color,
						lifeTime: 100,
						gravity: {
							x: -0.01, y: 0.01
						},
						speed: {
							x: 0.1, y: 0.1
						}
					}
				);
			} else if (endTimer == 0) {
				game.particler.angleArea(
					Std.int(x), Std.int(y),
					w, h, 0, Math.PI * 2, {
						x: 0, y: 0,
						color: color,
						lifeTime: 700,
						gravity: {
							x: -0.002, y: 0.002
						},
						speed: {
							x: 0.4, y: 0.4
						}
					}
				);
				color = 0x0;
				repulsion = 0;
			}
			endTimer--;
		}
	}

	override function render(g:Graphics) {
		super.render(g);
		if (!hasRepulsionBonus()) return;

		final tempMatrix = FastMatrix3.identity();
		tempMatrix.setFrom(g.transformation);
		g.transformation = g.transformation.multmat(
			FastMatrix3.translation(0, 0)
		).multmat(
			rotation(repulsionAngle.toRad(), x + w / 2, y + h / 2)
		);
		repulsionAngle += 8;
		if (repulsionAngle > 359) repulsionAngle -= 360;

		var color:Color = 0xFFFFFFFF;
		color.A = repulsion / REPULSION_MAX;
		g.color = color;
		g.drawRect(x - w / 2, y - h / 2, w * 2, h * 2);
		g.transformation = tempMatrix;
	}

	inline function rotation(angle: FastFloat, centerx: FastFloat, centery: FastFloat): FastMatrix3 {
		return FastMatrix3.translation(centerx, centery)
			.multmat(FastMatrix3.rotation(angle))
			.multmat(FastMatrix3.translation(-centerx, -centery));
	}

}
