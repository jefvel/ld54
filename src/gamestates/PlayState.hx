package gamestates;

import entities.OverWorld;
import entities.Ladder;
import h2d.Graphics;
import elk.M;
import elk.util.EasedFloat;
import h2d.ScaleGrid;
import entities.SudokuTile;
import h2d.Interactive;
import entities.SudokuBullet;
import entities.Guy;
import entities.CollectedBullets;
import h2d.Object;
import entities.SudokuBoard;
import h2d.filter.Nothing;
import elk.graphics.filter.RetroFilter;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Text;
import hxd.Key;
import elk.gamestate.GameState;

class PlayState extends GameState {
	var time = 0.;
	var tickRateTxt: Text;
	var filt: hxd.snd.effect.Pitch;
	
	public var board: SudokuBoard;
	var bricks: CollectedBullets;
	
	var bg: Interactive;
	var bgRect: Bitmap;
	var container: Object;

	var world: Object;
	var seed: Int;
	
	var man: Guy;
	var selectedBrick: SudokuBullet;
	
	public var ladder: Ladder;
	
	var aiming = false;
	var graphics:Graphics;
	
	public var overworld: OverWorld;

	function onSelectBrick(brick: SudokuBullet) {
		if (aiming) return;
		selectedBrick = brick;
		man.selectedBrick = brick;
	}
	
	var crosshair: ScaleGrid;
	var hoveredCell: SudokuTile;

	function onHoverCell(cell: SudokuTile) {
		if (!aiming) return;
		if (cell == null) {
			hoveredCell = null;
		} else if (cell.solved || cell.bullet != null) {
			hoveredCell = null;
			return;
		}
		
		hoveredCell = cell;
		game.sounds.playWobble(hxd.Res.sound.select2, 0.1);
	}

	public function new(?seed:Int) {
		super();
		filt = new hxd.snd.effect.Pitch();
		game.sounds.sfxChannel.addEffect(filt);
		

		if (seed == null){
			var d = Date.now();
			this.seed = ((d.getFullYear() - 2023) * 500) + (d.getMonth() * 40) + d.getDay();
		} else {
			this.seed = seed;
		}
		crosshairX.easeFunction = M.elasticOut;
		crosshairY.easeFunction = M.elasticOut;
	}
	
	override function onEnter() {
		super.onEnter();
		
		//sy.easeFunction = elk.T.elasticOut;

		tickRateTxt = new Text(hxd.Res.fonts.marumonica.toFont(), s2d);
		tickRateTxt.textColor = 0xffffff;
		
		// s2d.filter = new DropShadow(4, 0.785, 0, 1, 0, 1, 0);
		
		s2d.filter = new Nothing();
		s2d.filter = new RetroFilter(0.05, 0.04, 0.1, 0.9);

		container = new Object(s2d);
		bgRect = new Bitmap(Tile.fromColor(0x10141f), container);
		bg = new Interactive(1, 1, container);
		bg.cursor = Default;
		bg.onOver = (e) ->{
			onSelectBrick(null);
			onHoverCell(null);
		}

		world = new Object(container);
		board = new SudokuBoard(world);
		
		board.generate(seed);
		board.x = 110;
		board.y = 22;
		board.onOverCell = onHoverCell;
		
		ladder = new Ladder(world);
		man = new Guy(world, this);
		
		bricks = new CollectedBullets(world);
		bricks.y = board.y - board.padding + 64;
		bricks.x = board.x + board.width + 32;
		bricks.onSelect = onSelectBrick;
		
		man.x = bricks.x + 64;
		man.y = bricks.y + 32;
		
		ladder.x = bricks.x + 20;
		ladder.y = man.y - 56;
		ladder.onPush = goOverGround;

		graphics = new Graphics(world);
		crosshair = new ScaleGrid(hxd.Res.img.crosshair.toTile(), 16,16, 16, 16, world);
		
		overworld = new OverWorld(container);
	}
	
	var overGroundTime = 0.0;
	var overGround = false;
	function goOverGround() {
		overGround = true;
		overGroundTime = 0.0;
		man.climb();
		ladder.enabled = false;
	}
	
	override function onRemove() {
		container.remove();
		super.onRemove();
	}
	
	function updateCamBounds() {
		if (game.s3d.camera.orthoBounds == null) {
			return;
		}

		var b = game.s3d.camera.orthoBounds;
		b.xMin = 0;
		b.xMax = game.s2d.width;

		b.yMax = game.s2d.height;
		b.yMin = 0;

		b.zMin = -4000;
		b.zMax = 4000;

		game.s3d.camera.update();
	}
	
	
	var crosshairAlpha = new EasedFloat();
	var crosshairWidth = new EasedFloat(16.0, 0.4);
	var crosshairX = new EasedFloat();
	var crosshairY = new EasedFloat();
	override function tick(dt:Float) {
		super.tick(dt);
		if (overGround){
 			if (man.onLadder) {
				overGroundTime += dt;
			}
			if (overGroundTime > 0.5){
				world.alpha *= 0.8;
			}
		}
		if (aiming) {
			crosshairAlpha.value = 1.0;
			if (hoveredCell != null) {
				crosshairWidth.value = 40;
				var v = crosshairWidth.value;
				var pos = hoveredCell.getAbsPos();
				pos.x += world.x;
				pos.y += world.y;

				crosshairX.value = pos.x + 16 - v * 0.5;
				crosshairY.value = pos.y + 16 - v * 0.5;

				crosshair.width = v;
				crosshair.height = v;
			} else {
				crosshairWidth.value = 32;
				var v = crosshairWidth.value;
				crosshairX.value = (game.s2d.mouseX - v * 0.5);
				crosshairY.value = (game.s2d.mouseY - v * 0.5);
				crosshair.width = crosshair.height = v;
			}
		} else {
			crosshairAlpha.value = 0.0;
		}
	}
	

	function doKick() {
		if (hoveredCell != null) {
			man.kick();
			selectedBrick.fireAt(hoveredCell);
			bricks.removeBullet(selectedBrick);
			firedBullets.push(selectedBrick);
			selectedBrick.state = this;
			selectedBrick.onLanded = onLand;
		}

		hoveredCell = null;
		selectedBrick = null;
		aiming = false;
	}
	
	function startAiming() {
		if (selectedBrick != null) {
			aiming = true;
			world.addChild(graphics);
			world.addChild(crosshair);
		}
	}
	
	var firedBullets: Array<SudokuBullet> = [];
	var landedBullets = 0;
	var checking = false;
	var untilCheckNext = 0.5;
	function onLand(bull: SudokuBullet) {
		landedBullets ++;
		board.nudge();
		if (bricks.empty && landedBullets == firedBullets.length) {
			trace('wow emptied queue');
			checking = true;
			untilCheckNext = 1.0;
		}
	}
	
	var correctTiles = 0;
	function checkNext() {
		untilCheckNext = 0.07;
		if (firedBullets.length > 0) {
			var b = firedBullets.shift();
			var cell = b.target;
			var correct = b.hasValue(cell.value);

			if (correct) {
				board.setVal(cell.row, cell.col, cell.value);
				game.sounds.playSoundPitch(hxd.Res.sound.goodhit, 0.3, 1.0 + correctTiles * 0.25);
				correctTiles ++;
				cell.solve();
				board.nudge();
			}

			b.remove();
		} else {
			checking = false;
			ladder.enabled = true;
		}
	}
	
	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		
		if (Key.isPressed(Key.R)) {
			game.states.current = new PlayState(Std.int(Math.random() * 1201023));
			return;
		}
		
		if (checking) {
			untilCheckNext -= dt;
			if (untilCheckNext <= 0) checkNext();
		}
		
		if (man.onLadder && man.y < 30) {
			if (!overworld.running) {
				overworld.start();
			}
		}
		
		crosshair.alpha = crosshairAlpha.value;
		crosshair.x = crosshairX.value;
		crosshair.y = crosshairY.value;
		graphics.clear();

		if (aiming && hoveredCell != null) {
			var cx = crosshairWidth.value * 0.5 + crosshair.x;
			var cy = crosshairWidth.value * 0.5 + crosshair.y;
			graphics.lineStyle(2, 0xebede9, 0.6);
			graphics.moveTo(selectedBrick.x - 20, selectedBrick.y);
			graphics.curveTo(
				(selectedBrick.x + cx) * 0.5 , Math.min(selectedBrick.y, cy) - 64.0, 
				cx, cy 
			);
		}
		
		updateCamBounds();
		var s = s2d.getScene();
		bg.width = s.width;
		bg.height = s.height;
		bgRect.width= bg.width;
		bgRect.height= bg.height;
		var containerWidth = 1280 * 0.5;
		var containerHeight = 720 * 0.5;
		world.x = Math.round((s.width - containerWidth) * 0.5);
		world.y = Math.round((s.height - containerHeight) * 0.5);
		
		if (Key.isPressed(Key.MOUSE_LEFT)) {
			startAiming();
		}
		
		if (aiming && Key.isReleased(Key.MOUSE_LEFT)) {
			doKick();
		}
	}
}
