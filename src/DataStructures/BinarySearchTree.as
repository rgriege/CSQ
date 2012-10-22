package DataStructures
{
	import DataStructures.BinaryTreeNode;
	
	public class BinarySearchTree
	{
		private var root:BinaryTreeNode;
		
		public function BinarySearchTree()
		{
			root = null;
		}
		
		public function getRoot():BinaryTreeNode {
			return root;
		}
		
		public function add(data:Comparable):void {
			var newNode:BinaryTreeNode = new BinaryTreeNode(data);
			if(!root)
				root = newNode;
			else {
				var temp:BinaryTreeNode = root;
				while(temp) {
					var difference:int = data.compareTo(root.getData());
					if(difference < 0)
						temp = temp.getLeft();
					else if(difference > 0)
						temp = temp.getRight();
				}
			}
		}
		
		public function isEmpty():Boolean {
			return root == null;
		}
	}
}