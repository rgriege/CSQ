package Collisions
{
	import Collisions.Shapes.AbstractShape;
	
	import MathUtilities.Vector2D;

	public class Penetration
	{
		public var rb1:RigidBody;
		public var rb2:RigidBody;
		public var shapePenData:Vector.<ShapePenetration>;
		
		public function Penetration(rb1:RigidBody, rb2:RigidBody)
		{
			this.rb1 = rb1;
			this.rb2 = rb2;
			shapePenData = new Vector.<ShapePenetration>();
			if(bodiesAreClose()) {
//				trace("close");
				shapePenData = findShapePenetrations();
			}
		}
		
		public function exists():Boolean {
			return shapePenData.length > 0;
		}
		
		private function bodiesAreClose():Boolean {
			var c2cVec:Vector2D = rb2.center.copy();
			c2cVec.add(rb2.velocity);
			c2cVec.subtract(rb1.center);
			c2cVec.subtract(rb1.velocity);
			return c2cVec.magSquared() < Math.pow(rb1.maxRadius + rb2.maxRadius,2);
		}
		
		private function findShapePenetrations():Vector.<ShapePenetration> {
			var result:Vector.<ShapePenetration> = new Vector.<ShapePenetration>();
			for each(var s1:AbstractShape in rb1.shapes) {
				for each(var s2:AbstractShape in rb2.shapes) {
					var sp:ShapePenetration = new ShapePenetration(rb1, s1, rb2, s2);
					if(sp.exists()) {
						trace("closer");
						result.push(sp);
					}
				}
			}
			return result;
		}
		
		public function printResults():void {
			for each(var sp:ShapePenetration in shapePenData) {
				sp.printResults();
			}
		}
	}
}