package MathUtilities.Functions
{
	public class TrigFunction extends AbstractFunction
	{
		/* Describes an equation of the following type:
			a*t + b*cos(u*t) + c*sin(v*t) + d = 0
		The input parameters must be in the order: 
			a,b,u,c,v,d
		*/		
		public function TrigFunction(a:Number, b:Number, u:Number, c:Number, v:Number, d:Number)
		{
			super(a,b,u,c,v,d);
			if(coefficients.length != 6)
				throw new Error("Improper trig equation");
		}
		
		override public function f(t:Number):Number {
			return coefficients[0]*t + coefficients[1]*Math.cos(coefficients[2]*t) +
				coefficients[3]*Math.sin(coefficients[4]*t) + coefficients[5];
		}
	}
}