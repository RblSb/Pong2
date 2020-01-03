package game;

import khm.Screen;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.Color;

@:structInit
class ParticleSets {
	public var x:Float;
	public var y:Float;
	public var speed:Vector2;
	public var gravity:Vector2; // = {x: 0, y: 1};
	public var lifeTime:Int;
	public var color:Color;

	public inline function new(x:Float, y:Float, speed:Vector2, gravity:Vector2, lifeTime:Int, color:Color) {
		this.x = x;
		this.y = y;
		this.speed = speed;
		this.gravity = gravity;
		this.lifeTime = lifeTime;
		this.color = color;
	}
}

class Particler {

	final particles:Array<Particle> = [];
	final pool:Array<Particle> = [];

	public function new() {}

	public inline function add(sets:ParticleSets) {
		if (pool.length > 0) {
			final particle = pool.pop();
			particle.init(this, sets);
			particles.push(particle);
		} else {
			final particle = new Particle(this);
			particle.init(this, sets);
			particles.push(particle);
		}
	}

	public inline function angleArea(x:Int, y:Int, w:Int, h:Int, angleStart:Float, angleEnd:Float, sets:ParticleSets) {
		for (iy in y...y + h) {
			for (ix in x...x + w) {
				final ang = angleStart + Math.random() * (angleEnd - angleStart);
				add({
					x: sets.x + ix,
					y: sets.y + iy,
					speed: {
						x: Math.cos(ang) * sets.speed.x,
						y: Math.sin(ang) * sets.speed.y
					},
					gravity: sets.gravity,
					lifeTime: sets.lifeTime,
					color: sets.color
				});
			}
		}
	}

	static inline function dist(x:Float, y:Float, x2:Float, y2:Float):Float {
		return Math.sqrt(Math.pow(x - x2, 2) + Math.pow(y - y2, 2));
	}

	public inline function line(x:Float, y:Float, x2:Float, y2:Float, angleStart:Float, angleEnd:Float, sets:ParticleSets):Void {
		final d = dist(x, y, x2, y2);
		var tx = (x2 - x) / d;
		var ty = (y2 - y) / d;
		if (d > 500) {
			tx *= Std.int(d / 500);
			ty *= Std.int(d / 500);
		}
		for (i in 0...Std.int(d)) {
			final ang = angleStart + Math.random() * (angleEnd - angleStart);
			add({
				x: sets.x + x,
				y: sets.y + y,
				speed: {
					x: Math.cos(ang) * sets.speed.x,
					y: Math.sin(ang) * sets.speed.y
				},
				gravity: sets.gravity,
				lifeTime: sets.lifeTime,
				color: sets.color
			});
			x += tx;
			y += ty;
		}
	}

	public function update():Void {
		for (p in particles) p.update();
	}

	public function render(g:Graphics, cx:Float, cy:Float):Void {
		for (p in particles) p.render(g, cx, cy);
	}

	public function remove(p:Particle):Void {
		particles.remove(p);
		pool.push(p);
	}

}

class Particle {

	var ctx:Particler;
	var x:Float;
	var y:Float;
	var speed:Vector2;
	var gravity:Vector2;
	var color:Color;
	var maxLifeTime:Int;
	var lifeTime:Int;

	public function new(ctx:Particler) {}

	public inline function init(ctx:Particler, sets:ParticleSets):Void {
		this.ctx = ctx;
		x = sets.x;
		y = sets.y;
		speed = sets.speed;
		gravity = sets.gravity;
		color = sets.color;
		maxLifeTime = sets.lifeTime;
		lifeTime = sets.lifeTime;
	}

	public function update():Void {
		speed.x += gravity.x;
		speed.y += gravity.y;
		x += speed.x;
		y += speed.y;
		lifeTime--;

		if (lifeTime == 0) ctx.remove(this);
	}

	public function render(g:Graphics, cx:Float, cy:Float):Void {
		if (x + cx < 0 || y + cy < 0 || x + cx > Screen.w || y + cy > Screen.h) return;
		color.A = lifeTime / maxLifeTime;
		g.color = color;
		g.fillTriangle(x + cx, y + cy, x + cx + 1, y + cy + 1, x + cx, y + cy + 1);
		// g.fillRect(x + cx, y + cy, 1, 1);
	}

}
