package entities;

import h2d.Interactive;
import h2d.Text;
import elk.graphics.Sprite;

class LilLadder extends Actor {
	var ladder: Sprite;
	public var enabled = false;
	var arrw: Sprite;
	var txt: Text;
	var button: Interactive;
	public function new(?p) {
		super(p);
		mass = 0;
		ladder = hxd.Res.img.ladderdown.toSprite(this);
		ladder.originX = 16;
		ladder.originY = 23;
		button = new Interactive(32, 24, this);
		button.x = -16;
		button.y = -14;
		arrw = hxd.Res.img.arrowdown.toSprite(this);
		arrw.originX = arrw.originY = 10;
		arrw.y = -20;
		txt = new Text(hxd.Res.fonts.marumonica.toFont(), arrw);
		txt.text = "Click Ladder/Hold down Mouse button\nTo Return";
		txt.x = 16;
		txt.y = -txt.textHeight * 0.5;
		enabled = false;
		arrw.alpha = 0;
		button.visible = false;
	}
	
	override function tick(dt:Float) {
		super.tick(dt);
		if (enabled) {
			button.visible = true;
			arrw.alpha += (1 - arrw.alpha) * 0.2;
		} else {
			button.visible = false;
			arrw.alpha *= 0.8;
		}
	}
}