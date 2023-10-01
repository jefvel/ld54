package entities;

import elk.Elk;

class BlobGuy extends Enemy {
	public function new(?p, state) {
		super(p, state);
		maxSpeed = 12;
		dropChance = 0.8;
		health = 4.0;
		revivePower = 0.9;
		sprite = hxd.Res.img.blobe.toSprite(this);
		sprite.originX = 20;
		sprite.originY = 40;
	}

	override function onDie() {
		if (!dead) {
			Elk.instance.sounds.playWobble(hxd.Res.sound.mondie, 0.2);
		}
		super.onDie();
	}
}