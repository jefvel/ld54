package entities;

import gamestates.PlayState;
import elk.Elk;
import elk.entity.Entity;
import elk.graphics.Sprite;

class Guy extends Entity {
	var sprite: Sprite;
	var maxSpeed = 4.0;
	public var selectedBrick: SudokuBullet;
	var shadow: Sprite;
	
	var state:PlayState;
	
	var kicking = false;
	var footsteps = [
		hxd.Res.sound.footstep1,
		hxd.Res.sound.footstep2,
		hxd.Res.sound.footstep3,
	];

	public function kick() {
		if (kicking) {
			return;
		}
		kicking = true;
		vx = -80.0;
		sprite.animation.play("kick", false);
		Elk.instance.sounds.playWobble(hxd.Res.sound.kick, 0.4);
		selectedBrick = null;
	}
	
	function onAnimationEnd(name: String) {
		if (kicking) {
			kicking = false;
		}
	}

	public function new(?p, state) {
		super(p);
		this.state = state;
		shadow = hxd.Res.img.manshadow.toSprite(this);
		shadow.originX = 16;
		shadow.originY = 4;
		shadow.alpha = 0.4;
		sprite = hxd.Res.img.main.toSprite(this);
		sprite.animation.onEnd = onAnimationEnd;
		sprite.animation.onEnterFrame = (f) -> {
			if (f == 6) {
				Elk.instance.sounds.playWobble(
					footsteps.randomElement(),
					0.1,
				);
			}
		}

		sprite.scaleX = -1;
		shadow.scaleX = -1;
		sprite.animation.play("idle");
		sprite.originX = 20;
		sprite.originY = 40;
	}
	
	var climbing = false;
	public function climb() {
		climbing = true;
		onLadder = false;
	}
	
	public var onLadder = false;
	
	override function tick(dt:Float) {
		super.tick(dt);
		
		var l = 0.0;
		var moving = false;
		var tx = x;
		var ty = y;
		
		

		if (!kicking && selectedBrick != null) {
			moving = true;
			tx =  selectedBrick.x + 40;
			ty = selectedBrick.y + 13;
		} 
		
		if (!kicking && selectedBrick == null && (climbing || state.ladder.hovered)) {
			tx = state.ladder.x;
			ty = state.ladder.y + 16;
			moving = true;
			var dx = tx - x;
			var dy = ty - y;

			if (climbing) {
				if (onLadder || Math.sqrt(dx * dx + dy * dy) < 8) {
					if (!onLadder) {
						onLadder = true;
						Elk.instance.sounds.playWobble(hxd.Res.sound.climb);
					}

					vx *= 0.9;
					vy = -50;

					sprite.animation.play("climb");
					shadow.visible = false;

					return;
				}
			}
		}

		shadow.visible = true;
		
		
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
		
		if (vx > 5) {
			sprite.scaleX = 1;
			shadow.scaleX = 1;
		} else {
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