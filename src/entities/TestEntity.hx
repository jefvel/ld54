package entities;

import elk.graphics.Sprite;
import hxd.Key;
import h2d.Tile;
import h2d.Bitmap;
import elk.graphics.Animation;

class TestEntity extends elk.entity.Entity {
	var bm:Bitmap = null;
	var lx = 0.;
	var ly = 0.;
	var data: CData.Character;
	var sprite : Sprite;

	public function new(?p) {
		data = CData.character.get(Man);
		friction = 10.;
		sprite = hxd.Res.img.ball.toSprite(p);
		sprite.originX = 32;
		t = Math.random() * 30;
		sprite.originY = 64;
	}

	var t = 0.;
	override function tick(dt:Float) {
		super.tick(dt);
		t+=dt;
		sprite.rotation = Math.sin(t) * .3;

		var sp = data.MoveSpeed * 10000 * dt;
		if (Key.isDown(Key.A)) {
			ax -= sp;
		}
		if (Key.isDown(Key.D)) {
			ax += sp;
		}
		
		if (Key.isDown(Key.W)) {
			ay -= sp;
		}
		if (Key.isDown(Key.S)) {
			ay += sp;
		}

		var dSq = hxd.Math.distanceSq(vy, vx);
		var maxSpeed = data.MaxSpeed;
		if (dSq > maxSpeed * maxSpeed) {
			var d = Math.sqrt(dSq);
			vx /= d;
			vy /= d;
			vx *= maxSpeed;
			vy *= maxSpeed;
		}
		
		if (hxd.Math.distance(lx - x, ly - y) > 22) {
			//elk.Elk.instance.sounds.playSound(hxd.Res.sound.click);
			lx = x;
			ly = y;
		}
	}

	override function render() {
		// sprite.x = x;
		// sprite.y = y;
		sprite.x = interpX;
		sprite.y = interpY;
	}
}