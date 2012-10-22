package Editor
{
	import Collisions.Shapes.AbstractShape;
	
	import flash.events.Event;
	
	public class AddBodyEvent extends Event
	{
		public var shape:AbstractShape;
		public static const EVENT:String = "Here is another meaningless string.";
		
		public function AddBodyEvent(type:String, shape:AbstractShape, bubbles:Boolean=true, 
									 cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.shape = shape;
		}
	}
}