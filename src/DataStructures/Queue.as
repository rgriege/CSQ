package DataStructures
{
	import DataStructures.LinkedList;
	
	public class Queue
	{
		private var list:LinkedList;
		
		public function Queue()
		{
			list = new LinkedList();	
		}
		
		public function enqueue(data:*):void {
			list.add(data);
		}
		
		public function dequeue():* {
			return list.removeFirst();
		}
		
		public function peek():* {
			return list.getFirst();
		}
		
		public function isEmpty():Boolean {
			return list.isEmpty();
		}
	}
}