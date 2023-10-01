package entities;

import h2d.Tile;
import h2d.Bitmap;
import elk.M;
import elk.util.EasedFloat;
import gamestates.PlayState;
import h2d.ScaleGrid;
import elk.entity.Entity;


class BoostBar extends Entity {
	public var width = 64.0;
	public var height = 16.0;
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

	var bars: Array<Bitmap> = [];
	public var value(default, set) = 0.0;
	var boostEase = new EasedFloat(0, 0.4);

	public function new(?p, state: PlayState) {
		super(p);

		boostEase.easeFunction = M.elasticOut;

		this.state = state;

		frame = new ScaleGrid(hxd.Res.img.boostbarframe.toTile(),2,2, 4, 2, this);
		for (c in barColors) {
			var b = new Bitmap(Tile.fromColor(c), frame);
			b.x = b.y = padding;
			bars.push(b);
		}
	}
	
	var padding = 2.0;
	
	function set_value(v: Float) {
		boostEase.value = v;
		return value = v;
	}
	
	override function tick(dt:Float) {
		super.tick(dt);

		frame.width = width;
		frame.height = height;
		var v = boostEase.value;
		for (b in bars) {
			var s = v;
			s = Math.min(1, s);
			b.height = height - padding * 2;
			b.width = (width - padding * 2) * s;

			v -= 1;
			v = Math.max(0, v);
		}
	}
}