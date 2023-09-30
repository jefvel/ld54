package;

private typedef Init = haxe.macro.MacroType<[cdb.Module.build("../res/data.cdb")]>;

@:allow(Main)
private function init() {
	#if debug
	CData.load(hxd.Res.data.entry.getText(), true);
	hxd.Res.data.watch(() -> {
		CData.load(hxd.Res.data.entry.getText(), true);
	});
	#else
	CData.load(hxd.Res.data.entry.getText());
	#end
}