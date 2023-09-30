package entities;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Layers;
import CollisionHandler.CollisionObject;
import h2d.filter.Nothing;
import h2d.Object;
import elk.graphics.Sprite;
import elk.entity.Entity;


class OverWorld extends Entity {
	var width = 1280 >> 1;
	var height = 720 >> 1;
	public var world: Layers;
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
	public function new(?p) {
		super(p);
		alpha = 0.0;
		container = new Object(this);
		bg = new Bitmap(Tile.fromColor(0x000000), container);
		handler = new CollisionHandler();
		filter = new Nothing();
		world = new Layers(container);
		mask = new Graphics(world);
		world.filter = new h2d.filter.Mask(mask, false);
		worldBg = new Bitmap(Tile.fromColor(0x10141f), world);
		ladder = new LilLadder(world);
		ladder.x = width * 0.5;
		ladder.y = height * 0.5 + 64;
		turret = new Turret(world, this);
		turret.x = width * 0.5;
		turret.y = height * 0.5;
		man = new SmallGuy(world, this);
		objects = [];
		objects.push(man);
		objects.push(ladder);
		objects.push(turret);
	}
	
	var waveTime = 5.0;
	var waveDuration = 5.0;
	
	function spawnEnemy() {
		var e = new SkullGuy(world, this);
		var r = Math.random() * Math.PI * 2;
		var ww = visibleRange + 16;
		e.x = width * 0.5 +  Math.cos(r) * ww;
		e.y = height * 0.5 +  Math.sin(r) * ww;
		enemies.push(e);
		objects.push(e);
	}

	public function spawnWave() {
		waveTime = 0;
		for(i in 0...2) {
			spawnEnemy();
		}

		waveDuration -= 0.1; 
		if (waveDuration < 3.5) waveDuration = 3.5;
	}
	
	public function onEnemyDie(e: Enemy) {
		removeEnemy(e);

		if (Math.random() < e.dropChance) {
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
				var v = Std.int(Math.random() * 9) + 1;
				while (vals.contains(v)) {
					v = Std.int(Math.random() * 9) + 1;
				}
				vals.push(v);
			}

			var t = new SudokuBullet(world, vals, true);
			t.x = e.x;
			t.y = e.y - t.height * 0.5 - 3;
			t.onPress = onPush;
		}
		e.remove();
	}
	
	var pickedUp = [];
	public function onPush(b: SudokuBullet) {
		var dx = b.x - man.x;
		var dy = b.y - man.y;
		var l = Math.sqrt(dx * dx + dy * dy);
		if (l < 50) {
			b.button.visible = false;
			pickedUp.push(b);
		}
	}
	
	public function removeEnemy(e) {
		enemies.remove(e);
		objects.remove(e);
	}
	
	public function start() {
		objects = [];
		enemies = [];

		objects.push(man);
		objects.push(ladder);
		objects.push(turret);

		world.removeChildren();
		world.addChild(worldBg);
		world.addChild(ladder);
		world.addChild(man);
		world.addChild(turret);
		world.addChild(mask);
		
		turret.reset();
		pickedUp = [];

		man.x = ladder.x;
		man.y = ladder.y - 8;
		running = true;
		waveTime = waveDuration;
	}

	override function tick(dt:Float) {
		super.tick(dt);
		if (!running) {
			alpha *= 0.3;
			if (alpha < 0.05) visible = false;
			return;
		}
		
		
		life -= dt * 0.5;

		mask.clear();

		var lr = (life / 100.0);
		visibleRange = width * 0.56 * lr;
		mask.beginFill(0xfffff);
		mask.drawCircle(width * 0.5, height * 0.5, visibleRange);
		mask.endFill();

		visible = true;
		alpha += (1 - alpha) * 0.2;

		world.ysort(0);
		var s = getScene();
		bg.width = s.width;
		bg.height = s.height;
		worldBg.width = s.width;
		worldBg.height = s.height;
		worldBg.x = -world.x;
		worldBg.y = -world.y;
		handler.resolve(objects);
		
		waveTime += dt;
		if (waveTime > waveDuration) {
			spawnWave();
		}

		world.x = Math.round((s.width - width) * 0.5);
		world.y = Math.round((s.height - height) * 0.5);
		
		var sx = man.x;
		var sy = man.y - 12;
		if (man.sprite.scaleX < 0) {
			sx += 6;
		} else {
			sx -= 6;
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
