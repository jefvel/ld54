package entities;

import elk.M;
import h2d.RenderContext;
import elk.util.EasedFloat;
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
	public var range = 265.0;
	
	public var firerateMultiplier = 1.0;

	public var boost = 0.0;
	var boostPerBullet = 0.08;
	
	public var muzzle: Sprite;
	
	public var paused = true;
	public function reset() {
		paused = false;
		target = null;
		untilFire = fireRate;
	}

	var state: OverWorld;
	var off = new EasedFloat(0, 0.4);
	public function new(?p, state) {
		super(p);
		off.easeFunction = M.elasticOut;
		this.state = state;
		mass = 0.0;
		radius = 12.0;
		body = hxd.Res.img.turretbody.toSprite(this);
		t1 = hxd.Res.img.turrettop.toSprite(this);
		t2 = hxd.Res.img.turret.toSprite(this);
		muzzle = hxd.Res.img.turretmuzzle.toSprite(this);
		muzzle.originX = -20;
		muzzle.originY = 8;
		muzzle.visible = false;

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
		muzzle.y = offY;
	}


	function findTarget() {
		target = null;
		var modifiedRange = range;
		if (boost > 2) {
			modifiedRange += 25;
		}
		var r = Math.min(modifiedRange, state.visibleRange + 20);
		var md = r * r;
		var closest = null;
		for (e in state.enemies) {
			if (e.dead) continue;
			var dx = x - e.x;
			var dy = y - e.y;
			if (Math.abs(dy) > state.height * 0.5 - 10) continue;
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
		off.setImmediate(6);
		off.value = 0;
		untilFire = fireRate;
		var bullet = new Bullet(state.world, target);
		bullet.damage += state.state.extraFireRateUpgrades * 0.3;
		bullet.damage += boost;
		var dx = target.x - x;
		var dy = target.y - y;
		var l = Math.sqrt(dx * dx + dy * dy);
		dx /= l;
		dy /= l;
		dx *= 19;
		dy *= 19;

		muzzle.visible = true;
		muzzle.rotation = rott;
		muzzle.animation.play("fire", false, true);

		bullet.x = x + dx;
		bullet.y = y + offY + dy - bullet.bm.y;
		bullet.bm.rotation = rott;
		Elk.instance.sounds.playWobble(hxd.Res.sound.shoot);
		var bb = boostPerBullet;
		//if (boost >= 3) bb *= 0.6;
		//else if (boost >= 2) bb *= 0.7;
		boost -= bb;
		if (boost < 0) boost = 0.0;
	}
	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		t1.originX = t2.originX = t3.originX = 4 + Std.int(off.value);
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
			rott -= r * 0.4;
			var scl = 1.0 * firerateMultiplier;
			if (boost > 0.0) {
				scl += .5;
				if (boost > 1.0) {
					scl += 0.5;					
				}
			}
			untilFire -= dt * scl;
			if (untilFire < 0 && Math.abs(r) < 0.03) {
				fire();
			}
		}

		if (target == null) {
			rott += dt;
			rott %= Math.PI * 2;
		}
		
		t1.rotation = t2.rotation = t3.rotation = rott;
	}
}