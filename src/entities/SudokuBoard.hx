package entities;

import gamestates.PlayState;
import h2d.Object;
import elk.util.EasedFloat;
import h2d.ScaleGrid;
import hxd.Rand;
import elk.entity.Entity;

enum SudokuBoardState {
	Init;
	Generating;
	Generated;
	Ready;
	Solved;
	Failed;
}

class SudokuBoard extends Entity {
	var grid = [];
	var solution = [];
	
	public var state: SudokuBoardState = Init;
	
	var bg: ScaleGrid;
	public var tiles: Array<SudokuTile> = [];
	
	public var height = 0.0;
	public var width = 0.0;
	
	var offY = 0.0;
	public var offYEase = new EasedFloat(0, 0.3);
	
	static var templateBoard: Array<Int> = [
		1,2,3, 4,5,6, 7,8,9,
		4,5,6, 7,8,9, 1,2,3,
		7,8,9, 1,2,3, 4,5,6,
		
		2,3,1, 5,6,4, 8,9,7,
		5,6,4, 8,9,7, 2,3,1,
		8,9,7, 2,3,1, 5,6,4,

		3,1,2, 6,4,5, 9,7,8,
		6,4,5, 9,7,8, 3,1,2,
		9,7,8, 3,1,2, 6,4,5,
	];
	
	public function getSolutionCell(cellID) {
		return solution[cellID];
	}
	
	public function getVal(row = 0, col = 0, grid = null) {
		if (grid == null) grid = this.grid;
		return grid[row * 9 + col];
	}
	public function getSol(row = 0, col = 0) {
		return solution[row * 9 + col];
	}
	public function setVal(row, col, val) {
		return grid[row * 9 + col] = val;
	}
	
	public function getRandomFreeTile() {
		var t = tiles.copy();
		rand.shuffle(t);
		for (ti in t) {
			if (!ti.solved && ti.bullet == null) {
				return ti;
			}
		}
		
		return null;
	}
	
	var playState: PlayState;
	public function new(?p, playState) {
		super(p);
		this.playState = playState;
		offYEase.easeFunction = elk.M.elasticOut;
		container = new Object(this);
		bg = new ScaleGrid(hxd.Res.img.bottom.toTile(), 8, 8, 8, 10, container);
		var ts = tileSize;
		width = ts * 9 + 6 * 2;
		height = ts * 9 + 6 * 2;
		bg.x = -padding;
		bg.y = -padding;
		bg.width = width + padding * 2 - 1;
		bg.height = height + padding * 2 + 2;
	}
	
	public function getTileAt(row, col) {
		return tiles[row * 9 + col];
	}
	
	public function isRowClear(row:Int) {
		for (col in 0...9) {
			if (!getTileAt(row, col).solved) {
				return false;
			}
		}
		return true;
	}
	
	public function isColClear(col:Int) {
		for (row in 0...9) {
			if (!getTileAt(row, col).solved) {
				return false;
			}
		}
		return true;
	}

	public function isBlockClear(row: Int, col:Int) {
		var sx = Std.int(col / 3);
		var sy = Std.int(row / 3);
		for (r in 0...3) {
			for (c in 0...3) {
				if (!getTileAt(sy * 3 + r, sx * 3 + c).solved) {
					return false;
				}
			}
		}
		return true;
	}
	
	public function tileIsBlocked(col: Int, row: Int, numberToPlace: Int) {
		if (rowContainsNumber(row, numberToPlace)) return true;
		if (colContainsNumber(col, numberToPlace)) return true;
		if (houseContainsNumber(col, row, numberToPlace)) return true;
		return false;
	}
	
	public function rowContainsNumber(row: Int, number: Int) {
		for (c in 0...9) {
			var t = getTileAt(row, c);
			if (t.solved && t.value == number) {
				return true;
			}
		}
		
		return false;
	}

	public function colContainsNumber(col: Int, number: Int) {
		for (r in 0...9) {
			var t = getTileAt(r, col);
			if (t.solved && t.value == number) {
				return true;
			}
		}
		
		return false;
	}

	public function houseContainsNumber(col: Int, row: Int, number: Int) {
		var colh = Std.int(col / 3) * 3;
		var rowh = Std.int(row / 3) * 3;

		for (r in 0...3) {
			for (c in 0...3) {
				var t = getTileAt(r + rowh, c + colh);
				if (t.solved && t.value == number) {
					return true;
				}
			}
		}
		
		return false;
	}
	
	public var rand: Rand;
	public var padding = 8;
	var container: Object;
	public function getDigitsLeft(includePlacedBullets = false) {
		var digits = [];
		for (c in tiles) {
			if (includePlacedBullets && c.bullet != null) {
				if (c.bullet.hasValue(c.value)) {
					continue;
				}
			}

			if (!c.solved) {
				digits.push(c.value);
			}
		}
		
		return digits;
	}
	
	public function freeCellCount() {
		var i = 0;
		for (c in tiles) {
			if (!c.solved && c.bullet == null) {
				i ++;
			}
		}
		return i;
	}
	
	public function solveProgress() {
		var emptyCount = 0;
		var solvedCount = 0;
		for (i in tiles) {
			if (!i.presolved) {
				emptyCount ++;
				if (i.solved) {
					solvedCount ++;
				}
			}
		}

		if (emptyCount == 0) {
			return 0.0;
		}

		return solvedCount / emptyCount;
	}
	
	public function isSolved() {
		if (tiles.length == 0) return false;
		for (c in tiles) {
			if (!c.solved) {
				return false;
			}
		}

		return true;
	}


	public function generate(seed = 1337) {
		rand = new Rand(seed);
		grid = templateBoard.copy();
		state = Generating;
		
		#if (target.threaded)
		sys.thread.Thread.create(() -> {
		#end

		shuffleNumbers();
		shuffleRows();
		shuffleCols();
		
		shuffleBlockCols();
		shuffleBlockRows();
		
		solution = grid.copy();

		removeCells();
		
		state = Generated;
		#if (target.threaded)
		});
		#end
	}
	
	var tileSize = 34;
	
	var generating = false;
	
	override function tick(dt:Float) {
		super.tick(dt);
		if (state == Generated) {
			var ts = tileSize;
			for (row in 0...9) {
				for (col in 0...9) {
					var val = getVal(row, col);
					var sol = getSol(row, col);
					var tile = new SudokuTile(container, sol, val != -1, row, col, playState);
					var gapsY = Std.int(row / 3) * 6;
					var gapsX = Std.int(col / 3) * 6;
					tile.x = col * ts + gapsX;
					tile.y = row * ts + gapsY;
					tile.onOver = onHoverCell;
					tiles.push(tile);
				}
			}
			state = Ready;
		}
	}
	
	public function nudge() {
		offYEase.setImmediate(4);
		offYEase.value = 0.0;
	}
	
	override function render() {
		super.render();
		container.y = offYEase.value;
	}
	
	public var onOverCell: SudokuTile -> Void;
	public var onOutOfCell: SudokuTile -> Void;
	
	public function makeAppear() {
		for (t in tiles) t.appear();
	}

	function onHoverCell(cell: SudokuTile) {
		if (onOverCell != null) onOverCell(cell);
	}
	
	function onOutCell(cell: SudokuTile) {
		if (onOutOfCell != null) onOutOfCell(cell);
	}

	function shuffleNumbers() {
		for(i in 0...9) {
			var random = rand.random(9) + 1;
			swapNumbers(i + 1, random);
		}
	}
	
	function swapNumbers(n1: Int, n2: Int) {
		for (row in 0...9) {
			for (col in 0...9) {
				var val = getVal(row, col);
				if (val == n1) {
					setVal(row, col, n2);
				} else if (val == n2) {
					setVal(row, col, n1);
				}
			}
		}
	}
	
	function shuffleRows() {
		for (i in 0...9) {
			var num = rand.random(3);
			var block = Std.int(i / 3);
			swapRows(i, block * 3 + num);
		}
	}
	
	function swapRows(r1: Int, r2: Int) {
		for (col in 0...9) {
			var val1 = getVal(r1, col);
			var val2 = getVal(r2, col);
			setVal(r1, col, val2);
			setVal(r2, col, val1);
		}
	}
	
	function shuffleCols() {
		for (i in 0...9) {
			var num = rand.random(3);
			var block = Std.int(i / 3);
			swapCols(i, block * 3 + num);
		}
	}
	
	function swapCols(c1: Int, c2: Int) {
		for (row in 0...9) {
			var val1 = getVal(row, c1);
			var val2 = getVal(row, c2);
			setVal(row, c1, val2);
			setVal(row, c2, val1);
		}
	}
	
	
	function shuffleBlockRows() {
		for (i in 0...3) {
			var num = rand.random(3);
			swapBlockRow(i, num);
		}
	}

	function swapBlockRow(r1, r2){
		for (i in 0...3) {
			swapRows(r1 * 3 + i, r2 * 3 + i);
		}
	}

	function shuffleBlockCols() {
		for (i in 0...3) {
			var num = rand.random(3);
			swapBlockCol(i, num);
		}
	}

	function swapBlockCol(c1, c2){
		for (i in 0...3) {
			swapCols(c1 * 3 + i, c2 * 3 + i);
		}
	}

	
	function removeCells() {
		var arr = [];
		var numsToRemove = 50;

		for (i in 0...(9*9)) {
			arr.push(i);
		}
		
		var numsRemoved = 0;
		var unremoved = [];
		
		while(true) {
			rand.shuffle(arr);
			numsRemoved = 0;
			unremoved = [];

			var g = grid.copy();
			var counts = new Map<Int, Int>();
			for (i in 0...arr.length) {
				// trace(i);
				var toClear = arr[i];
				var val = g[toClear];

				if (!counts.exists(val)) counts[val] = 9;
				
				// Unique solutions 
				var completelyRemovedValues = 0;
				for (i in 1...10) {
					var numLeft = counts.exists(i) ? counts[i] : 9;
					if (i == val) {
						numLeft --;
					}
					if (numLeft <= 0) {
						completelyRemovedValues ++;
						if (completelyRemovedValues > 1) break;
					}
				}

				if (completelyRemovedValues > 1) {
					continue;
				}

				g[toClear] = -1;
				
				if (!solutionIsUnique(g.copy(), toClear, val)) {
					g[toClear] = val;
					unremoved.push(toClear);
					var left = arr.length - i;
				} else {
					numsRemoved ++;
				}
			}
			
			if (81 - numsRemoved  <= 18) {
				break;
			}

			//if (numsRemoved >= numsToRemove) {
				grid = g.copy();
				break;
			//}
		}
		
		rand.shuffle(unremoved);
		var extraRemovals = Std.int(Math.min(unremoved.length, 1));
		for (i in 0...extraRemovals) {
			grid[unremoved[i]] = -1;
		}
	}
	
	function solutionIsUnique(cells: Array<Int>, removedIndex, correctValue) {
		for (i in 1...10) {
			if (i == correctValue) continue;
			if (!canPlace(Std.int(removedIndex / 9), removedIndex % 9, i, cells)){
				continue;
			}

			cells[removedIndex] = i;
			var s = solve(0, 0, cells);
			if (s >= 1) return false;
		}

		return true;
	}
	
	function solve(row:Int, col: Int, cells: Array<Int>, count: Int = 0) {
		if (row == 9) {
			row = 0;
			col ++;
			if (col == 9) {
				return count + 1;
			}
		}
		
		if (cells[row * 9 + col] != -1) {
			return solve(row + 1, col, cells, count);
		}
		
		var val = 1;
		while(val <= 9 && count < 1) {
			if (canPlace(row, col, val, cells)) {
				cells[row * 9 + col] = val;
				count = solve(row + 1, col, cells, count);
			}
			val ++;
		}
		
		cells[row * 9 + col] = -1;
		return count;
	}

	
	function canPlace(row = 0, col = 0, val: Int, ?grid: Array<Int>) {
		if (numInCol(col, val, grid)) {
			return false;
		}
		if (numInRow(row, val,grid)) {
			return false;
		}
		if (numInBlock(row, col, val,grid)) {
			return false;
		}

		return true;
	}
	
	function numInCol(col, num,grid) {
		for (i in 0...9) {
			var val = getVal(i, col,grid);
			if (val != -1) {
				if (val == num) {
					return true;
				}
			}
		}
		return false;
	}

	function numInRow(row, num,grid) {
		for (i in 0...9) {
			var val = getVal(row, i, grid);
			if (val == num) {
				return true;
			}
		}

		return false;
	}
	
	function numInBlock(row, col, num,grid) {
		var r = Std.int(row / 3);
		var c = Std.int(col / 3);
		for (row in 0...3) {
			for(col in 0...3) {
				var val = getVal(r * 3 + row, c * 3 + col,grid);
				if (val == num) {
					return true;
				}
			}
		}
		return false;
	}

	override public function toString() {
		var s = "\n";
		for (row in 0...9) {
			for (col in 0...9) {
				var val = getVal(row, col);
				if (val == -1) {
					s += " ";
				} else {
					s += '$val';
				}
				if (col < 8) {
					s += ', ';
				}
				if (col > 0 && (col + 1) % 3 == 0) {
					s += " ";
				}
			}
			if (row > 0 && (row + 1) % 3 == 0) {
				s += '\n';
			}
			if (row < 8) {
				s += '\n';
			}

		}
		return s;
	}
}