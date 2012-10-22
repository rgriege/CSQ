package Collisions
{
	import MathUtilities.Vector2D;
	
	public class Collision
	{
		public var sp:ShapePenetration;
		public var frictionalImpulse:Vector2D;
		public var impulseScalar:Number;
		
		public function Collision(sp:ShapePenetration)
		{
			this.sp = sp;
			impulseScalar = findImpulseScalar();
			frictionalImpulse = findFrictionalImpulse();
		}
		
		private function findImpulseScalar():Number {
			var result:Number = -(1 + sp.rb1.restitution * sp.rb2.restitution);
			var radius1perp:Vector2D = sp.radius1.getPerpendicular();
			var radius2perp:Vector2D = sp.radius2.getPerpendicular();
			result *= sp.ipv.dot(sp.collisionAxis);
			var denominator:Number = 
				(sp.rb2.fixed ? 0 : Math.pow(radius2perp.dot(sp.collisionAxis),2)/sp.rb2.momentOfInertia + 1/sp.rb2.mass)+
				(sp.rb1.fixed ? 0 : Math.pow(radius1perp.dot(sp.collisionAxis),2)/sp.rb1.momentOfInertia + 1/sp.rb1.mass);
			return Math.abs(result/denominator);
		}
		
		// returns the impulse due to friction
		private function findFrictionalImpulse():Vector2D {
			// first we must find the tangent vector
			var tangentVector:Vector2D;
			var normalVelocity:Number = sp.ipv.dot(sp.collisionAxis);
			if(normalVelocity == 0)
				tangentVector = new Vector2D(0,0);
			else {
				tangentVector = sp.ipv.copy();
				var tempVec:Vector2D = sp.collisionAxis.copy();
				tempVec.scale(normalVelocity);
				tangentVector.subtract(tempVec);
			}
			// now scale it appropriately
			var result:Vector2D = tangentVector;
			result.scale(sp.rb1.friction * sp.rb2.friction);
			//			var result:Vector2D = tangentVector.unitVector();
			//			result.scale(rb1.friction * rb2.friction * impulseScalar);
			return result;
		}
		
		// for debugging
		public function printResults():void {
			sp.printResults();
			trace("impulse scalar=",impulseScalar);
			//				trace("numerator=",-2*ipv.dot(collisionAxis)+", denominator=", 
			//					Math.pow(radius2.getPerpendicular().dot(collisionAxis), 2)/rb2.momentOfInertia +
			//					Math.pow(radius1.getPerpendicular().dot(collisionAxis), 2)/rb1.momentOfInertia +
			//					1/rb1.mass + 1/rb2.mass);
			trace("frictional impulse=",frictionalImpulse);
			trace("rb1 new velocity:",sp.rb1.velocity);
			trace("rb2 new velocity:",sp.rb2.velocity);
			
			//				trace("frictional impulse=",frictionalImpulse);
			//				trace(
			//					(CSQMath.equalWithin(vel1.x*rb1.mass + vel2.x*rb2.mass, 
			//						rb1.velocity.x*rb1.mass + rb2.velocity.x*rb2.mass, 0.0001))
			//					? "x momentum conserved" : "x momentum not conserved\n"
			//					+ "initial: " + vel1.x*rb1.mass + " + " + vel2.x*rb2.mass + ", final: "
			//					+ rb1.velocity.x*rb1.mass + " + " + rb2.velocity.x*rb2.mass);
			//				trace(
			//					(CSQMath.equalWithin(vel1.y*rb1.mass + vel2.y*rb2.mass, 
			//						rb1.velocity.y*rb1.mass + rb2.velocity.y*rb2.mass, 0.0001))
			//					? "y momentum conserved\n" : "y momentum not conserved\n"
			//					+ "initial: " + vel1.y*rb1.mass + " + " + vel2.y*rb2.mass + ", final: "
			//					+ rb1.velocity.y*rb1.mass + " + " + rb2.velocity.y*rb2.mass);
			trace("\n");
		}
	}
}