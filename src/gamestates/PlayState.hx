package gamestates;

import elk.M;
import elk.graphics.filter.RetroFilter;
import elk.graphics.pass.RetroPass;
import h3d.pass.ScreenFx;
import h3d.shader.ScreenShader;
import elk.util.EasedFloat;
import elk.graphics.Quad;
import elk.graphics.Billboard;
import h3d.scene.World.WorldModel;
import h3d.prim.Cube;
import h3d.scene.Mesh;
import h3d.col.Bounds;
import h3d.prim.UV;
import h3d.col.Point;
import h3d.scene.MeshBatch;
import h3d.prim.BigPrimitive;
import h2d.Tile;
import h2d.Bitmap;
import entities.TestEntity;
import hxd.res.DefaultFont;
import h2d.Text;
import hxd.Key;
import elk.gamestate.GameState;

class PlayState extends GameState {
	var time = 0.;
	var tickRateTxt: Text;
	var filt: hxd.snd.effect.Pitch;

	public function new() {
		super();
		filt = new hxd.snd.effect.Pitch();
		game.sounds.sfxChannel.addEffect(filt);
	}
	
	override function onEnter() {
		super.onEnter();
		
		//sy.easeFunction = elk.T.elasticOut;

		tickRateTxt = new Text(DefaultFont.get(), s2d);
		tickRateTxt.textColor = 0xffffff;
		
		//s2d.filter = new h2d.filter.Nothing();
		for (i in 0...0) {
			var e = new TestEntity(s2d);
			e.x = Math.random() * 1000;
			e.y = Math.random() * 600;
			game.entities.add(e);
		}
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
	

	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		
		updateCamBounds();
	}
}
