class SaveData extends elk.GameSaveData {
	public var wins = 0;
	public var losses = 0;
	public var playedDaily = false;
	public var dailyScore = 0.0;
	public var previousDaySeed: Int = -1;
	public var bestTime: Float = -1;
}