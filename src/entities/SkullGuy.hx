package entities;

import elk.Elk;

class SkullGuy extends Enemy {
	public function new(?p, state) {
		super(p, state);
		maxSpeed = 14;
		revivePower = 0.7;
		sprite = hxd.Res.img.skullman.toSprite(this);
		sprite.originX = 16;
		sprite.originY = 30;
	}

	override function onDie() {
		if (!dead) {
			Elk.instance.sounds.playWobble(hxd.Res.sound.mondie, 0.2);
		}
		super.onDie();
	}
}