package entities;

import elk.M;
import h2d.Interactive;
import h2d.Text;
import elk.graphics.Sprite;
import elk.entity.Entity;

class Ladder extends Actor {
	var sprite:Sprite;
	
	var arrow: Sprite;
	var label: Text;
	var button: Interactive;
	public var enabled = false;
	
	public var onClick: Void -> Void;
	public var hovered = false;
	
	public function new(?p) {
		super(p);
		mass = 0.0;
		radius = 12.0;
		
		sprite = hxd.Res.img.ladder.toSprite(this);
		sprite.originX = 32;
		sprite.originY = 58;
		arrow = hxd.Res.img.arrowup.toSprite(this);
		arrow.originX = arrow.originX = 16;
		arrow.x = 0;
		arrow.y = -40;
		label = new Text(hxd.Res.fonts.marumonica.toFont(), arrow);
		label.text = "Go\nCollect Tiles";
		label.x = 32;
		arrow.alpha = 0;
		button = new Interactive(129, 80, this);
		button.y = - 70;
		button.x = -20;
		button.onPush = (e) -> {
			if (enabled) {
				onPush();
			}
		}
		button.onOver = (e) -> onOver = true;
		button.onOut = (e) -> onOver = false;
	}
	public var onPush: Void -> Void;
	var onOver = false;
	
	override function tick(dt:Float) {
		super.tick(dt);
		hovered = onOver && enabled;
		if (enabled) {
			button.cursor = Button;
			arrow.alpha += (1 - arrow.alpha) * 0.3;
		} else {
			button.cursor = Default;
			arrow.alpha *= 0.4;
		}
	}
}