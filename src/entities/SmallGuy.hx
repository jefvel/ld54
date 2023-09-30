package entities;

import gamestates.PlayState;
import elk.Elk;
import elk.graphics.Sprite;

class SmallGuy extends Actor {
	public var sprite: Sprite;
	var maxSpeed = 4.0;
	var shadow: Sprite;
	
	var kicking = false;
	var footsteps = [
		hxd.Res.sound.footstep1,
		hxd.Res.sound.footstep2,
		hxd.Res.sound.footstep3,
	];

	
	function onAnimationEnd(name: String) {
		if (kicking) {
			kicking = false;
		}
	}

	var state: OverWorld;
	public function new(?p, state) {
		super(p);
		this.state = state;
		shadow = hxd.Res.img.manshadow.toSprite(this);
		shadow.originX = 16;
		shadow.originY = 4;
		shadow.alpha = 0.0;
		sprite = hxd.Res.img.smallman.toSprite(this);
		sprite.animation.onEnd = onAnimationEnd;
		sprite.animation.onEnterFrame = (f) -> {
			if (f == 4 || f == 6) {
				Elk.instance.sounds.playWobble(
					footsteps.randomElement(),
					0.1,
				);
			}
		}

		sprite.scaleX = -1;
		shadow.scaleX = -1;
		sprite.animation.play("idle");
		sprite.originX = 16;
		sprite.originY = 28;
	}
	
	var climbing = false;
	public function climb() {
		climbing = true;
		onLadder = false;
	}
	
	public var onLadder = false;
	
	override function tick(dt:Float) {
		super.tick(dt);
		if (!state.running) {
			return;
		}
		
		var l = 0.0;
		var moving = false;
		var tx = x;
		var ty = y;
		
		shadow.visible = true;
		
		var s = getScene();
		tx = s.mouseX - parent.x;
		ty = s.mouseY - parent.y;
		moving = true;
		
		if (moving) {
			var dx = tx - x;
			var dy = ty - y;
			dx *= 0.2;
			dy *= 0.2;
			l = Math.sqrt(dx * dx + dy * dy);
			if (l > maxSpeed) {
				dx /= l;
				dy /= l;
				dx *= maxSpeed;
				dy *= maxSpeed;
				l = maxSpeed;
			}
			vx = dx * 40;
			vy = dy * 40;
		} else {
			vx *= 0.9;
			vy *= 0.9;
		}
		
		if (vx > 1) {
			sprite.scaleX = 1;
			shadow.scaleX = 1;
		} else if (vx < -1) {
			sprite.scaleX = -1;
			shadow.scaleX = -1;
		} 

		if (kicking) {
			return;
		}

		if (l > 0.4) {
			sprite.animation.play("walk");
		} else {
			sprite.animation.play("idle");
		}
	}
}