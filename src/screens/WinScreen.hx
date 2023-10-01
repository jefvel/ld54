package screens;

import h2d.Tile;
import h2d.Bitmap;
import elk.util.EasedFloat;
import h2d.Object;
import entities.BoostBar;
import elk.Elk;
import hxd.Key;
import elk.Timeout;
import h2d.Text;
import gamestates.PlayState;
import elk.entity.Entity;


class WinScreen extends Entity {
	var state : PlayState;
	var txt: Text;
	var bar: BoostBar;
	var timeTxt: Text;
	var timeval: Text;
	var container: Object;
	var easedTime = new EasedFloat(0, 0.6);
	var clickToReturn: Text;
	var m : hxd.snd.Channel;
	var bg: Bitmap;
	public function new(?p, state) {
		super(p);
		this.state = state;
		container = new Object(this);
		bg = new Bitmap(Tile.fromColor(0x10141f), container);
		Elk.instance.sounds.playSound(hxd.Res.sound.whiu, 0.5);
		txt = new Text(hxd.Res.fonts.gridgazer.toFont(), container);
		txt.text = "YOU WON";
		txt.textAlign = Center;
		txt.alpha = 0.0;
		new Timeout(0.8, showProgress);
		timeTxt = new Text(hxd.Res.fonts.marumonica.toFont(), container);
		timeTxt.text = "Time";
		timeval = new Text(timeTxt.font,timeTxt);
		timeval.textAlign = Right;
		timeTxt.alpha = 0;
		clickToReturn = new Text(timeTxt.font, container);
		clickToReturn.text = 'Click to Restart';
		clickToReturn.textAlign = Center;
		clickToReturn.alpha = 0;
		clickToReturn.visible = false;
		new Timeout(1.5, () -> {
			if (parent == null) return;
			m = elk.Elk.instance.sounds.playMusic(hxd.Res.sound.winmusic, 0.4);
		});
	}
	
	function showProgress() {
		bar = new BoostBar(this, state);
		bar.alpha = 0.0;
		bar.value = 0;
		bar.width = txt.textWidth;
		var tx = new Text(hxd.Res.fonts.marumonica.toFont(), bar);
		tx.text = 'Solve Progress';
		tx.y = -tx.textHeight - 4;
		new Timeout(0.3, () -> {
			var prog = state.board.solveProgress();
			bar.value = prog;
			new Timeout(0.3, showTime);
		});
	}

	var timevisibl = false;
	function showTime() {
		timevisibl = true;
		new Timeout(0.2,() -> easedTime.value = state.time);
		new Timeout(0.3, ()-> {
			clickToReturn.visible = true;
			canLeave = true;
		});
	}
	
	var canLeave = false;
	var left = false;
	
	function leave() {
		if (!canLeave || left) {
			return;
		}
		
		if (m != null) m.stop();
		left = true;
		Elk.instance.states.current = new PlayState();
		remove();
	}
	
	override function tick(dt:Float) {
		super.tick(dt);
		txt.alpha += (1-txt.alpha) * 0.1;
		if (bar != null) {
			bar.alpha += (1-bar.alpha) * 0.2;
		}
		if (timevisibl) {
			timeTxt.alpha += (1-timeTxt.alpha) * 0.2;
		}
		if (clickToReturn.visible) {
			clickToReturn.alpha += (1-clickToReturn.alpha) * 0.2;
		}
	}

	override function render() {
		super.render();
		var s = getScene();
		bg.width = s.width;
		bg.height = s.height;
		txt.x = s.width * 0.5;
		txt.y = s.height * 0.25 + (1 - txt.alpha) * 4.0;

		if (bar != null){
			bar.x = s.width * 0.5 - bar.width * 0.5;
			bar.y = txt.y + 80 + (1 - bar.alpha) * 4.0;
		}

		if (timevisibl){
			timeTxt.x = bar.x;
			timeTxt.y = bar.y + 32 + (1 - timeTxt.alpha) * 4.0;
			timeval.text = easedTime.value.toTimeString(true);
			timeval.x = bar.width;
		}

		if (clickToReturn.visible){
			clickToReturn.x = s.width * 0.5;
			clickToReturn.y = timeTxt.y + 48 + (1 - clickToReturn.alpha) * 4.0;
		}
		

		if (Key.isPressed(Key.MOUSE_LEFT)) {
			leave();
		}
	}
}