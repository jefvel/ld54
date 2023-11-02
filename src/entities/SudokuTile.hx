package entities;

import h2d.Bitmap;
import gamestates.PlayState;
import elk.Elk;
import hxd.Key;
import h2d.RenderContext;
import elk.entity.Entity;
import h2d.Interactive;
import h2d.Text;
import elk.graphics.Sprite;
import h2d.Object;

class SudokuTile extends Entity {
	var sprite: Sprite;
	var text: Text;
	var button: Interactive;
	public var value = -1;
	public var failed = false;
	public var presolved = false;
	public var onOver: SudokuTile -> Void;
	public var cellID = 0;
	
	public var bullet: SudokuBullet;
	public var row: Int;
	public var col: Int;
	
	public var solved = false;

	public var triedValues:Map<Int, Bool> = new Map();
	public var state: PlayState;
	
	var container: Object;

	var cross: Bitmap;
	var appearSpeed = 0.0;

	public function new(?p, value, presolved = false, row, col, state) {
		super(p);
		alpha = -6;
		appearSpeed = 0.01 + row * 0.01 + col * 0.005;
		container = new Object(this);

		this.state = state;
		this.presolved = presolved;
		this.solved = presolved;
		this.value = value;
		this.row = row;
		this.col = col;
		this.cellID = row * 9 + col;
		
		sprite = hxd.Res.img.sudokutile.toSprite(container);
		text = new Text(hxd.Res.fonts.futilepro_medium_12.toFont(), container);
		text.textAlign = Align.Center;
		text.dropShadow = {
			dy: -1,
			dx: 0, 
			alpha: 0.5,
			color: 0x202e37,
		}

		button = new Interactive(40, 40, container);
		button.onOver = e -> {
			onOver(this);
		}

		button.x = -4;
		button.y = -4;
		button.cursor = Default;
		updateSprite();
		cross = new Bitmap(hxd.Res.img.cross.toTile(), container);
		cross.y = -2;
		cross.tile.dx = cross.tile.dy = -16;
		cross.visible = false;
	}
	
	var appearing = false;
	public function appear() {
		appearing = true;
	}
	
	public function solve() {
		solved = true;
		updateSprite();
		// flash();

		var spr = hxd.Res.img.successpoof.toSprite(this);
		spr.originX = spr.originY = 20;
		spr.x = spr.y = 16;
		spr.animation.play("poof", false);
		spr.animation.onEnd = e -> spr.remove();
		if (bullet != null) {
			for (v in bullet.vals) {
				triedValues[v] = true;
			}
		}
	}

	public function poof() {
		Elk.instance.sounds.playWobble(hxd.Res.sound.poof, 0.1);
		var spr = hxd.Res.img.poof.toSprite(this);
		spr.originX = spr.originY = 16;
		spr.x = spr.y = 16;
		spr.animation.play("poof", false);
		spr.animation.onEnd = e -> spr.remove();
		if (bullet != null) {
			for (v in bullet.vals) {
				triedValues[v] = true;
			}
		}
	}
	
	var flashCol = 0.0;
	public function flash() {
		flashCol = 1.0;
	}
	
	override function tick(dt:Float) {
		super.tick(dt);
		if (appearing) {
			alpha += dt / appearSpeed;
			if (alpha > 1) {
				alpha = 1;
				appearing = false;
			}
			container.y = -(1 - alpha) * 4;
		}
		

		flashCol -= dt * 2.0;
		flashCol = Math.max(0.0, flashCol);
		var c = 1.0 + flashCol * 10.0;
		sprite.color.set(c, c, c);
		var crossVisible = false;
		var blocked = false;
		if (!solved && bullet == null) {
			if (state.man.selectedBrick != null) {
				var b = state.man.selectedBrick.vals;
				var v = true;
				for (val in b) {
					if (state.board.tileIsBlocked(col, row, val)) {
						blocked = true;
					}
					if (!triedValues.exists(val)) {
						v = false;
						break;
					}
				}
				crossVisible = v;
			}
		}
		
		if (!appearing) {
			alpha += ((blocked ? 0.3 : 1) - alpha) * 0.2;
		}

		if (crossVisible) {
			cross.alpha += (1 - cross.alpha) * 0.15;
			cross.visible = true;
		} else {
			cross.alpha *= 0.8;
			if (cross.alpha < 0.1) {
				cross.visible = false;
			}
		}
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		#if debug
		if (!solved) {
			text.visible = Key.isDown(Key.SHIFT);
		}
		#end
		text.y = Math.round((32 - text.textHeight) * 0.5);
	}
	
	public function updateSprite() {
		var textColor = 0xffffff;
		text.text = '$value';
		if (solved) {
			text.visible = true;
		} else {
			text.visible = false;
		}
		text.y = Math.round((32 - text.textHeight) * 0.5);
		text.x = 32 * 0.5;
		if (solved) {
			if (presolved) {
				sprite.animation.play("filled", false);
				textColor = 0x819796;
			} else if (failed) {
				sprite.animation.play("error", false);
			} else {
				sprite.animation.play("success");
				textColor = 0xa8ca58;
				text.y -= 1;
			}
		} else {
			sprite.animation.play("empty");
		}
		text.textColor = textColor;
	}
}