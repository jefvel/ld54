package entities;

import h2d.Tile;
import h2d.Bitmap;
import elk.entity.Entity;

class CollectedBullets extends Entity {
	public var bricks = [];

	public var onSelect:SudokuBullet -> Void;
	
	public var empty(get, null): Bool;
	function get_empty(){
		return bricks.length == 0;
	}

	public function new(?p) {
		super(p);

		addRandomBrick();
		//addRandomBrick();
		//addRandomBrick();
		//addRandomBrick();
		//addRandomBrick();
		//addRandomBrick();
		
	}
	
	public function addRandomBrick() {
		var l = 1;
		if (Math.random() > 0.8) {
			l = 2;
			if (Math.random() > 0.6) {
				l = 3;
			}
			if (Math.random() > 0.8) {
				l = 4;
			}
		}
		var vals = [];
		for (i in 0...l) {
			vals.push(Std.int(Math.random() * 9) + 1);
		}
		
		var b = new SudokuBullet(this, vals);
		addBrick(b);
	}
	
	function onSelectedBullet(b: SudokuBullet) {
		onSelect(b);
	}
	
	public function removeBullet(b) {
		bricks.remove(b);
	}
	
	public function addBrick(b: SudokuBullet) {
		b.onSelect = onSelectedBullet;
		parent.addChild(b);
		bricks.push(b);
	}
	
	override function tick(dt:Float) {
		super.tick(dt);
		var sy = 0.0;
		for (i in 0...bricks.length) {
			var b = bricks[i];
			b.y =y + sy + b.height * 0.5;
			b.x = x+ 16;
			sy += b.height + 6;
		}
	}
}