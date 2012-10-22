package DataStructures
{
	public class DoublyLinkedListNode
	{
		private var prev:DoublyLinkedListNode;
		private var next:DoublyLinkedListNode;
		private var data:*;
		
		public function DoublyLinkedListNode(prev:DoublyLinkedListNode, data:*, next:DoublyLinkedListNode)
		{
			this.prev = prev;
			this.data = data;
			this.next = next;
		}
		
		public function getPrev():DoublyLinkedListNode
		{
			return prev;
		}
		
		public function getData():*
		{
			return data;
		}
		
		public function getNext():DoublyLinkedListNode
		{
			return next;
		}
		
		public function setPrev(node:DoublyLinkedListNode):void
		{
			this.prev = node;
		}
		
		public function setData(data:*):void
		{
			this.data = data;
		}
		
		public function setNext(node:DoublyLinkedListNode):void
		{
			this.next = node;
		}
		
		public function toString():String {
			return (data as Object).toString();
		}
	}
}