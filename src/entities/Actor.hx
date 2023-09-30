package entities;

import CollisionHandler.CollisionObject;
import elk.entity.Entity;

class Actor extends Entity {
	public var radius = 8.0;
	public var mass = 1.0;
	public var uncollidable = false;
	public var filterGroup = 0;
	public var sleeping = false;
}