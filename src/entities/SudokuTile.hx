package entities;

import hl.I64;
import elk.entity.Entity;
import h2d.Interactive;
import h2d.Text;
import elk.graphics.Sprite;
import h2d.Object;

class SudokuTile extends Object {
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

	public function new(?p, value, presolved = false, row, col) {
		super(p);
		this.presolved = presolved;
		this.solved = presolved;
		this.value = value;
		this.row = row;
		this.col = col;
		this.cellID = row * 9 + col;
		
		sprite = hxd.Res.img.sudokutile.toSprite(this);
		text = new Text(hxd.Res.fonts.marumonica.toFont(), this);
		text.textAlign = Align.Center;

		button = new Interactive(40, 40, this);
		button.onOver = e -> {
			onOver(this);
		}

		button.x = -4;
		button.y = -4;
		button.cursor = Default;
		updateSprite();
	}
	
	public function solve() {
		solved = true;
		updateSprite();
	}
	
	
	function updateSprite() {
		var textColor = 0xffffff;
		if (solved) {
			text.text = '$value';
		} else {
			text.text = '';
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