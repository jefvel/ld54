package entities;

import h3d.Vector;
import elk.graphics.Sprite;

class Enemy extends Actor {
	public var health = 3.0;
	public var sprite: Sprite;
	public var maxSpeed = 9.0;

	var state: OverWorld;
	
	public var dropChance = 0.4;
	public var dropStrength = 1;
	
	public var dead = false;

	function new(?p, state) {
		super(p);
		this.state = state;
	}
	
	var flasTime = 0.0;
	public function hurt(damage = 1.0) {
		if (dead) {
			return;
		}

		health -= damage;
		flasTime = 0.1;

		if (health<= 0) {
			onDie();
		}
	}
	
	function onDie() {
		if (dead) return;
		dead = true;
		state.onEnemyDie(this);
	}
	
	override function tick(dt:Float) {
		super.tick(dt);
		if (flasTime > 0) {
			sprite.color.set(100., 100, 100);
			flasTime -= dt;
		} else {
			sprite.color.set(1, 1, 1);
		}
		var dx = state.man.x - x;
		var dy = state.man.y - y;
		var l = Math.sqrt(dx * dx + dy * dy);
		dx /= l;
		dy /= l;
		dx *= maxSpeed;
		dy *= maxSpeed;
		vx = dx;
		vy = dy;
		if (vx < -0.5) {
			sprite.scaleX = -1;
		} else if (vx > 0.5) {
			sprite.scaleX = 1.0;
		}
	}
}