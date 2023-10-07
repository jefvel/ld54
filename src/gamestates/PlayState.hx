package gamestates;

import screens.WinScreen;
import hxd.Rand;
import screens.MainMenu;
import screens.GameOverScreen;
import elk.Timeout;
import entities.BoostBar;
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
	public var time = 0.;
	var timeText: Text;
	var tickRateTxt: Text;
	
	public var board: SudokuBoard;
	var bricks: CollectedBullets;
	
	var bg: Interactive;
	var bgRect: Bitmap;
	var container: Object;

	public var world: Object;
	var seed: Int;
	
	public var man: Guy;
	// var selectedBrick: SudokuBullet;
	
	public var ladder: Ladder;
	public var boostBar: BoostBar;
	
	public var aiming = false;
	var graphics:Graphics;
	
	public var overworld: OverWorld;
	
	var caveMusic: hxd.snd.Channel;
	var overworldMusic: hxd.snd.Channel;

	function onSelectBrick(brick: SudokuBullet) {
		if (aiming) return;
		man.selectedBrick = brick;
		overBull = true;
	}
	
	var overBull = false;

	function onDeselectBrick(brick: SudokuBullet) {
		//if (aiming) return;
		overBull = false;
	}
	
	var crosshair: ScaleGrid;
	var hoveredCell: SudokuTile;
	
	public var isDailyChallenge = false;

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
	
	function onOutOfCell(cell: SudokuTile) {
		
	}

	public function new(?seed:Int) {
		super();

		seed = Std.int(Math.random() * 1000000);
		if (seed == null){
			var d = Date.now();
			this.seed = ((d.getFullYear() - 2023) * 500) + (d.getMonth() * 40) + d.getDay();
		} else {
			this.seed = seed;
		}
		crosshairX.easeFunction = M.elasticOut;
		crosshairY.easeFunction = M.elasticOut;
	}
	
	
	public var started = false;
	override function onEnter() {
		super.onEnter();
		
		//sy.easeFunction = elk.T.elasticOut;

		tickRateTxt = new Text(hxd.Res.fonts.marumonica.toFont(), s2d);
		tickRateTxt.textColor = 0xffffff;
		
		// s2d.filter = new DropShadow(4, 0.785, 0, 1, 0, 1, 0);
		
		s2d.filter = new Nothing();
		s2d.filter = new RetroFilter(0.0, 0.04, 0.1, 1.0);

		container = new Object(s2d);
		bgRect = new Bitmap(Tile.fromColor(0x10141f), container);
		bg = new Interactive(1, 1, container);
		bg.cursor = Default;
		bg.onOver = (e) ->{
			onSelectBrick(null);
			onHoverCell(null);
		}

		world = new Object(container);
		board = new SudokuBoard(world, this);
		
		board.x = 110;
		board.y = 22;
		board.onOverCell = onHoverCell;
		board.onOutOfCell = onOutOfCell;
		
		ladder = new Ladder(world);
		bricks = new CollectedBullets(world);
		man = new Guy(world, this);
		
		bricks.y = board.y - board.padding + 64;
		bricks.x = board.x + board.width + 32;
		bricks.onSelect = onSelectBrick;
		bricks.onDeselect = onDeselectBrick;
		
		man.x = bricks.x + 64;
		man.y = bricks.y + 32;
		
		ladder.x = bricks.x + 20;
		ladder.y = man.y - 56;
		ladder.onPush = goOverGround;

		graphics = new Graphics(world);
		crosshair = new ScaleGrid(hxd.Res.img.crosshair.toTile(), 16,16, 16, 16, world);
		
		overworld = new OverWorld(container, this, this.seed);
		
		timeText = new Text(hxd.Res.fonts.marumonica.toFont(), container);
		timeText.alpha = 0;
		extraBonusText = new Text(hxd.Res.fonts.marumonica.toFont(), timeText);
		extraBonusText.y = 32;
		boostBar = new BoostBar(container, this);
		boostBar.alpha = 0;
		mainMenu = new MainMenu(container, this);
	}
	
	public var mainMenu: MainMenu;


	var generating = false;
	var rand: Rand;
	public function start(seed: Int) {
		if (generating || started) return;
		rand = new Rand(seed + 2);
		generating = true;
		board.generate(seed);
	}

	var generationDone = false;
	function onGenerated() {
		if (started) return;
		if (generationDone) return;

		generationDone = true;

		new Timeout(0.15, () -> {
			caveMusic = game.sounds.playMusic(hxd.Res.sound.musiccave, 0.3);
			overworldMusic = game.sounds.playMusic(hxd.Res.sound.overworld, 0.0);
			started = true;
			generating = false;
			wscl.value = 1.0;
			lookRatio.value = 1.0;
			mainMenu.close();

			board.makeAppear();
			
			var f = board.getDigitsLeft();
			rand.shuffle(f);
			for (i in 0...3) {
				bricks.addBrick(new SudokuBullet(world, [f[i]], false));
			}
			if (bricks.empty) {
				startChecking();
			}
		});
	}
	
	var overGroundTime = 0.0;
	var overGround = false;
	var checked = false;
	function goOverGround() {
		overGround = true;
		overGroundTime = 0.0;
		man.climb();
		overworld.turret.boost = turretBoost;
		ladder.enabled = false;
		overworldMusic.fadeTo(0.2, 0.2);
		caveMusic.fadeTo(0.0, 0.2);
	}
	
	public function finishOverGround() {
		overGround = false;
		checked = false;
		man.onLadder = false;
		man.climbing = false;
		man.y = ladder.y + 8;
		landedBullets = 0;
		var p = overworld.pickedUp;
		game.sounds.playWobble(hxd.Res.sound.climbdown);
		for (pik in p) {
			var b = new SudokuBullet(world, pik.vals, false, pik.isMagic);
			bricks.addBrick(b);
		}

		world.addChild(man);

		if (bricks.empty) {
			startChecking();
		}
	}
	
	var overworldMusicOn = false;
	
	override function onRemove() {
		container.remove();
		super.onRemove();
		stopMusic();
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
		if (!started && generating) {
			onGenerated();
		}

		if (overGround){
 			if (man.onLadder) {
				overGroundTime += dt;
			}
			if (overGroundTime > 0.5){
				world.alpha *= 0.8;
			}
		} else {
			world.alpha += (1 - world.alpha) * 0.1;
			discardUnusableBricks();
		}
		
		if (overGround && overworld.running && !overworldMusicOn) {
			caveMusic.fadeTo(0.0, 0.2);
			overworldMusic.fadeTo(0.3, 0.2);
			overworldMusicOn = true;
		}
		if (!overGround && overworldMusicOn) {
			caveMusic.fadeTo(0.3, 0.2);
			overworldMusic.fadeTo(0.0, 0.2);
			overworldMusicOn = false;
		}

		if (aiming) {
			if (man.selectedBrick == null) {
				stopAiming();
			}
			crosshairAlpha.value = 1.0;
			if (hoveredCell != null) {
				crosshairWidth.value = 40;
				var v = crosshairWidth.value;
				var pos = hoveredCell.getAbsPos();
				pos.x -= world.x;
				pos.y -= world.y;

				crosshairX.value = pos.x + 16 - v * 0.5;
				crosshairY.value = pos.y + 16 - v * 0.5;

				crosshair.width = v;
				crosshair.height = v - 1;
			} else {
				crosshairWidth.value = 32;
				var v = crosshairWidth.value;
				crosshairX.value = (game.s2d.mouseX - world.x - v * 0.5);
				crosshairY.value = (game.s2d.mouseY - world.y - v * 0.5);
				crosshair.width = crosshair.height = v;
			}
		} else {
			crosshairAlpha.value = 0.0;
		}
	}
	

	function doKick() {
		var selectedBrick = man.selectedBrick;
		if (hoveredCell != null && selectedBrick != null) {
			man.kick();
			selectedBrick.fireAt(hoveredCell);
			bricks.removeBullet(selectedBrick);
			firedBullets.push(selectedBrick);
			selectedBrick.state = this;
			selectedBrick.onLanded = onLand;
		}

		stopAiming();
	}
	
	function stopAiming() {
		hoveredCell = null;
		if (!overBull) {
			man.selectedBrick = null;
			aiming = false;
		}
	}
	
	function startAiming() {
		if (man.selectedBrick != null) {
			aiming = true;
			world.addChild(graphics);
			world.addChild(crosshair);
		}
	}
	
	public var firedBullets: Array<SudokuBullet> = [];
	var landedBullets = 0;
	var checking = false;
	var untilCheckNext = 0.5;
	function onLand(bull: SudokuBullet) {
		landedBullets ++;
		board.nudge();
		if (bricks.empty && landedBullets >= firedBullets.length) {
		}
	}
	
	function startChecking(){
		if (checking || checked) return;
		checking = true;
		correctTiles = 0;
		untilCheckNext = 1.0;
		turretBoost = overworld.turret.boost;
	}
	
	function onCellClear(cell: SudokuTile) {
		if (board.isRowClear(cell.row)) {
			for (c in 0...9) {
				board.getTileAt(cell.row, c).flash();
			}

			extraFireRateUpgrades ++;
			overworld.turret.firerateMultiplier += 0.08;
		}

		if (board.isColClear(cell.col)) {
			for (c in 0...9) {
				board.getTileAt(c, cell.col).flash();
			}

			extraDropChanceUpgrades ++;
		}

		if (board.isBlockClear(cell.row, cell.col)) {
			var sx = Std.int(cell.col / 3);
			var sy = Std.int(cell.row / 3);
			for (r in 0...3) {
				for (c in 0...3) {
					board.getTileAt(sy * 3 + r, sx * 3 + c).flash();
				}
			}
			
			extraLifeUpgrades ++;

		}
	}
	
	var correctTiles = 0;
	var turretBoost = 0.0;
	function checkNext() {
		untilCheckNext = 0.07;
		if (firedBullets.length > 0) {
			var b = firedBullets.shift();
			var cell = b.target;
			var correct = b.hasValue(cell.value);
			if (correct) {
				board.setVal(cell.row, cell.col, cell.value);
				var vols = [
					0.4,
					0.45,
					0.5,
					0.53,
				];
				var sounds = [
					hxd.Res.sound.goodhit,
					hxd.Res.sound.goodhit2,
					hxd.Res.sound.goodhit3,
					hxd.Res.sound.goodhit4,
				];

				var perSound = 3;
				var i = Std.int(correctTiles / perSound);
				if (i >= sounds.length) i = sounds.length - 1;
				var sound = sounds[i];
				var pitch = correctTiles - i * perSound;

				game.sounds.playSoundPitch(sound, vols[i], 1.0 + pitch * 0.25);
				correctTiles ++;

				var b = 0.5 + correctTiles * 0.05;
				turretBoost += b;
				if (turretBoost > 6) {
					turretBoost = 6;
				}
				boostBar.value = turretBoost;

				cell.solve();
				board.nudge();
				
				onCellClear(cell);

			} else {
				cell.poof();
			}
			cell.bullet = null;
			b.remove();
		} else {
			checking = false;
			checked = true;
			if (board.isSolved()) {
				winGame();
			} else {
				ladder.enabled = true;
			}
		}
	}
	
	public function winGame() {
		if (won) return;
		stopMusic();
		bricks.discardCards();
		boostBar.visible = false;
		timeText.visible = false;
		running = false;
		won = true;
		new Timeout(0.6, _flashAll);
	}

	function _flashAll() {
		board.nudge();
		for(c in board.tiles) {
			c.presolved = true;
			c.solved = true;
			c.updateSprite();
			c.flash();
			game.sounds.playWobble(hxd.Res.sound.winboom);
		}
		new Timeout(2.0, _showWin);
	}
	var winScreen: WinScreen;
	function _showWin() {
		winScreen = new WinScreen(container, this);
	}
	
	function stopMusic() {
		if (caveMusic != null) {
			caveMusic.stop();
		}
		if (overworldMusic != null) {
			overworldMusic.stop();
		}
	}

	public var won = false;
	public var lost = false;
	public function loseGame() {
		if (lost) {
			return;
		}
		stopMusic();
		lost = true;
		running = false;
		timeText.visible = false;
		boostBar.visible = false;
		new Timeout(1.8, showRestart);
	}
	
	var gameover: GameOverScreen;
	function showRestart() {
		gameover = new GameOverScreen(container, this);
	}
	

	function discardUnusableBricks() {
		if (bricks.empty) {
			return;
		}
		
		if (board.freeCellCount() == 0) {
			bricks.discardCards();
			return;
		}

		var digs = board.getDigitsLeft(true);
		var dig = [];
		for (d in digs) {
			if (!dig.contains(d)) {
				dig.push(d);
			}
		}
		if (dig.length == 0) {
			dig = null;
		}

		bricks.discardCards(dig);
	}
	
	
	var running = true;

	var wscl = new EasedFloat(2.0, 0.8);
	var lookRatio = new EasedFloat(0.0, 1.2);
	
	public var extraFireRateUpgrades = 0;
	public var extraLifeUpgrades = 0;
	public var extraDropChanceUpgrades = 0;
	var extraBonusText: Text;

	override function update(dt:Float) {
		super.update(dt);
		timeText.x = world.x + board.x - 90;
		timeText.y = world.y + board.y;
		if (!started) {
			var b = board.getAbsPos();
			mainMenu.y = b.y;
			mainMenu.x = b.x + board.width * wscl.value - 240;
		}

		var bbx = world.x + board.x - 90;
		var bby =  world.y + board.y + board.height - boostBar.height;
		if (overworld.running) {
			bbx = overworld.turret.x + overworld.world.x - boostBar.width * 0.5;
			bby = overworld.turret.y + overworld.world.y - 64;
			if (boostBar.value <= 0) {
				boostBar.alpha *= 0.8;
			}
		} else if(started) {
			boostBar.alpha += (1 - boostBar.alpha) * 0.2;
		}

		boostBar.x += (bbx - boostBar.x) * 0.1;
		boostBar.y += (bby - boostBar.y) * 0.1;
		
		if (Key.isPressed(Key.R)) {
			game.states.current = new PlayState(Std.int(Math.random() * 1201023));
			return;
		}
		
		#if debug
		if (Key.isPressed(Key.W)) {
			winGame();
		}
		#end

		if (started && running) {
			time += dt;
			timeText.alpha += (1 - timeText.alpha) * 0.1;
			// boostBar.alpha += (1 - boostBar.alpha) * 0.1;
		}
		
		timeText.text = time.toTimeString(true);
		var bns = '';
		if (extraDropChanceUpgrades > 0) {
			bns += 'Drop Chance\n -- Lv. $extraDropChanceUpgrades\n';
		}
		if (extraFireRateUpgrades > 0) {
			bns += 'Firerate+DMG\n -- Lv. $extraFireRateUpgrades\n';
		}
		if (extraLifeUpgrades > 0) {
			bns += 'Life Regen\n -- Lv. $extraLifeUpgrades\n';
		}
		extraBonusText.text = bns;
		
		if (started) {
			if (bricks.empty) {
				startChecking();
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
		}
		
		crosshair.alpha = crosshairAlpha.value;
		crosshair.x = crosshairX.value;
		crosshair.y = crosshairY.value;
		graphics.clear();

		var selectedBrick = man.selectedBrick;
		if (selectedBrick != null && aiming && hoveredCell != null) {
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

		var scl = wscl.value;
		world.setScale(scl);
		var rr = lookRatio.value;

		world.x = M.mix(
			s.width * 0.7 - (man.x) * scl, 
			Math.round((s.width - containerWidth) * 0.5),
			rr
		);
		
		world.y = M.mix(
			s.height * 0.5 - (man.y - 32) * scl,
			Math.round((s.height - containerHeight) * 0.5),
			rr
		);

		
		if (Key.isPressed(Key.MOUSE_LEFT)) {
			if (started) {
				startAiming();
			}
		}
		
		if (aiming && Key.isReleased(Key.MOUSE_LEFT)) {
			doKick();
		}
	}
}
