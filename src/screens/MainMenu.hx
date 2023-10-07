package screens;

import hxd.Key;
import h2d.RenderContext;
import gamestates.PlayState;
import h2d.Object;
import h2d.Text;
import elk.entity.Entity;

class MainMenu extends Entity {
	var title: Text;
	var container: Object;

	public var onStartDaily: Int -> Void;
	public var onStartRandom: Void -> Void; 
	
	var state: PlayState;
	var desc: Text;

	public function new(?p, state) {
		super(p);
		this.state = state;
		container = new Object(this);
		title = new Text(hxd.Res.fonts.gridgazer.toFont(), container);
		title.text = "Bill's\nCave of Numbers";
		title.y = 4;
		title.dropShadow = {
			dx: 0,
			dy: 2,
			color: 0x202e37,
			alpha: 1.0,
		};
		
		desc = new Text(hxd.Res.fonts.marumonica.toFont(), container);
		desc.text = "A Sudoku game for the adventurous";
		
		stext = new Text(hxd.Res.fonts.marumonica.toFont(), container);
		stext.text = "Click to Start";

		var s = SaveData.getCurrent();
		if (s.bestTime > 0) {
			var tt = s.bestTime.toTimeString(true);
			var ti = new Text(desc.font, container);
			ti.text = 'Personal Best\n${tt}';
			sbest = ti;
		}
	}

	var sbest: Text;
	var stext:Text;
	
	var closing = false;
	public function close() {
		closing = true;
	}
	
	var t = 0.0;

	override function tick(dt:Float) {
		super.tick(dt);
		t += dt;
		desc.y = title.y + 80;
		stext.y = 167 + desc.y;
		stext.x = 155 + desc.x;
		if (sbest != null) {
			sbest.y = 160 + desc.y;
			sbest.x = desc.x;
		}
		if (closing) {
			alpha *= 0.5;
			if (alpha < 0.1) {
				remove();
			}
		}
	}
	
	var started = false;
	override function sync(ctx:RenderContext) {
		super.sync(ctx);

		if (started) return;
		if (t < 0.2) return;

		if (Key.isPressed(Key.MOUSE_LEFT)) {
			started = true;
			state.start(Std.int(Math.random() * 50000000));
		}
	}
}