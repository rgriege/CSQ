package Editor
{
	import flash.events.Event;
	
	public class ToolSelectedEvent extends Event
	{
		public var tool:String;
		public static const EVENT:String = "This is the best day ever!";
		
		public function ToolSelectedEvent(type:String, tool:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.tool = tool;
		}
	}
}