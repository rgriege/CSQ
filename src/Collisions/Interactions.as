package Collisions
{
	import Collisions.Shapes.AbstractShape;
	import Collisions.Shapes.Disk;
	import Collisions.Shapes.Polygon;
	import Collisions.Shapes.Ring;
	
	import Editor.SaveFile;
	
	import MathUtilities.CSQMath;
	import MathUtilities.Interval;
	import MathUtilities.Vector2D;
	
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Interactions extends MovieClip
	{
		// vector containing all the Rigid Bodies in the interaction
		public var bodies:Vector.<RigidBody>;
		// stores the gravity vector
		public var gravityVector:Vector2D;
		// determines whether to keep Rigid Bodies within specified boundaries
		public var hasBounds:Boolean;
		// keeps track of boundary box with upper left and bottom right coordinates
		public var bounds:Vector.<Vector2D>;
		private var limits:Vector.<Number>;
		
		private const COLLISION_THRESHOLD:Number = 1;
		
		public function Interactions(hasBounds:Boolean=false, gravity:Vector2D=null)
		{
			bounds = new Vector.<Vector2D>();
			this.limits = new Vector.<Number>();
			this.hasBounds = hasBounds;
			if(hasBounds) {
				bounds.push(Vector2D.X_AXIS, Vector2D.Y_AXIS, Vector2D.X_AXIS.invert(), 
							Vector2D.Y_AXIS.invert());
				this.limits.push(0, 0, -700, -550);
			}
			bodies = new Vector.<RigidBody>();
			if(gravity != null)
				gravityVector = gravity;
			else
				gravityVector = new Vector2D(0,0);
//			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
//			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		// adds a RigidBody to the bodies vector
		public function addBody(rb:RigidBody):void {
			bodies.push(rb);
			rb.calculateNextVertices();
			addChild(rb);
		}
		
		// removes a RigidBody from bodies
		// returns true if rb is found and removed, false otherwise
		public function removeBody(rb:RigidBody):Boolean {
			var len:uint = bodies.length;
			for(var i:uint = 0; i < len; i++)
				if(bodies[i] == rb)
					bodies.splice(i, 1);
			return len != bodies.length;
		}
		
		// runs every frame 
		public function EFH(evt:Event):void {
			if(!gravityVector.isZero())
				applyGravity();
			var stable:Boolean = false;
			while(!stable) {
				stable = true;
				var bodyCollisions:Boolean = true;
				while(bodyCollisions) {
					var bodyCollision:Collision = detectBodyCollision();
					if(bodyCollision)
						resolveCollision(bodyCollision);
					else
						bodyCollisions = false;
				}
				//var cs:ContactSolver = new ContactSolver(contacts); OLD
				var boundCollisions:Boolean = true;
				while(boundCollisions) {
					var boundCollision:Collision = detectBoundCollision();
					if(boundCollision)
						resolveCollision(boundCollision);
					else
						boundCollisions = false;
				}
				stable = !bodyCollisions && !boundCollisions;
			}
			moveBodies();
		}
		
		// gravity
		public function applyGravity():void {
			for each(var rb:RigidBody in bodies) {
				if(!rb.fixed) {
					var v:Vector2D = gravityVector.copy();
					v.scale(rb.mass);
					rb.applyForceAt(v,new Vector2D(0,0));
				}
			}
		}
		
		// detects collisions between Rigid Bodies and returns the first it finds
		public function detectBodyCollision():Collision {
			var len:uint = bodies.length;
			for(var i:uint = 0; i < len-1; i++) {
				for(var j:uint = i+1; j < len; j++) {
					var collision:Collision = new Collision(bodies[i], bodies[j]);
					if (collision.exists()) {
						if (collision.ipv.magSquared() > COLLISION_THRESHOLD) {
							return collision;
						}
					}
				}
			}
			return null;
		}
		
		// keeps Rigid Bodies within the boundaries
		// returns true if a body is moved
		public function detectBoundCollision():Collision {
			return null;
			var stateChanged:Boolean = false;
			for each(var rb:RigidBody in bodies) {
				var len:uint = bounds.length;
				for(var i:uint = 0; i < len; i++) {
					var ints:Vector.<Interval> = rb.project(bounds[i]);
					var projection:Interval = Interval.Inclusion(ints);
					if(projection.leftLimit < limits[i]) {
						moveToTangency(rb, bounds[i], limits[i]);
						var radius:Vector2D = findRadius(rb, bounds[i], limits[i]);
						var impulse:Vector2D = findImpulse(rb, radius, bounds[i]);
						rb.applyImpulseAt(impulse, radius);
						stateChanged = true;
					}
				}
			}
			//return stateChanged;
			return null;
		}
		
		// move the bodies
		public function moveBodies():void {
			for each(var rb:RigidBody in bodies) {
				rb.stepMove(1);
			}
		}
		
		// moves the parameter Rigid Bodies out of their collision and 
		// adjusts their (linear and angular) velocities
		public function resolveCollision(colData:Collision):void {
			// first average the collision impules
			var rad1:Vector2D = new Vector2D(0,0);
			var rad2:Vector2D = new Vector2D(0,0);
			var impulse1:Vector2D = new Vector2D(0,0);
			var impulse2:Vector2D = new Vector2D(0,0);
			var maxTime:Number = 0;
			rad1.add(colData.radius1);
			rad2.add(colData.radius2);
			var temp:Vector2D = colData.collisionAxis.copy();
			temp.scale(-colData.impulseScalar);
			impulse1.add(temp);
			temp.invert();
			impulse2.add(temp);
			if(colData.penetrationTime > maxTime)
				maxTime = colData.penetrationTime;
			
			// adjust linear and angular velocities from collisoin impulse
			colData.rb1.applyImpulseAt(impulse1, rad1);
			colData.rb2.applyImpulseAt(impulse2, rad2);
			
			// adjust linear and angular velocities from frictional impulse
//			impulse = colData.frictionalImpulse;
//			sp.rb1.applyImpulseAt(impulse.copy(), sp.radius1);
//			sp.rb2.applyImpulseAt(impulse.invert(), sp.radius2);
			
			// move Rigid Bodies appropriate amount away from collision
			colData.rb1.stepMove(maxTime);
			colData.rb2.stepMove(maxTime);
			colData.printResults();
		}
		
		private function moveToTangency(rb:RigidBody, axis:Vector2D, limit:Number):void {
			var initialVelocity:Vector2D = rb.velocity.copy();
			var initialAngularVelocity:Number = rb.angularVelocity;
			var timeChange:Number = 0.5
			var timeToPenetration:Number = 0.5;
			var over:Boolean = false;
			while(timeChange > 0.01 || over) {
				rb.velocity = initialVelocity.copy();
				rb.velocity.scale(timeToPenetration);
				rb.angularVelocity = initialAngularVelocity*timeToPenetration;				
				rb.calculateNextVertices();
				var projection:Interval = rb.project(axis);
				if(projection.leftLimit < limit)
					over = true;
				else
					over = false;
				timeChange /= 2;
				if(over)
					timeToPenetration -= timeChange;
				else
					timeToPenetration += timeChange;
			}
			rb.velocity = initialVelocity;
			rb.angularVelocity = initialAngularVelocity;
		}
		
		private function findRadius(rb:RigidBody, axis:Vector2D, limit:Number):Vector2D {
			var tangentVectors:Vector.<Vector2D> = new Vector.<Vector2D>();
			if(rb.shape is Polygon) {
				for each(var v:Vector2D in rb.shape.nextVertices) {
					if(CSQMath.equalWithin(v.dot(axis), limit, 0.1))
						tangentVectors.push(v.copy());
				}
			} else {
				var tempVec:Vector2D = axis.invert();
				if(rb.shape is Disk)
					tempVec.scale((rb.shape as Disk).radius);
				else
					tempVec.scale((rb.shape as Ring).outerRadius);
				tempVec.add(rb.shape.nextVertices[0]);
				if(CSQMath.equalWithin(tempVec.dot(axis), limit, 0.1))
					tangentVectors.push(tempVec);
			}
			var len:uint = tangentVectors.length;
			for(var i:uint; i < len; i++) {
				tangentVectors[i].subtract(rb.center);
			}
			if(len == 1)
				return tangentVectors[0];
			else {
				Vector2D.sortByDotProduct(tangentVectors, axis.getPerpendicular());
				if(len % 2 == 1)
					return tangentVectors[Math.floor(len/2)];
				else
					return Vector2D.getAverage(tangentVectors[len/2-1], tangentVectors[len/2]);
			}
		}
		
		private function findImpulse(rb:RigidBody, radius:Vector2D, axis:Vector2D):Vector2D {
			var numerator:Number = -(1 + rb.restitution);
			var radiusPerp:Vector2D = radius.getPerpendicular();
			var ipv:Vector2D = radius.getPerpendicular();
			ipv.scale(rb.angularVelocity);
			ipv.add(rb.velocity);
			numerator *= ipv.dot(axis);
			var denominator:Number = Math.pow(radiusPerp.dot(axis),2)/rb.momentOfInertia + 1/rb.mass;
			var result:Vector2D = axis.copy();
			result.scale(Math.abs(numerator/denominator));
			return result;
		}
		
		public function drawBounds():void {
			graphics.lineStyle(2);
			var len:uint = bounds.length;
			graphics.moveTo(bounds[len-1].x, bounds[len-1].y);
			for(var i:uint = 0; i < len; i++)
				graphics.lineTo(bounds[i].x, bounds[i].y);
		}
		
//		public function addedToStage(evt:Event):void {
//			
//		}
//		
//		public function removedFromStage(evt:Event):void {
//			
//		}
		
		public function exportData():String {
			var result:String = new String();
			if(hasBounds) {
				result += "t;";
				var len:uint = bounds.length;
				for(var i:uint = 0; i < len; i++) {
					result += bounds[i]+";" + limits[i]+";";
				}
			} else
				result += "f;";
			if(gravityVector.isZero())
				result += "f!";
			else
				result += "t;" + gravityVector+"!\n";
			len = bodies.length;
			for(i = 0; i < len; i++) {
				result += bodies[i].exportData();
			}
			return result;
		}
		
		public function importData(file:SaveFile):void {
			var arr:Array = file.getObjectData(0);
			var index:uint = 0;
			if(arr[index] == "t") {
				hasBounds = true;
				index++;
				while(!(arr[index] is String)) {
					bounds.push(arr[index] as Vector2D);
					limits.push(arr[index+1] as Number);
					index += 2;
				}
			}
			if(arr[index] == "t") {
				gravityVector = arr[index+1] as Vector2D;
				index++;
			}
			index++;
			var s:AbstractShape;
			for(var i:uint = 1; i < file.numObjects; i++) {
				arr = file.getObjectData(i);
				switch(arr[0]) {
					case "RigidBody":
						var rb:RigidBody = new RigidBody(s);
						rb.center = arr[1];
						rb.velocity = arr[2];
						rb.angularVelocity = arr[3];
						var index2:uint = 4;
						if(arr[index2] == "t") {
							index2++;
							rb.anchor = arr[index2];
						}
						index2++;
						rb.fixed = arr[index2++] == "t";
						rb.restitution = arr[index2++];
						rb.friction = arr[index2++];
						rb.x = rb.center.x;
						rb.y = rb.center.y;
						addBody(rb);
						break;
					case "Disk":
						s = new Disk(arr[1], arr[2], arr[3], arr[4]);
						break;
					case "Ring":
						s = new Ring(arr[1], arr[2], arr[3], arr[4], arr[5]);
						break;
					case "Polygon":
						index2 = 2;
						var vertices:Vector.<Vector2D> = new Vector.<Vector2D>();
						while(arr[index2] is Vector2D) {
							vertices.push(arr[index2] as Vector2D);
							index2++;
						}
						s = new Polygon(arr[1], vertices, arr[index2], arr[index2+1]);
						break;
				}
			}
		}
		
		// Either starts or stops this and all Rigid Bodies' EFHs depending on the current state.
		// The default state of the EFHs for Rigid Bodies and Interactions is 'off'.
		public function toggle():void {
			if(hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, EFH);
			else
				addEventListener(Event.ENTER_FRAME, EFH);
		}
	}
}