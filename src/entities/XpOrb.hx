package entities;

import elk.graphics.Sprite;
import elk.entity.Entity;

class XpOrb extends Entity {
	var sprite: Sprite;
	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.xporb.toSprite(this);
		sprite.originX = sprite.originY = 8;
	}
}