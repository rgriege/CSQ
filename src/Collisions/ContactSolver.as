package Collisions
{
	import MathUtilities.CSQMath;
	import MathUtilities.Vector2D;
	
	import mx.core.UIComponent;
	
	public class ContactSolver
	{
		private var adjacencyMatrix:Array;
		private var vsp:Vector.<ShapePenetration>;
		private var b:Array;
		
		public function ContactSolver(vsp:Vector.<ShapePenetration>)
		{
			/*this.vsp = vsp;
			findAdjacencyMatrix();
			resolveContacts(vsp);*/
		}
		
		/*public function findAdjacencyMatrix():void {
			adjacencyMatrix = CSQMath.getZeroArray(vsp.length);
			
		}
		
		public function findBvector():void {
			b = new Array(vsp.length);
			var len:uint = b.length;
			for(var i:uint = 0; i < len; i++) {
				var temp:Vector2D = vsp[i].axisFromS1 ? vsp[i].collisionAxis.copy() : 
					vsp[i].collisionAxis.invert();
				temp.scale(vsp[i].axisFromS1 ? vsp[i].rb1.angularVelocity : vsp[i].rb2.angularVelocity);
				temp.scale(2);
				temp = temp.getPerpendicular();
				b[i] = temp.dot(vsp[i].axisFromS1 ? vsp[i].ipv : vsp[i].ipv.invert());
			}
		}
		
		// solve a = A*f + b
		public function resolveContacts(vsp:Vector.<ShapePenetration>):void {
			var len:uint = vsp.length;
			var A:Array = CSQMath.getZeroArray(len);
			for(var i:uint = 0; i < len; i++) {
				for(var j:uint = 0; j < len; j++) {
					if(connected(vsp[i], vsp[j])) {
						var dependence:Number;
						var temp:Vector2D = new Vector2D(0,0);
						
						
						
						A[i][j] += dependence;
					}
				}
			}
		}
		
		private function connected(p1:ShapePenetration, p2:ShapePenetration):Boolean {
			return p1.rb1 == p2.rb1 || p1.rb1 == p2.rb2 || p1.rb2 == p2.rb1 || p1.rb2 == p2.rb2;
		}*/
	}
}