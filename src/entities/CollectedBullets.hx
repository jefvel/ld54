package entities;

import hxd.Key;
import h2d.Tile;
import h2d.Bitmap;
import elk.entity.Entity;

class CollectedBullets extends Entity {
	public var bricks:Array<SudokuBullet> = [];

	public var onSelect:SudokuBullet -> Void;
	
	public var empty(get, null): Bool;
	function get_empty(){
		return bricks.length == 0;
	}

	public function new(?p) {
		super(p);


		addRandomBrick();
		/*
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		addRandomBrick();
		*/
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
	public function discardCards(?filter: Array<Int>) {
		for(b in bricks) {
			if (b.target != null) {
				continue;
			}
			
			var doDiscard = true;
			if (filter != null) {
				for (i in filter) {
					if (b.hasValue(i)) {
						doDiscard = false;
					}
				}
			}

			if (doDiscard) {
				b.discard();
				bricks.remove(b);
			}
		}
	}

	override function render() {
		super.render();
		#if debug
		if(Key.isDown(Key.D)) {
			discardCards();	
		}
		if (Key.isPressed(Key.C)) {
			addRandomBrick();
		}
		#end
	}
	
	override function tick(dt:Float) {
		super.tick(dt);
		var sy = 0.0;
		var sx = 0.0;
		for (i in 0...bricks.length) {
			var b = bricks[i];
			if (sy + b.height > 256) {
				sy = 0;
				sx += 36;
			}
			b.y += (y + sy + b.height * 0.5 - b.y) * 0.2;
			b.x += (x + 16 + sx - b.x) * 0.2;

			sy += b.height + 6;
		}
	}
}