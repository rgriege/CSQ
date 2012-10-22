package Collisions
{
	import Collisions.Shapes.AbstractShape;
	
	import MathUtilities.CSQMath;
	import MathUtilities.Interval;
	import MathUtilities.Matrix2D;
	import MathUtilities.Vector2D;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class RigidBody extends MovieClip
	{
		// stores the shapes
		public var shapes:Vector.<AbstractShape>;
		// stores the mean x and y values, used for axis checking in the collidesWith method
		public var center:Vector2D;
		// stores the maximum distance from the center to a vertex of a shape
		public var maxRadius:Number;
		// stores the (linear) velocity
		public var velocity:Vector2D;
		// stores the angular velocity in radians, with CCW being positive
		public var angularVelocity:Number = 0;
		// stores the constant setting the maximum angular velocity to use the approximation in
		// Collision.findOffsets()
		public const AV_THRESHOLD:Number = 0.1;
		public var force:Vector2D;
		public var torque:Number;
		// stores the moment of inertia
		public var momentOfInertia:Number;
		// stores the mass
		public var mass:Number = 0;
		/* This engine approximates the actual coefficients of restitution and friction in a collision
		by storing an individual coeffectient for each Rigid Body and multiplying them together.*/
		// coefficient of restitution, should be between 0 and 1.0
		public var restitution:Number;
		// coefficient of friction, should be between 0 and 1.0
		public var friction:Number;
		// stores the possible anchor
		public var anchor:Vector2D;
		// determines whether or not the body's location is fixed
		public var fixed:Boolean;
		// sprite to hold the graphics for anchors and fixed points
		public var oxSprite:Sprite;
		
		public function RigidBody(shapes:Array, restitution:Number=1, friction:Number=1) {
			maxRadius = 0;
			this.shapes = new Vector.<AbstractShape>();
			for each(var s:AbstractShape in shapes) {
				this.shapes.push(s);
				addChild(s);
				var temp:Number = s.findMaxRadius();
				if(temp > maxRadius)
					maxRadius = temp;
			}
			this.restitution = restitution;
			this.friction = friction;
			center = new Vector2D(0, 0);
			velocity = new Vector2D(0, 0);
			angularVelocity = 0;
			force = new Vector2D(0,0);
			torque = 0;
			calculateMass();
			calculateMomentOfInertia();
			drawShapes();
			oxSprite = new Sprite();
			addChild(oxSprite);
		}
		
		private function calculateMass():void {
			mass = 0;
			for each(var shape:AbstractShape in shapes) {
				mass += shape.mass;
			}
		}
		
		// calculate the moment of inertia of the whole Rigid Body according to the parallel axis theorem
		private function calculateMomentOfInertia():void {
			momentOfInertia = 0;
			for each(var shape:AbstractShape in shapes) {
				momentOfInertia += shape.calculateMomentOfInertia() + shape.mass * shape.center.magSquared();
			}
		}
		
		// Sets an anchor around which the Rigid Body may rotate freely but restricts horizontal
		// or vertical translation.  The input vector should point from the center of the Rigid
		// Body to the anchor; the inverting is to simplify calculations later (so the actual 
		// anchor vector points from the anchor to the center of mass).
		public function setAnchor(v:Vector2D):void {
			if(!fixed) {
				anchor = v.invert();
				drawOX();
			}
		}
		
		public function setHorizon(v:Vector2D):void {
			for each(var s:AbstractShape in shapes) {
				s.setHorizon(v);
			}
		}
		
		// draws the polygon
		public function drawShapes():void {
			for each(var shape:AbstractShape in shapes) {
				shape.drawVertices();
			}
		}
		
		public function drawOX():void {
			if(anchor != null) {
				oxSprite.graphics.beginFill(0);
				oxSprite.graphics.drawCircle(-anchor.x, -anchor.y, 4);
			}
			if(fixed) {
				oxSprite.graphics.lineStyle(3);
				oxSprite.graphics.moveTo(-3, -3);
				oxSprite.graphics.lineTo(3, 3);
				oxSprite.graphics.moveTo(-3, 3);
				oxSprite.graphics.lineTo(3, -3);
			}
		}
		
		// projects the Rigid Body onto the input axis
		public function project(axis:Vector2D):Vector.<Interval> {
			var axisCopy:Vector2D = axis.isUnitVector() ? axis.copy() : axis.unitVector();
			var result:Vector.<Interval> = new Vector.<Interval>();
			for each(var s:AbstractShape in shapes) {
				result = result.concat(s.project(axisCopy));
			}
			return result;
		}
		
		// applies an impulse to the Rigid Body at the specified location from the center
		public function applyImpulseAt(impulse:Vector2D, location:Vector2D=null):void {
			if(!fixed) {
				if(location==null)
					location = new Vector2D(0,0);
				if(anchor == null) {
					angularVelocity -= location.cross(impulse)/momentOfInertia;
					impulse.scale(1/mass);
					velocity.add(impulse);
				} else {
					location.add(anchor);
					angularVelocity = (impulse.cross(location) + momentOfInertia*angularVelocity
						+ mass*velocity.cross(anchor)) / 
						(momentOfInertia + mass*anchor.getPerpendicular().cross(anchor));
					velocity = anchor.getPerpendicular();
					velocity.scale(angularVelocity);
				}
			}
		}
		
		// applies the input force at the given location, as measure from the center
		public function applyForceAt(force:Vector2D, location:Vector2D):void {
			this.force.add(force);
			if(anchor == null)
				torque -= location.cross(force);
			else {
				var newLocation:Vector2D = anchor.copy();
				newLocation.add(location);
				torque -= newLocation.cross(force);
			}
		}
		
		// adjusts position based on the current velocity
		public function stepMove(time:Number):void {
			if(anchor == null) {
				var acceleration:Vector2D = force.copy();
				acceleration.scale(1/mass);
				var diff:Vector2D = acceleration.copy();
				diff.scale(time/2);
				diff.add(velocity);
				diff.scale(time);
				translate(diff);
				rotate(CSQMath.toDegrees(angularVelocity*time + Math.pow(time, 2)*torque/momentOfInertia/2));
				acceleration.scale(time);
				velocity.add(acceleration);
				angularVelocity += torque/momentOfInertia*time
			} else {
				var newForce:Vector2D = force.project(anchor.invert());
				applyForceAt(newForce, anchor.invert());
				var original:Vector2D = anchor.copy();
				rotate(angularVelocity*time + torque*Math.pow(time,2)/2/momentOfInertia);
				angularVelocity += torque*time/momentOfInertia;
				diff = anchor.copy();
				diff.subtract(original);
				translate(diff);
			}
			calculateNextVertices();
			force = new Vector2D(0,0);
			torque = 0;
		}
		
		// manually moves the rigid body a certain distance without changing velocity
		public function translate(change:Vector2D):void {

			center.add(change);
			this.x = center.x;
			this.y = center.y;
		}
		
		public function translate2(x:Number, y:Number):void {

			center.x += x;
			center.y += y;
			this.x = center.x;
			this.y = center.y;
		}
		
		// Rotates the rigid body a certain angle CCW about the center of mass
		public function rotate(radians:Number):void {
			for each(var s:AbstractShape in shapes) {
				s.rotateAround(radians);
			}
			if(anchor != null) 
				anchor.rotate(radians);
			var degrees:Number = radians*180/Math.PI;
			this.rotation -= degrees;
		}
		
		public function fix():void {
			if(anchor == null) {
				fixed = true;
				drawOX();
			}
		}
		
		public function calculateNextVertices():void {
			for each(var s:AbstractShape in shapes) {
				s.calculateNextVertices(center, velocity, angularVelocity);
			}
		}
		
		// exports the important data of this Rigid Body to a string for saving
		public function exportData():String {
			// first export each shape
			var result:String = new String("");
			var len:uint = shapes.length;
			for(var j:uint = 0; j < len; j++) {
				shapes[j].roundValues();
				result += shapes[j].exportData();
			}
			// then export the properties of the rigid body
			roundValues();
			result += "RigidBody;";
			result += center.x+"," + center.y+";";
			result += velocity.x+"," + velocity.y+";";
			result += angularVelocity+";";
			if(anchor == null)
				result += "f;";
			else
				result += "t;" + anchor.x+"," + anchor.y+";";
			result += (fixed ? "t;" : "f;");
			result += restitution+";";
			result += friction+"!";
			return result;
		}
		
		private function roundValues():void {
			center.x = CSQMath.roundTo(center.x, 2);
			center.y = CSQMath.roundTo(center.y, 2);
			velocity.x = CSQMath.roundTo(velocity.x, 2);
			velocity.y = CSQMath.roundTo(velocity.y, 2);
			angularVelocity = CSQMath.roundTo(angularVelocity, 2);
			if(anchor != null) {
				anchor.x = CSQMath.roundTo(anchor.x, 2);
				anchor.y = CSQMath.roundTo(anchor.y, 2);
			}
			restitution = CSQMath.roundTo(restitution, 2);
			friction = CSQMath.roundTo(friction, 2);
		}
		
		// print method for debugging
		public function printVertices():void {
			trace("Shapes:");
			for(var i:uint = 0; i < shapes.length; i++) {
				trace(shapes[i].toString());
			}
		}
	}
}