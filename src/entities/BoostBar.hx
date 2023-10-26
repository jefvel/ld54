package entities;

import elk.Elk;
import h3d.Vector;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import elk.M;
import elk.util.EasedFloat;
import gamestates.PlayState;
import h2d.ScaleGrid;
import elk.entity.Entity;

enum Orientation {
	Horizontal;
	Vertical;
}

class BoostBar extends Entity {
	var _width = new EasedFloat(64, 0.4);
	var _height = new EasedFloat(16, 0.4);
	public var width = 64.;
	public var height = 16.;

	public var value(default, set) = 0.0;
	
	public var maxValue = 6.0;
	public var sizePerSegment = 1.0;
	
	public var orientation = Horizontal;
	
	var lastVal = 0.0;
	var accum = 0.0;

	var frame: ScaleGrid;
	var state: PlayState;
	var barColors = [
		0x468232,
		0xa8ca58,
		0xe8c170,
		0xda863e,
		0xa53030,
		0xa23e8c,
		0xebede9,
	];

	var glow: ScaleGrid;
	var glowPad = 16;
	var bars: Array<Bitmap> = [];
	var boostEase = new EasedFloat(0, 0.6);

	var rotateEase = new EasedFloat(0, 0.4);
	
	var ox = 0.0;
	var oy = 0.0;
	var vox = 0.0;
	var voy = 0.0;
	var aoy = 0.0;
	var aox = 0.0;

	var container: Object;
	public function nudge(dx = 0.0, dy = -1.0) {
		ox += dx * 0.005;
		oy += dy * 0.005;
		glow.alpha += 2.0;
	}

	public function new(?p, state: PlayState) {
		super(p);
		container = new Object(this);

		boostEase.easeFunction = M.elasticOut;

		rotateEase.easeFunction = M.elasticOut;
		rotateEase.value = -Math.PI * 0.5;

		this.state = state;
		
		glow = new ScaleGrid(hxd.Res.img.blurrect.toTile(), 24,24,24,24, container);
		glow.x = glow.y = - glowPad;
		glow.color = Vector.fromColor(barColors[1]);
		glow.color.a = 1.0;
		glow.alpha = 0.0;

		frame = new ScaleGrid(hxd.Res.img.boostbarframe.toTile(), 2, 2, 4, 2, container);
		for (c in barColors) {
			var b = new Bitmap(Tile.fromColor(c), frame);
			b.x = b.y = padding;
			bars.push(b);
		}
		
		nudge(Math.random() * 100 - 50, Math.random() * 100 - 50);
	}
	
	var padding = 2.0;
	
	function set_value(v: Float) {
		boostEase.value = v;
		return value = v;
	}
	
	override function tick(dt:Float) {
		super.tick(dt);

		if (orientation == Horizontal) {
			rotateEase.value = 0;
			_width.value = width;
			_height.value = height;
		} else if (orientation == Vertical) {
			rotateEase.value = -Math.PI * 0.5;
			_width.value = height;
			_height.value = width;
		}

		var w = _width.value;
		var h = _height.value;

		glow.alpha = Math.min(glow.alpha, 2.0);
		glow.alpha *= 0.9;

		glow.width = w + glowPad * 2;
		glow.height = h + glowPad * 2;

		ox += vox;
		oy += voy;

		aox += -ox * 0.3;
		aoy += -oy * 0.3;

		vox += aox;
		voy += aoy;

		aox *= 0.7;
		aoy *= 0.7;
		
		vox *= 0.36;
		voy *= 0.36;

		rotation = rotateEase.value;

		container.x = ox - w * 0.5;
		container.y = oy - h * 0.5;

		frame.width = w;
		frame.height = h;

		var d = boostEase.targetValue - lastVal;
		var v = 0.0;
		if (d > 0) {
			d = Math.min(d * 0.2, 0.06);
			accum += d;
			if (accum > 0.1 && value < maxValue) {
				Elk.instance.sounds.playWobble(hxd.Res.sound.click, 0.3);
				accum -= 0.1;
			}
			var p = Std.int(lastVal);
			lastVal += d;
			lastVal = Math.min(maxValue, lastVal);
			if (p < Std.int(lastVal)) {
				nudge(0, -700);
			}
			v = lastVal;
		} else {
			lastVal = boostEase.targetValue;
			v = boostEase.value;
		}


		for (b in bars) {
			var s = v;
			s = Math.min(sizePerSegment, s);
			b.height = h - padding * 2;
			b.width = ((w - padding * 2) * s) / sizePerSegment;

			v -= sizePerSegment;
			v = Math.max(0, v);
		}
	}
}