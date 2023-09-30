package entities;

import gamestates.PlayState;
import elk.Elk;
import elk.M;
import elk.util.EasedFloat;
import h2d.Interactive;
import h2d.Text;
import elk.graphics.Sprite;
import elk.entity.Entity;

class SudokuBullet extends Entity {
	var vals = [];
	public var onLanded: SudokuBullet -> Void;
	public var button:Interactive;
	public var small = false;
	public function new(?p, vals: Array<Int>, small = false) {
		super(p);
		this.vals = vals;
		this.small = small;
		if (small) {
			width = 16;
			height = 16;
		}
		buildSprite();
	}

	public var height = 32.0;
	public var width = 32.0;
	
	public var onSelect: SudokuBullet -> Void;
	
	public var target: SudokuTile;
	var startX = 0.0;
	var startY = 0.0;

	var targetX = 0.0;
	var targetY = 0.0;

	var fired = false;
	var rv = 0.0;
	var fireTime = new EasedFloat(0, 0.4);
	var fireDuration = 0.0;
	var hit = false;
	public var state: PlayState;
	public function fireAt(tile: SudokuTile) {
		if (fired) return;
		tile.bullet = this;
		parent.addChild(this);
		button.remove();
		fireTime.easeFunction = x -> x;
		fired = true;
		target = tile;

		startX = x;
		startY = y;
		var g = tile.getAbsPos();
		targetX = parent.x + g.x + 16;
		targetY = parent.y + g.y + 16;
		fireTime.value = 1.0;

		rv = Math.random() * 2 - 1.0;
	}
	
	public function hasValue(val) {
		return vals.contains(val);
	}
	
	function onHit() {
		if (hit) return;
		hit = true;
		onLanded(this);
		Elk.instance.sounds.playWobble(hxd.Res.sound.slide, 0.2);
	}
	
	var sps = [];
	var tt = 0.0;
	
	var lbl: Text;
	var ind = 0;
	
	var popped = false;
	
	override function tick(dt:Float) {
		super.tick(dt);
		if (!popped && Math.abs(x - targetX) < 10 && Math.abs(y - targetY) < 10) {
			Elk.instance.sounds.playWobble(hxd.Res.sound.pop, 0.3);
			popped = true;
		}
		if (hit) {
			rotation *= 0.6;
			for (s in sps) {
				s.y += (-16 - s.y) * 0.4;
				s.animation.currentFrameIndex = 0;
			}
			
			tt += dt;
			if (vals.length > 1) {
				var tt = vals.map(e -> '$e').join('|');
				lbl.text = tt;
				//ind = Std.int(tt / 1) % vals.length;
				//lbl.text = '${vals[ind]}';
			}
			x += (targetX - x) * 0.9;
			y += (targetY + state.board.offYEase.value - y) * 0.9;
			return;
		}
		if (fired) {
			rotation += rv;
			rotation %= Math.PI * 2;
			rv *= 0.92;
			var dx = targetX - startX;
			var dy = targetY - startY;
			var t = fireTime.value;
			x = startX + dx * t;
			y = startY + dy * t;
			y -= Math.sin(t * Math.PI) * 120;
			if (fireTime.value >= 0.98) {
				onHit();
			}
		}
	}

	function buildSprite() {
		var si = small ? 16.0 : 32.0;
		var totalHeight = vals.length * si;
		var totalWidth = si;
		width = totalWidth;
		height = totalHeight;
		var sx = -totalWidth * 0.5; 
		var sy = -totalHeight * 0.5;
		var l = vals.length;
		var font = hxd.Res.fonts.marumonica.toFont();
		for (i in 0...l) {
			var s: Sprite;
			if (!small) {
				s = hxd.Res.img.sutile.toSprite(this);
			} else {
				s = hxd.Res.img.tilesmall.toSprite(this);
			}
			s.x = sx;
			s.y = sy + si * i;
			var frame = 0;
			if (i == 0 && l > 1) {
				frame = 1;
			}
			
			if (i > 0) {
				if (i < l - 1) {
					frame = 2;
				} else {
					frame = 3;
				}
			}

			// s.animation.pause = true;
			s.animation.pause = true;
			s.animation.currentFrameIndex = frame;
			sps.push(s);

			var t = new Text(font, s);
			t.x = Math.round(si * 0.5);
			t.text = '${vals[i]}';
			t.y = Math.round((si - t.textHeight) * 0.5);
			t.textColor = 0x394a50;
			t.textAlign = Align.Center;
			lbl = t;
		}
		
		button = new Interactive(totalWidth, totalHeight, this);
		button.x = sx;
		button.y = -totalHeight * 0.5;
		button.onOver = e -> { 
			if (fired) return;
			if (onSelect != null) onSelect(this);
		};
		button.onPush = e -> {
			if (onPress != null) {
				onPress(this);
			}
		}
	}
	public var onPress: SudokuBullet -> Void;
}