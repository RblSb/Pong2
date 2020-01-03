package khm.utils;

import khm.Types.Point;
import khm.Types.Rect;

class Collision {

	public static inline function aabb(a:Rect, b:Rect):Bool {
		return !(
			a.y + a.h < b.y || a.y > b.y + b.h ||
			a.x + a.w < b.x || a.x > b.x + b.w
		);
	}

	public static inline function aabb2(a:Rect, b:Rect):Bool {
		return !(
			a.y + a.h <= b.y || a.y >= b.y + b.h ||
			a.x + a.w <= b.x || a.x >= b.x + b.w
		);
	}

	public static function doPolygonsIntersect(a:Array<Point>, b:Array<Point>):Bool {
		function doIntersect(polygon:Array<Point>):Bool {
			var hasIntersect = true;
			for (i in 0...polygon.length) {
				// get points for normal
				final i2 = (i + 1) % polygon.length;
				final p1 = polygon[i];
				final p2 = polygon[i2];
				final normal = {
					x: p2.y - p1.y,
					y: p1.x - p2.x
				};

				var minA = Math.POSITIVE_INFINITY;
				var maxA = Math.NEGATIVE_INFINITY;
				for (point in a) {
					final projected = normal.x * point.x + normal.y * point.y;
					if (projected < minA) minA = projected;
					if (projected > maxA) maxA = projected;
				}

				var minB = Math.POSITIVE_INFINITY;
				var maxB = Math.NEGATIVE_INFINITY;
				for (point in b) {
					final projected = normal.x * point.x + normal.y * point.y;
					if (projected < minB) minB = projected;
					if (projected > maxB) maxB = projected;
				}

				if (maxA < minB || maxB < minA) {
					hasIntersect = false;
					break;
				}
			}
			return hasIntersect;
		}
		if (!doIntersect(a)) return false;
		if (!doIntersect(b)) return false;
		return true;
	}

	public static inline function lineRect(p:Point, p2:Point, r:Rect):Bool {
		final left = lineLine(p.x, p.y, p2.x, p2.y, r.x, r.y, r.x, r.y + r.h);
		final right = lineLine(p.x, p.y, p2.x, p2.y, r.x + r.w, r.y, r.x + r.w, r.y + r.h);
		final top = lineLine(p.x, p.y, p2.x, p2.y, r.x, r.y, r.x + r.w, r.y);
		final bottom = lineLine(p.x, p.y, p2.x, p2.y, r.x, r.y + r.h, r.x + r.w, r.y + r.h);
		return left || right || top || bottom;
	}

	public static function lineLine(
		x1:Float, y1:Float, x2:Float, y2:Float,
		x3:Float, y3:Float, x4:Float, y4:Float
	):Bool {
		final uA = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) /
			((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));
		final uB = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) /
			((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));
		return uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1;
	}

	public static function doLinesIntersect(p:Point, p2:Point, p3:Point, p4:Point):Point {
		final x = p2.x - p.x;
		final y = p2.y - p.y;
		final x2 = p4.x - p3.x;
		final y2 = p4.y - p3.y;

		final s = (-y * (p.x - p3.x) + x * (p.y - p3.y)) / (-x2 * y + x * y2);
		final t = (x2 * (p.y - p3.y) - y2 * (p.x - p3.x)) / (-x2 * y + x * y2);

		if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
			return {x: p.x + t * x, y: p.y + t * y};
		}
		return null;
	}

	public static function inTriangle(p:Point, a:Point, b:Point, c:Point):Bool {
		final v0 = {x: c.x - a.x, y: c.y - a.y};
		final v1 = {x: b.x - a.x, y: b.y - a.y};
		final v2 = {x: p.x - a.x, y: p.y - a.y};
		final dot00 = v0.x * v0.x + v0.y * v0.y;
		final dot01 = v0.x * v1.x + v0.y * v1.y;
		final dot02 = v0.x * v2.x + v0.y * v2.y;
		final dot11 = v1.x * v1.x + v1.y * v1.y;
		final dot12 = v1.x * v2.x + v1.y * v2.y;

		final invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
		final u = (dot11 * dot02 - dot01 * dot12) * invDenom;
		final v = (dot00 * dot12 - dot01 * dot02) * invDenom;
		return u >= 0 && v >= 0 && u + v < 1;
	}

}
