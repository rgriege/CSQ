package DataStructures
{
	import DataStructures.DoublyLinkedList;
	
	public class Stack
	{
		private var list:DoublyLinkedList;
		
		public function Stack()
		{
			list = new DoublyLinkedList;
		}
		
		public function push(data:*):void {
			list.addLast(data);
		}
		
		public function pop():* {
			return list.removeLast();
		}
		
		public function top():* {
			return list.getLast();
		}
		
		public function isEmpty():Boolean {
			return list.isEmpty();
		}
		
		public function toString():String {
			return list.toString();
		}
	}
}