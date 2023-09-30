package entities;

import elk.Elk;
import elk.graphics.Sprite;
import elk.entity.Entity;

class Turret extends Actor {
	var t1: Sprite;
	var t2: Sprite;
	var t3: Sprite;
	var body: Sprite;
	var box: Sprite;
	var rott = 0.0;
	var offY = -14;

	public var target: Enemy;
	public var untilFire = 0.0;
	public var fireRate = 1.0;
	public var range = 240.0;
	
	public var paused = true;
	public function reset() {
		paused = false;
		untilFire = fireRate;
	}

	var state: OverWorld;
	public function new(?p, state) {
		super(p);
		this.state = state;
		mass = 0.0;
		radius = 12.0;
		body = hxd.Res.img.turretbody.toSprite(this);
		t1 = hxd.Res.img.turrettop.toSprite(this);
		t2 = hxd.Res.img.turret.toSprite(this);
		t3 = hxd.Res.img.turrettop.toSprite(this);
		box = hxd.Res.img.turretpeg.toSprite(this);
		body.originX = 16;
		body.originY = 26;
		box.originX = box.originY = 16;
		box.y = -2 + offY;
		t1.originY = t2.originY = t3.originY = 16;
		t1.originX = t2.originX = t3.originX = 4;
		t2.y = offY;
		t1.y = 1 + offY;
		t3.y = -2 + offY;
	}


	function findTarget() {
		target = null;
		var r = Math.min(range, state.visibleRange);
		var md = r * r;
		var closest = null;
		for (e in state.enemies) {
			if (e.dead) continue;
			var dx = x - e.x;
			var dy = y - e.y;
			var lsq = dx * dx + dy * dy;
			if (lsq < md) {
				closest = e;
				md = lsq;
			}
		}
		
		if (closest != null)  {
			target = closest;
		}
	}
	
	function fire() {
		untilFire = fireRate;
		var bullet = new Bullet(state.world, target);
		var dx = target.x - x;
		var dy = target.y - y;
		var l = Math.sqrt(dx * dx + dy * dy);
		dx /= l;
		dy /= l;
		dx *= 24;
		dy *= 24;

		bullet.x = x + dx;
		bullet.y = y + offY + dy - bullet.bm.y;
		bullet.bm.rotation = rott;
		Elk.instance.sounds.playWobble(hxd.Res.sound.shoot);
	}
	
	override function tick(dt:Float) {
		super.tick(dt);
		if (paused) {
			return ;
		}


		if (target == null || target.dead) {
			findTarget();
		}
		
		if (target != null) {
			var dx = target.x - x;
			var dy = target.y - y;
			var ang = Math.atan2(dy, dx);
			var r = ang.angleBetween(rott);
			rott -= r * 0.1;
			untilFire -= dt;
			if (untilFire < 0) {
				fire();
			}
		}

		//rott += dt;
		t1.rotation = t2.rotation = t3.rotation = rott;
	}
}