package entities;

import elk.Elk;
import elk.util.EasedFloat;
import elk.M;
import gamestates.PlayState;
import elk.graphics.Sprite;
import elk.entity.Entity;

class XpOrb extends Entity {
	var state: PlayState;
	var sprite: Sprite;

	var untilMove = 0.4;
	var moving = false;

	var svx = 0.0;
	var svy = 0.0;
	
	var moveTime = 0.0;
	
	var value = 0.1;
	
	var rOffX = 0.0;
	
	public function new(?p, state, value, delay = 0.0) {
		super(p);
		this.state = state;
		this.value = value;
		untilMove += delay;

		sprite = hxd.Res.img.xporb.toSprite(this);
		sprite.originX = sprite.originY = 8;

		var d = Math.PI * 2 * Math.random();
		var s = Math.random() * 120.3 + 50;
		friction = 2.8;
		rOffX = Math.random() - 0.5;

		svx = Math.cos(d);
		svy = Math.sin(d);

		vx = svx * s;
		vy = svy * s;
		svy -= 2.8;
	}

	var moveEase = new EasedFloat(0, 0.4);
	var speedEase = new EasedFloat(0, 0.3);
	
	function addVal() {
		state.turretBoost += value;
		if (state.turretBoost > 6) {
			state.turretBoost = 6;
		}

		state.boostBar.value = state.turretBoost;
		state.boostBar.nudge(vx, vy);
	}

	override function tick(dt:Float) {
		super.tick(dt);
		if (!moving) {
			untilMove -= dt;
			if (untilMove <= 0) {
				moving = true;
				moveEase.value = 1;
				speedEase.value = 2;
				friction = 14.5;
			}
			return;
		}
		
		rotation = Math.atan2(vy, vx);
		scaleX = Math.max(1, Math.max(Math.abs(vx / 100), Math.abs(vy / 100)));
		//scaleY = Math.max(1, Math.abs(vy / 100));
		
		moveTime += dt;
		var barPos = state.boostBar.getAbsPos();
		var ownPos = getAbsPos();
		
		var bbar = state.boostBar;
		
		barPos.x += state.boostBar.width * 0.5;
		barPos.y += state.boostBar.height * 0.5;
		

		var dx = barPos.x - ownPos.x;
		var dy = barPos.y - ownPos.y;
		
		if (Math.abs(dx) < bbar.width * 0.8 && Math.abs(dy) < bbar.height * 0.8) {
			addVal();
			Elk.instance.sounds.playWobble(hxd.Res.sound.xporbhit, 0.3);
			remove();
			return;
		}
		
		dx += bbar.width * rOffX;

		var l = Math.sqrt(dx * dx + dy * dy);
		
		dx /= l;
		dy /= l;
		
		var t = moveEase.value;
		var sp = speedEase.value;
		dx = M.mix(svx, dx, t) * 160 * sp;
		dy = M.mix(svy, dy, t) * 160 * sp;

		vx += dx;
		vy += dy;
	}
}