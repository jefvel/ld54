import gamestates.PlayState;

class Main extends elk.Elk{
	static var app: elk.Elk;

	override function init() {
		super.init();

		CData.init();

		app.states.current = new PlayState();
	}
	
	override function update(dt: Float) {
		super.update(dt);
	}

	public static function main() {
		app = new Main(60, 2);
	}
}