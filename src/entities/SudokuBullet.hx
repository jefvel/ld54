package entities;

import h2d.Object;
import gamestates.PlayState;
import elk.Elk;
import elk.M;
import elk.util.EasedFloat;
import h2d.Interactive;
import h2d.Text;
import elk.graphics.Sprite;
import elk.entity.Entity;

class SudokuBullet extends Entity {
	public var vals = [];
	public var onLanded: SudokuBullet -> Void;
	public var button:Interactive;
	public var small = false;
	public var isMagic = false;
	var wrapper: Object;
	public function new(?p, vals: Array<Int>, small = false, isMagic = false) {
		super(p);
		this.isMagic = isMagic;
		this.vals = vals;
		this.small = small;
		wrapper =new Object(this);
		if (small) {
			width = 16;
			height = 16;
		}
		buildSprite();
		bounceT.easeFunction = M.bounceOut;
		if (small) {
			bounceT.setImmediate(-5);
			bounceT.value = 0.0;
		}
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
	public var lifeTime = 0.0;
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
		targetX = -parent.x + g.x + 16;
		targetY = -parent.y + g.y + 16;
		fireTime.value = 1.0;

		rv = Math.random() * 2 - 1.0;
	}
	
	public var discarded = false;
	var discardTime = 0.0;
	var bounceT = new EasedFloat();
	public function discard() {
		discarded = true;
		vx = Math.random() * 100 - 50;
		vy = -Math.random() * 24 - 15;
		rv = Math.random() * 1 - 0.5;
		friction = 0.0;
		button.visible = false;
	}
	
	public function hasValue(val) {
		return vals.contains(val);
	}
	
	function onHit() {
		if (hit) return;
		hit = true;

		if (isMagic && hasValue(target.value)) {
			for (i in 0...(1+state.board.rand.random(2))){
				var t = state.board.getRandomFreeTile();
				if (t != null) {
					var b = new SudokuBullet(state.world, [t.value], false, false);
					b.x = x;
					b.y = y;
					b.fireAt(t);
					b.state = state;
					b.onLanded = onLanded;
					state.firedBullets.push(b);
				}
			}
		}

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
		lifeTime += dt;
		if (small) {
			wrapper.y = bounceT.value;
		}
		if (discarded) {
			discardTime += dt;
			vy += 30.3;
			// vx *= 0.99;
			rv *= 0.9;
			if (discardTime > 2.0) {
				alpha *= 0.6;
				if (alpha < 0.1) {
					remove();
				}
			}
			rotation += rv;
			return;
		}
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
		var sih = small ? 20.0 : 32;
		var totalHeight = vals.length * sih;
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
				if (!isMagic) {
					s = hxd.Res.img.sutile.toSprite(wrapper);
				} else {
					s = hxd.Res.img.magictile.toSprite(wrapper);
				}
			} else {
				if (!isMagic) {
					s = hxd.Res.img.tilesmall.toSprite(wrapper);
				} else {
					s = hxd.Res.img.magictilesmall.toSprite(wrapper);
				}
			}
			s.x = sx;
			s.y = sy + sih * i;
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
			t.y = Math.round((sih - t.textHeight) * 0.5);
			t.textColor = 0x394a50;
			if (isMagic) {
				t.textColor = 0xdf84a5;
			}
			t.textAlign = Align.Center;
			lbl = t;
		}
		if (!small) {
		
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
	}
	public var onPress: SudokuBullet -> Void;
}