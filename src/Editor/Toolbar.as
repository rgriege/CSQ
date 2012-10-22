package Editor
{
	import assets.ToolbarGraphic;
	
	import flash.display.Sprite;
	
	public class Toolbar extends Sprite
	{
		private var icons:Vector.<Icon>;
		
		public function Toolbar()
		{
			var graphic:Sprite = new ToolbarGraphic();
			addChild(graphic);
			
			icons = new Vector.<Icon>();
			var len:uint = Icon.TYPES.length;
			for(var i:uint = 0; i < len-2; i++) {
				icons.push(new Icon(Icon.TYPES[i] as String));
				icons[i].y = i*Icon.DEFAULT_HITBOX_SIZE;
				icons[i].x = (graphic.width - icons[i].width)/2;
				addChild(icons[i]);
			}
		}
	}
}