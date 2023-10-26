package entities;

import elk.graphics.Sprite;

class Bullet extends Actor {
	public var bm : Sprite;
	var target: Enemy;
	var speed = 20.0;
	public var damage = 1.0;
	var state: OverWorld;
	public function new(?p, target, state) {
		super(p);
		this.state = state;
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
			var s = hxd.Res.img.enemyhit.toSprite(state.parts);
			s.x = x;
			s.y = y;
			s.originX = s.originY = 8;
			s.animation.play("fire", false);
			s.animation.onEnd = e -> s.remove();
			remove();

			elk.Elk.instance.sounds.playWobble(hxd.Res.sound.hit);
		} else {
			x += dx;
			y += dy;
		}
	}
}