package entities;

import elk.graphics.Sprite;
import h2d.Bitmap;

class Bullet extends Actor {
	public var bm : Sprite;
	var target: Enemy;
	var speed = 20.0;
	public var damage = 1.0;
	public function new(?p, target) {
		super(p);
		this.target = target;
		bm = hxd.Res.img.bullet.toSprite(this);
		bm.originX = 7;
		bm.originY = 3;
		bm.y = -8;
		this.uncollidable = true;
	}
	
	override function tick(dt:Float) {
		super.tick(dt);
		var dx = target.x - x;
		var dy = target.y - y + bm.y - 9;
		var l = Math.sqrt(dx * dx + dy * dy);
		dx /= l;
		dy /= l;
		dx *= speed;
		dy *= speed;
		if (l < speed) {
			target.hurt(damage);
			remove();
			elk.Elk.instance.sounds.playWobble(hxd.Res.sound.hit);
		} else {
			x += dx;
			y += dy;
		}
	}
}