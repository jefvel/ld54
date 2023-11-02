package entities;
import elk.M;
import elk.util.EasedFloat;
import elk.Elk;
import hxd.Key;
import h2d.RenderContext;
import hxd.Rand;
import gamestates.PlayState;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Layers;
import CollisionHandler.CollisionObject;
import h2d.filter.Nothing;
import h2d.Object;
import elk.entity.Entity;

class OverWorld extends Entity {
	public var width = 1280 >> 1;
	public var height = 720 >> 1;

	public var world: Object;
	public var parts: Object;
	public var characterLayer: Layers;
	public var ladder: LilLadder;
	public var turret: Turret;
	public var man: SmallGuy;
	var handler: CollisionHandler;
	var objects: Array<CollisionObject>;
	public var running = false;
	public var enemies: Array<Enemy> = [];
	var mask: Graphics;
	var container: Object;
	var life = 100.0;
	var bg: Bitmap;
	var worldBg: Bitmap;
	public var visibleRange = 500.0;
	public var state: PlayState;
	var seed: Int;
	var rand: Rand;
	var dropRand: Rand;
	var dropList: Array<Int>;
	var originalDropList: Array<Int>;
	public function new(?p,state, seed) {
		super(p);
		rand = new Rand(seed);
		dropRand = new Rand(rand.random(0xffffffff));
		dropList = [];
		originalDropList = dropList.copy();
		this.seed = seed;

		this.state = state;
		alpha = 0.0;
		container = new Object(this);
		bg = new Bitmap(Tile.fromColor(0x000000), container);
		handler = new CollisionHandler();
		filter = new Nothing();
		world = new Object(container);
		characterLayer = new Layers(world);
		parts = new Object(world);
		mask = new Graphics(world);
		world.filter = new h2d.filter.Mask(mask, false);
		worldBg = new Bitmap(Tile.fromColor(0x10141f), world);

		ladder = new LilLadder(characterLayer);
		ladder.x = width * 0.5;
		ladder.y = height * 0.5 + 64;
		turret = new Turret(characterLayer, this);
		turret.x = width * 0.5;
		turret.y = height * 0.5;
		man = new SmallGuy(characterLayer, this);
		objects = [];
		objects.push(man);
		objects.push(ladder);
		objects.push(turret);
		
		ladder.button.onPush = e -> doReturn();
		offX.easeFunction = M.elasticOut;
		offY.easeFunction = M.elasticOut;
	}
	
	var waveTime = 5.0;
	var waveDuration = 5.0;
	
	function spawnEnemy(enemy: Enemy) {
		var e = enemy;
		var r = rand.rand() * Math.PI * 2;
		var ww = visibleRange + 16;
		if (activeSessionWaves == 0 && ww > 200) {
			ww *= 0.65;
		}
		e.x = width * 0.5 +  Math.cos(r) * ww;
		e.y = height * 0.5 +  Math.sin(r) * ww;
		enemies.push(e);
		objects.push(e);
	}

	var waves = 0;
	public function spawnWave() {
		waveTime = 0;
		waves ++;
		var spawnCount = 2;
		if(waves > 20){
			spawnCount ++;
		}
		if (waves > 25) {
			spawnCount ++;
		}
		if (waves > 50) {
			spawnCount ++;
		}

		if (waves > 90) {
			spawnCount ++;
		}

		if (waves > 100) {
			spawnCount += 4;
		}

		if (waves > 180) {
			spawnCount ++;
		}
		
		if (waves > 150) {
			spawnCount ++;
		}

		for(i in 0...spawnCount) {
			spawnEnemy(new SkullGuy(characterLayer, this));
		}

		if (waves > 30 && waves % 4 == 0) {
			spawnEnemy(new BlobGuy(characterLayer, this));
		}

		waveDuration -= 0.1; 
		if (waveDuration < 3) waveDuration = 3;

		activeSessionWaves ++;
	}
	
	var offX = new EasedFloat(0, 0.5);
	var offY = new EasedFloat(0, 0.5);
	public function onHurt(e: Enemy) {
		life -= e.revivePower * 4.0;
		var dx = e.x - man.x;
		var dy = e.y - man.y;
		var l = Math.sqrt(dx * dx + dy * dy);
		dx /= l;
		dy /= l;
		offX.setImmediate(dx * 4);
		offY.setImmediate(dy * 4);
		offX.value = 0;
		offY.value = 0;
	}
	
	public function onEnemyDie(e: Enemy) {
		removeEnemy(e);
		var reviveBoost = 1.0;
		if (turret.boost > 0.2) {
			reviveBoost += 0.2;
		}

		if (turret.boost >= 1.0) {
			reviveBoost += 0.8;
		}

		if (turret.boost > 2.5) {
			reviveBoost += 0.2;
		}
		
		reviveBoost += state.extraLifeUpgrades * 0.1;

		if (life < 75) {
			life += e.revivePower * reviveBoost * 0.8;
		}
		
		var extraDropChance = 0.0;
		extraDropChance += state.extraDropChanceUpgrades * 0.02;

		if (dropRand.rand() < e.dropChance + extraDropChance) {
			var l = 1;
			/*
			if (originalDropList.length > 19) {
				if (dropRand.rand() > 0.8) {
					l = 2;
					if (dropRand.rand() > 0.6) {
						l = 3;
					}
					if (dropRand.rand() > 0.8) {
						l = 4;
					}
				}
			}
			*/

			var magic = false;
			if (state.extraDropChanceUpgrades > 0 || state.extraFireRateUpgrades > 0 || state.extraLifeUpgrades > 0) {
				if (dropRand.rand() < e.dropChance * 0.5) {
					l = 1;
					magic = true;
				} else if (originalDropList.length < 20 && dropRand.rand() < e.dropChance * 0.7) {
					l = 1;
					magic = true;
				}
			}

			var vals = [];
			for (i in 0...l) {
				var v = getNextDigit();
				var tries = 0;
				while (vals.contains(v) && tries < 3) {
					v = getNextDigit();
					tries ++;
				}
				if (tries < 3) {
					vals.push(v);
				}
			}
			
			if (vals.length > 1) {
				for(t in vals) toPutInFront.push(t);
			}

			var t = new SudokuBullet(characterLayer, vals, true, magic);
			bulls.push(t);
			t.x = e.x;
			t.y = e.y - t.height * 0.5 - 3;
			t.onPress = onPush;
		}

		e.remove();
	}
	
	var bulls:Array<SudokuBullet> = [];
	var toPutInFront = [];
	
	function getNextDigit() {
		var d = 0;
		if (dropList.length > 0) {
			d = dropList.shift();
			if (dropList.length == 0) {
				dropList = originalDropList;
				dropRand.shuffle(dropList);
				dropRand.shuffle(toPutInFront);
				for (t in toPutInFront) {
					dropList.remove(t);
					dropList.insert(0, t);
				}
				originalDropList = dropList.copy();
			}
		} else {
			d = dropRand.random(9) + 1;
		}

		return d;
	}
	
	function doReturn() {
		if (!running) {
			return;
		}
		if (!ladder.enabled) {
			return;
		}

		var dx = man.x -ladder.x;
		var dy = man.y - ladder.y;
		if (Math.sqrt(dx * dx + dy * dy) > 100) {
			return;
		}

		running = false;
		turret.target = null;
		state.finishOverGround();
	}
	
	public var pickedUp: Array<SudokuBullet> = [];
	public function onPush(b: SudokuBullet) {
	}
	
	public function removeEnemy(e) {
		enemies.remove(e);
		objects.remove(e);
	}
	
	var activeSessionWaves = 0;
	public function start() {
		objects = [];
		enemies = [];
		toPutInFront = [];
		dropList = state.board.getDigitsLeft();
		dropRand.shuffle(dropList);
		originalDropList = dropList.copy();

		objects.push(man);
		objects.push(ladder);
		objects.push(turret);

		characterLayer.removeChildren();
		characterLayer.addChild(worldBg);
		characterLayer.addChild(ladder);
		characterLayer.addChild(man);
		characterLayer.addChild(turret);
		characterLayer.addChild(mask);
		
		turret.reset();
		for (p in bulls) p.remove();
		for (p in pickedUp) p.remove();
		bulls = [];
		pickedUp = [];

		man.x = ladder.x;
		man.y = ladder.y - 8;
		activeSessionWaves = 0;
		running = true;
		waveTime = waveDuration;
	}
	
	public var lost = false;
	public function onLose() {
		if (lost) return;
		running = false;
		lost = true;
		turret.paused = true;
		for (e in enemies) e.remove();
		man.dead = true;
		characterLayer.removeChild(man);
		man.remove();
		ladder.remove();
		for (b in bulls)b.remove();
		state.loseGame();
	}
	
	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		#if debug
		if (Key.isPressed(Key.K)) {
			life = 0.3;
		}
		#end
	}

	override function tick(dt:Float) {
		super.tick(dt);
		if (!running && !lost) {
			alpha *= 0.3;
			if (alpha < 0.05)  {
				visible = false;
				turret.remove();
				for(e in enemies) e.remove();
				man.remove();
			}
			return;
		}
		
		state.boostBar.value = turret.boost;
		
		ladder.enabled = pickedUp.length >= 1 && visibleRange > 55;
		
		life -= dt * 0.48;
		if (life <= 0) {
			life = 0;
			onLose();
		}

		mask.clear();

		var lr = (life / 100.0);
		visibleRange = width * 0.56 * lr;
		mask.beginFill(0xfffff);
		mask.drawCircle(width * 0.5, height * 0.5, visibleRange);
		mask.endFill();
		characterLayer.ysort(0);
		var s = getScene();
		bg.width = s.width;
		bg.height = s.height;
		worldBg.width = s.width;
		worldBg.height = s.height;
		worldBg.x = -world.x;
		worldBg.y = -world.y;

		visible = true;
		alpha += (1 - alpha) * 0.2;

		if (lost) {
			return;
		}

		handler.resolve(objects);
		
		var waveTimeSpeedUp = 1.0;
		if (enemies.length <= 1) {
			waveTimeSpeedUp = 10.0;
		}

		waveTime += dt * waveTimeSpeedUp;
		if (waveTime > waveDuration) {
			spawnWave();
		}

		world.x = Math.round((s.width - width) * 0.5 + offX.value);
		world.y = Math.round((s.height - height) * 0.5 + offY.value);
		
		var sx = 0.0;
		var sy = 0.0 - 12;
		if (man.sprite.scaleX < 0) {
			sx += 6;
		} else {
			sx -= 6;
		}
		
		for (b in bulls) {
			if (b.lifeTime < 1.0) {
				var dx = turret.x - b.x;
				var dy = turret.y - b.y;
				var l = Math.sqrt(dx * dx + dy * dy);
				if (l > visibleRange - 15) {
					var dl = l - visibleRange - 15;
					dx /= l;
					dy /= l;
					var sp = 0.09;
					dx *= dl * sp;
					dy *= dl * sp;
					b.x -= dx;
					b.y -= dy;
				}
			}

			var dx = b.x - man.x;
			var dy = b.y - man.y;
			var l = Math.sqrt(dx * dx + dy * dy);
			if (l < 32) {
				pickedUp.push(b);
				bulls.remove(b);
				man.addChildAt(b, 0);
				b.x -= man.x;
				b.y -= man.y;
				Elk.instance.sounds.playWobble(hxd.Res.sound.pickup);
			}
		}

		{
			var dx = turret.x - man.x;
			var dy = turret.y - man.y;
			var l = Math.sqrt(dx * dx + dy * dy);
			if (l > visibleRange) {
				var dl = l - visibleRange;
				dx /= l;
				dy /= l;
				var sp = 1.1;
				dx *= dl * sp;
				dy *= dl * sp;

				man.x += dx;
				man.y += dy;
			}
		}

		for (i in pickedUp) {
			var dx = sx - i.x;
			var dy = sy - i.y - i.height * 0.5;
			i.x += dx * 0.4;
			i.y += dy * 0.4;
			sx = i.x;
			sy = i.y ;
			sy -= i.height * 0.4;
		}
	}
}
