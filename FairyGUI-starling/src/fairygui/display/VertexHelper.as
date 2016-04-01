package fairygui.display
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import fairygui.FillType;
	import fairygui.FlipType;
	
	import starling.display.QuadBatch;
	import starling.textures.Texture;

	public class VertexHelper
	{
		public static var vertBuffer:Vector.<Point> = new Vector.<Point>();
		public static var uvBuffer:Vector.<Point> = new Vector.<Point>();
		public static var colorBuffer:Vector.<uint> = new Vector.<uint>();		
		public static var color:uint = 0;		
		public static var quadCount:int;		
		
		private static var helperQuad:HelperQuad;
		private static var helperRect1:Rectangle = new Rectangle();
		private static var helperRect2:Rectangle = new Rectangle();
		private static var helperRect3:Rectangle = new Rectangle();
		private static var helperRect4:Rectangle = new Rectangle();
		private static var helperTexCoords:Vector.<Number> = new Vector.<Number>(8);
		private static var FULL_UV:Array = [0,0,1,0,0,1,1,1];
		
		public function VertexHelper()
		{
			super();
		}
		
		public static function beginFill():void
		{
			quadCount = 0;
			
			if(helperQuad==null)
			{
				helperQuad = new HelperQuad();
				alloc(50);
			}
		}
		
		public static function alloc(capacity:int):void
		{
			var req:int = capacity*4;
			var cnt:int = vertBuffer.length;
			if(cnt<req)
			{
				vertBuffer.length = req;
				uvBuffer.length = req;
				colorBuffer.length = capacity;
				
				for(var i:int=cnt;i<req;i++)
				{
					vertBuffer[i] = new Point();
					uvBuffer[i] = new Point();
				}
			}
		}
		
		public static function flush(target:QuadBatch, texture:Texture, alpha:Number=1, smoothing:String=null):void
		{
			if(quadCount==0)
				return;
			
			if(texture!=null)
				helperQuad.vectexData.setPremultipliedAlpha(texture.premultipliedAlpha);
			else
				helperQuad.vectexData.setPremultipliedAlpha(false);
			
			var space:int = target.capacity-target.numQuads;
			if(space<quadCount)
				target.capacity += quadCount-space;
			
			var k:int = 0;
			for(var i:int=0;i<quadCount;i++)
			{
				for(var j:int=0;j<4;j++)
				{
					helperQuad.vectexData.setPosition(j, vertBuffer[k].x, vertBuffer[k].y);
					helperQuad.vectexData.setTexCoords(j, uvBuffer[k].x, uvBuffer[k].y);
					k++;
				}

				helperQuad.color = colorBuffer[i];
				target.addQuad(helperQuad, alpha, texture, smoothing);
			}
		}
		
		public static function addQuad(x:Number, y:Number, width:Number, height:Number):void
		{
			var vertIndex:int = quadCount*4;
			vertBuffer[vertIndex].x = x;
			vertBuffer[vertIndex].y = y;
			vertBuffer[vertIndex+1].x = x+width;
			vertBuffer[vertIndex+1].y = y;
			vertBuffer[vertIndex+2].x = x;
			vertBuffer[vertIndex+2].y = y+height;
			vertBuffer[vertIndex+3].x = x+width;
			vertBuffer[vertIndex+3].y = y+height;
			
			colorBuffer[quadCount] = color;
			
			quadCount++;
		}
		
		public static function addQuad2(vertRect:Rectangle):void
		{
			var vertIndex:int = quadCount*4;
			vertBuffer[vertIndex].x = vertRect.x;
			vertBuffer[vertIndex].y = vertRect.y;
			vertBuffer[vertIndex+1].x = vertRect.right;
			vertBuffer[vertIndex+1].y = vertRect.y;
			vertBuffer[vertIndex+2].x = vertRect.x;
			vertBuffer[vertIndex+2].y = vertRect.bottom;
			vertBuffer[vertIndex+3].x = vertRect.right;
			vertBuffer[vertIndex+3].y = vertRect.bottom;
			
			colorBuffer[quadCount] = color;
			
			quadCount++;
		}
		
		public static function getTextureUV(texture:Texture, rect:Rectangle = null):Rectangle
		{
			for(var i:int=0;i<8;i++)
				helperTexCoords[i] = FULL_UV[i];
			texture.adjustTexCoords(helperTexCoords);
			
			if(rect==null)
				rect = new Rectangle();
			rect.x = helperTexCoords[0];
			rect.y = helperTexCoords[1];
			rect.right = helperTexCoords[6];
			rect.bottom = helperTexCoords[7];
			
			return rect;
		}
		
		public static function flipUV(rect:Rectangle, flip:int):void
		{
			var tmp:Number;
			if (flip == FlipType.Horizontal || flip == FlipType.Both)
			{
				tmp = rect.x;
				rect.x = rect.right;
				rect.right = tmp;
			}
			if (flip == FlipType.Vertical || flip == FlipType.Both)
			{
				tmp = rect.y;
				rect.y = rect.bottom;
				rect.bottom = tmp;
			}
		}
		
		public static function fillUV(x:Number, y:Number, width:Number, height:Number):void
		{
			var vertIndex:int = (quadCount-1)*4;
			uvBuffer[vertIndex].x = x;
			uvBuffer[vertIndex].y = y;
			uvBuffer[vertIndex+1].x = x+width;
			uvBuffer[vertIndex+1].y = y;
			uvBuffer[vertIndex+2].x = x;
			uvBuffer[vertIndex+2].y = y+height;
			uvBuffer[vertIndex+3].x = x+width;
			uvBuffer[vertIndex+3].y = y+height;
		}
		
		public static function fillUV2(uvRect:Rectangle):void
		{
			var vertIndex:int = (quadCount-1)*4;
			uvBuffer[vertIndex].x = uvRect.x;
			uvBuffer[vertIndex].y = uvRect.y;
			uvBuffer[vertIndex+1].x = uvRect.right;
			uvBuffer[vertIndex+1].y = uvRect.y;
			uvBuffer[vertIndex+2].x = uvRect.x;
			uvBuffer[vertIndex+2].y = uvRect.bottom;
			uvBuffer[vertIndex+3].x = uvRect.right;
			uvBuffer[vertIndex+3].y = uvRect.bottom;
		}
		
		public static function fillUV3(uvRect:Rectangle, ratioX:Number, ratioY:Number):void
		{
			var vertIndex:int = (quadCount-1)*4;
			uvBuffer[vertIndex].x = uvRect.x;
			uvBuffer[vertIndex].y = uvRect.y;
			uvBuffer[vertIndex+1].x = uvRect.x + uvRect.width*ratioX;
			uvBuffer[vertIndex+1].y = uvRect.y;
			uvBuffer[vertIndex+2].x = uvRect.x;
			uvBuffer[vertIndex+2].y = uvRect.y + uvRect.height*ratioY;
			uvBuffer[vertIndex+3].x = uvBuffer[vertIndex+1].x;
			uvBuffer[vertIndex+3].y = uvBuffer[vertIndex+2].y;
		}
		
		public static function fillUV4(texture:Texture):void
		{
			for(var i:int=0;i<8;i++)
				helperTexCoords[i] = FULL_UV[i];
			texture.adjustTexCoords(helperTexCoords);
			
			var x:Number = helperTexCoords[0];
			var y:Number = helperTexCoords[1];
			var width:Number = helperTexCoords[6]-x;
			var height:Number = helperTexCoords[7]-y;
			
			var vertIndex:int = (quadCount-1)*4;
			uvBuffer[vertIndex].x = x;
			uvBuffer[vertIndex].y = y;
			uvBuffer[vertIndex+1].x = x + width;
			uvBuffer[vertIndex+1].y = y;
			uvBuffer[vertIndex+2].x = x;
			uvBuffer[vertIndex+2].y = y + height;
			uvBuffer[vertIndex+3].x = x + width;
			uvBuffer[vertIndex+3].y = y + height;
		}
		
		public static function fillImage(method:int, amount:Number, origin:int, clockwise:Boolean,
									vertRect:Rectangle, uvRect:Rectangle):void
		{
			var amount:Number = amount>1?1:(amount<0?0:amount);
			switch(method)
			{
				case FillType.FillMethod_Horizontal:
					fillHorizontal(origin, amount, vertRect, uvRect);
					break;
				
				case FillType.FillMethod_Vertical:
					fillVertical(origin, amount, vertRect, uvRect);
					break;
				
				case FillType.FillMethod_Radial90:
					fillRadial90(origin, amount, clockwise, vertRect, uvRect);
					break;
				
				case FillType.FillMethod_Radial180:
					fillRadial180(origin, amount, clockwise, vertRect, uvRect);
					break;
				
				case FillType.FillMethod_Radial360:
					fillRadial360(origin, amount, clockwise, vertRect, uvRect);
					break;	
			}
		}
		
		public static function fillHorizontal(origin:int, amount:Number, 
					vertRect:Rectangle, uvRect:Rectangle):void
		{
			if (origin == FillType.OriginHorizontal_Left)
			{
				vertRect.width = vertRect.width * amount;
				uvRect.width = uvRect.width * amount;
			}
			else
			{
				vertRect.x += vertRect.width * (1 - amount);
				vertRect.width = vertRect.width * amount;
				uvRect.x += uvRect.width * (1 - amount);
				uvRect.width = uvRect.width * amount;
			}
			
			addQuad2(vertRect);
			fillUV2(uvRect);
		}
		
		public static function fillVertical(origin:int, amount:Number, 
											vertRect:Rectangle, uvRect:Rectangle):void
		{
			if (origin == FillType.OriginVertical_Bottom)
			{
				vertRect.y += vertRect.height * (1 - amount);
				vertRect.height = vertRect.height * amount;
				uvRect.y += uvRect.height*(1-amount);
				uvRect.height = uvRect.height * amount;
			}
			else
			{
				vertRect.height = vertRect.height * amount;
				uvRect.height = uvRect.height * amount;
			}
			
			addQuad2(vertRect);
			fillUV2(uvRect);
		}
		
		public static function fillRadial90(origin:int, amount:Number, clockwise:Boolean, 
											vertRect:Rectangle, uvRect:Rectangle):void
		{			
			if (amount < 0.001)
				return;
			
			addQuad2(vertRect);
			fillUV2(uvRect);
			
			if (amount > 0.999)
				return;
			
			var v:Number, h:Number, ratio:Number;
			switch (origin)
			{
				case FillType.Origin90_BottomLeft:
				{
					if (clockwise)
					{
						v = Math.tan(Math.PI / 2 * (1 - amount));
						h = vertRect.width * v;
						if (h > vertRect.height)
						{
							ratio = (h - vertRect.height) / h;
							vertBuffer[1].x -= vertRect.width * ratio;
							vertBuffer[3].copyFrom(vertBuffer[1]);
							
							uvBuffer[1].x -= uvRect.width * ratio;
							uvBuffer[3].copyFrom(uvBuffer[1]);
						}
						else
						{
							ratio = h / vertRect.height;
							vertBuffer[3].y -= h;
							uvBuffer[3].y -= uvRect.height * ratio;
						}
					}
					else
					{
						v = Math.tan(Math.PI / 2 * amount);
						h = vertRect.width * v;
						if (h > vertRect.height)
						{
							ratio = (h - vertRect.height) / h;
							vertBuffer[0].x += vertRect.width * (1 - ratio);
							uvBuffer[0].x += uvRect.width * (1 - ratio);
						}
						else
						{
							ratio = h / vertRect.height;
							vertBuffer[1].y += vertRect.height * (1 - ratio);
							vertBuffer[0].copyFrom(vertBuffer[1]);
							
							uvBuffer[1].y += uvRect.height * (1 - ratio);
							uvBuffer[0].copyFrom(uvBuffer[1]);
						}
					}
					break;
				}
				
				case FillType.Origin90_BottomRight:
				{
					if (clockwise)
					{
						v = Math.tan(Math.PI / 2 * amount);
						h = vertRect.width * v;
						if (h > vertRect.height)
						{
							ratio = (h - vertRect.height) / h;
							vertBuffer[1].x -= vertRect.width * (1 - ratio);
							uvBuffer[1].x -= uvRect.width * (1 - ratio);
						}
						else
						{
							ratio = h / vertRect.height;
							vertBuffer[0].y += vertRect.height * (1 - ratio);
							vertBuffer[1].copyFrom(vertBuffer[3]);
							
							uvBuffer[0].y += uvRect.height * (1 - ratio);
							uvBuffer[1].copyFrom(uvBuffer[3]);
						}
					}
					else
					{
						v =  Math.tan(Math.PI / 2 * (1 - amount));
						h = vertRect.width * v;
						if (h > vertRect.height)
						{
							ratio = (h - vertRect.height) / h;
							vertBuffer[0].x += vertRect.width * ratio;
							vertBuffer[2].copyFrom(vertBuffer[0]);
							
							uvBuffer[0].x += uvRect.width * ratio;
							uvBuffer[2].copyFrom(uvBuffer[0]);
						}
						else
						{
							ratio = h / vertRect.height;
							vertBuffer[2].y -= h;
							uvBuffer[2].y -= uvRect.height * ratio;
						}
					}
					break;
				}					
				
				case FillType.Origin90_TopLeft:
				{
					if (clockwise)
					{
						v = Math.tan(Math.PI / 2 * amount);
						h = vertRect.width * v;
						if (h > vertRect.height)
						{
							ratio = (h - vertRect.height) / h;
							vertBuffer[2].x += vertRect.width * (1 - ratio);
							uvBuffer[2].x += uvRect.width * (1 - ratio);
						}
						else
						{
							ratio = h / vertRect.height;
							vertBuffer[3].y -= vertRect.height * (1 - ratio);
							vertBuffer[2].copyFrom(vertBuffer[3]);
							
							uvBuffer[3].y -= uvRect.height * (1 - ratio);
							uvBuffer[2].copyFrom(uvBuffer[3]);
						}
					}
					else
					{
						v =  Math.tan(Math.PI / 2 * (1 - amount));
						h = vertRect.width * v;
						if (h > vertRect.height)
						{
							ratio = (h - vertRect.height) / h;
							vertBuffer[3].x -= vertRect.width * ratio;
							vertBuffer[1].copyFrom(vertBuffer[3]);
							uvBuffer[3].x -= uvRect.width * ratio;
							uvBuffer[1].copyFrom(uvBuffer[3]);
						}
						else
						{
							ratio = h / vertRect.height;
							vertBuffer[1].y += h;
							uvBuffer[1].y += uvRect.height * ratio;
						}
					}
					break;
				}					
				
				case FillType.Origin90_TopRight:
				{
					if (clockwise)
					{
						v =  Math.tan(Math.PI / 2 * (1 - amount));
						h = vertRect.width * v;
						if (h > vertRect.height)
						{
							ratio = (h - vertRect.height) / h;
							vertBuffer[2].x += vertRect.width * ratio;
							vertBuffer[0].copyFrom(vertBuffer[1]);
							uvBuffer[2].x += uvRect.width * ratio;
							uvBuffer[0].copyFrom(uvBuffer[1]);
						}
						else
						{
							ratio = h / vertRect.height;
							vertBuffer[0].y += vertRect.height * ratio;
							uvBuffer[0].y += uvRect.height * ratio;
						}
					}
					else
					{
						v = Math.tan(Math.PI / 2 * amount);
						h = vertRect.width * v;
						if (h > vertRect.height)
						{
							ratio = (h - vertRect.height) / h;
							vertBuffer[3].x -= vertRect.width * (1 - ratio);
							uvBuffer[3].x -= uvRect.width * (1 - ratio);
						}
						else
						{
							ratio = h / vertRect.height;
							vertBuffer[2].y -= vertRect.height * (1 - ratio);
							vertBuffer[3].copyFrom(vertBuffer[2]);
							uvBuffer[2].y -= uvRect.height * (1 - ratio);
							uvBuffer[3].copyFrom(uvBuffer[2]);
						}
					}
				}
				break;
			}
		}
		
		public static function fillRadial180(origin:int, amount:Number, clockwise:Boolean, 
											vertRect:Rectangle, uvRect:Rectangle):void
		{			
			if (amount < 0.001)
				return;
			
			if (amount > 0.999)
			{
				addQuad2(vertRect);
				fillUV2(uvRect);
				return;
			}
			
			helperRect1.copyFrom(vertRect);
			helperRect2.copyFrom(uvRect);
			
			vertRect = helperRect1;
			uvRect = helperRect2;
			
			var v:Number, h:Number, ratio:Number;
			switch (origin)
			{
				case FillType.Origin180_Top:
					if (amount <= 0.5)
					{
						vertRect.width /= 2;
						uvRect.width /= 2;
						if (clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						amount = amount / 0.5;
						fillRadial90(clockwise ? FillType.Origin90_TopLeft : FillType.Origin90_TopRight, amount, clockwise, vertRect, uvRect);
					}
					else
					{
						vertRect.width /= 2;
						uvRect.width /= 2;
						if (!clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						amount = (amount - 0.5) / 0.5;
						fillRadial90(clockwise ? FillType.Origin90_TopRight : FillType.Origin90_TopLeft, amount, clockwise, vertRect, uvRect);
						
						if (clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						else
						{
							vertRect.x -= vertRect.width;
							uvRect.x -= uvRect.width;
						}
						addQuad2(vertRect);
						fillUV2(uvRect);
					}
					break;
				
				case FillType.Origin180_Bottom:
					if (amount <= 0.5)
					{
						vertRect.width /= 2;
						uvRect.width /= 2;
						if (!clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						amount = amount / 0.5;
						fillRadial90(clockwise ? FillType.Origin90_BottomRight : FillType.Origin90_BottomLeft, amount, clockwise, vertRect, uvRect);
					}
					else
					{
						vertRect.width /= 2;
						uvRect.width /= 2;
						if (clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						amount = (amount - 0.5) / 0.5;
						fillRadial90(clockwise ? FillType.Origin90_BottomLeft : FillType.Origin90_BottomRight, amount, clockwise, vertRect, uvRect);
						
						if (clockwise)
						{
							vertRect.x -= vertRect.width;
							uvRect.x -= uvRect.width;
						}
						else
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						addQuad2(vertRect);
						fillUV2(uvRect);
					}
					break;
				
				case FillType.Origin180_Left:
					if (amount <= 0.5)
					{
						if (clockwise)
						{
							vertRect.height /= 2;
							uvRect.height /= 2;
						}
						else
						{
							vertRect.height /= 2;
							vertRect.y += vertRect.height;
							uvRect.height /= 2;
							uvRect.y += uvRect.height;
						}
						amount = amount / 0.5;
						fillRadial90(clockwise ? FillType.Origin90_BottomLeft : FillType.Origin90_TopLeft, amount, clockwise, vertRect, uvRect);
					}
					else
					{
						if (clockwise)
						{
							vertRect.height /= 2;
							vertRect.y += vertRect.height;
							uvRect.height /= 2;
							uvRect.y += uvRect.height;
						}
						else
						{
							vertRect.height /= 2;
							uvRect.height /= 2;
						}
						amount = (amount - 0.5) / 0.5;
						fillRadial90(clockwise ? FillType.Origin90_TopLeft : FillType.Origin90_BottomLeft, amount, clockwise, vertRect, uvRect);
						
						if (clockwise)
						{
							vertRect.y -= vertRect.height;
							uvRect.y -= uvRect.height;
						}
						else
						{
							vertRect.y += vertRect.height;
							uvRect.y += uvRect.height;
						}
						addQuad2(vertRect);
						fillUV2(uvRect);
					}
					break;
				
				case FillType.Origin180_Right:
					if (amount <= 0.5)
					{
						if (clockwise)
						{
							vertRect.height /= 2;
							vertRect.y += vertRect.height;
							uvRect.height /= 2;
							uvRect.y += uvRect.height;
						}
						else
						{
							vertRect.height /= 2;
							uvRect.height /= 2;
						}
						amount = amount / 0.5;
						fillRadial90(clockwise ? FillType.Origin90_TopRight : FillType.Origin90_BottomRight, amount, clockwise, vertRect, uvRect);
					}
					else
					{
						if (clockwise)
						{
							vertRect.height /= 2;
							uvRect.height /= 2;
						}
						else
						{
							vertRect.height /= 2;
							vertRect.y += vertRect.height;
							uvRect.height /= 2;					
							uvRect.y += uvRect.height;
						}
						amount = (amount - 0.5) / 0.5;
						fillRadial90(clockwise ? FillType.Origin90_BottomRight : FillType.Origin90_TopRight, amount, clockwise, vertRect, uvRect);
						
						if (clockwise)
						{
							vertRect.y += vertRect.height;
							uvRect.y += uvRect.height;
						}
						else
						{
							vertRect.y -= vertRect.height;
							uvRect.y -= uvRect.height;
						}
						addQuad2(vertRect);
						fillUV2(uvRect);
					}
					break;
			}
		}
		
		public static function fillRadial360(origin:int, amount:Number, clockwise:Boolean, 
											 vertRect:Rectangle, uvRect:Rectangle):void
		{			
			if (amount < 0.001)
				return;
			
			if (amount > 0.999)
			{
				addQuad2(vertRect);
				fillUV2(uvRect);
				return;
			}
			
			helperRect3.copyFrom(vertRect);
			helperRect4.copyFrom(uvRect);
			
			vertRect = helperRect3;
			uvRect = helperRect4;
			
			switch (origin)
			{
				case FillType.Origin360_Top:
					if (amount < 0.5)
					{
						amount = amount / 0.5;
						vertRect.width /= 2;
						uvRect.width /= 2;
						if (clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						fillRadial180(clockwise ? FillType.Origin180_Left : FillType.Origin180_Right, amount, clockwise, vertRect, uvRect);
					}
					else
					{
						vertRect.width /= 2;
						uvRect.width /= 2;
						if (!clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						amount = (amount - 0.5) / 0.5;
						fillRadial180(clockwise ? FillType.Origin180_Right : FillType.Origin180_Left, amount, clockwise, vertRect, uvRect);
						
						if (clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						else
						{
							vertRect.x -= vertRect.width;
							uvRect.x -= uvRect.width;
						}
						addQuad2(vertRect);
						fillUV2(uvRect);
					}
					break;
				
				case FillType.Origin360_Bottom:
					if (amount < 0.5)
					{
						amount = amount / 0.5;
						vertRect.width /= 2;
						uvRect.width /= 2;
						if (!clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						fillRadial180(clockwise ? FillType.Origin180_Right : FillType.Origin180_Left, amount, clockwise, vertRect, uvRect);
					}
					else
					{
						vertRect.width /= 2;
						uvRect.width /= 2;
						if (clockwise)
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						amount = (amount - 0.5) / 0.5;
						fillRadial180(clockwise ? FillType.Origin180_Left : FillType.Origin180_Right, amount, clockwise, vertRect, uvRect);
						
						if (clockwise)
						{
							vertRect.x -= vertRect.width;
							uvRect.x -= uvRect.width;
						}
						else
						{
							vertRect.x += vertRect.width;
							uvRect.x += uvRect.width;
						}
						addQuad2(vertRect);
						fillUV2(uvRect);
					}
					break;
				
				case FillType.Origin360_Left:
					if (amount < 0.5)
					{
						amount = amount / 0.5;
						if (clockwise)
						{
							vertRect.height /= 2;
							uvRect.height /= 2;
						}
						else
						{
							vertRect.height /= 2;
							vertRect.y += vertRect.height;
							uvRect.height /= 2;
							uvRect.y += uvRect.height;
						}
						fillRadial180(clockwise ? FillType.Origin180_Bottom : FillType.Origin180_Top, amount, clockwise, vertRect, uvRect);
					}
					else
					{
						if (clockwise)
						{
							vertRect.height /= 2;
							vertRect.y += vertRect.height;
							uvRect.height /= 2;
							uvRect.y += uvRect.height;
						}
						else
						{
							vertRect.height /= 2;
							uvRect.height /= 2;
						}
						amount = (amount - 0.5) / 0.5;
						fillRadial180(clockwise ? FillType.Origin180_Top : FillType.Origin180_Bottom, amount, clockwise, vertRect, uvRect);
						
						if (clockwise)
						{
							vertRect.y -= vertRect.height;
							uvRect.y -= uvRect.height;
						}
						else
						{
							vertRect.y += vertRect.height;
							uvRect.y += uvRect.height;
						}
						addQuad2(vertRect);
						fillUV2(uvRect);
					}
					break;
				
				case FillType.Origin360_Right:
					if (amount < 0.5)
					{
						if (clockwise)
						{
							vertRect.height /= 2;
							vertRect.y += vertRect.height;
							uvRect.height /= 2;
							uvRect.y += uvRect.height;
						}
						else
						{
							vertRect.height /= 2;
							uvRect.height /= 2;
						}
						amount = amount / 0.5;
						fillRadial180(clockwise ? FillType.Origin180_Top : FillType.Origin180_Bottom, amount, clockwise, vertRect, uvRect);
					}
					else
					{
						if (clockwise)
						{
							vertRect.height /= 2;
							uvRect.height /= 2;
						}
						else
						{
							vertRect.height /= 2;
							vertRect.y += vertRect.height;
							uvRect.height /= 2;
							uvRect.y += uvRect.height;
						}
						
						amount = (amount - 0.5) / 0.5;
						fillRadial180(clockwise ? FillType.Origin180_Bottom : FillType.Origin180_Top, amount, clockwise, vertRect, uvRect);
						
						if (clockwise)
						{
							vertRect.y += vertRect.height;
							uvRect.y += uvRect.height;
						}
						else
						{
							vertRect.y -= vertRect.height;
							uvRect.y -= uvRect.height;
						}
						addQuad2(vertRect);
						fillUV2(uvRect);
					}
					break;
			}
		}
	}
}


import starling.display.Quad;
import starling.utils.VertexData;

class HelperQuad extends Quad
{		
	public var vectexData:VertexData;
	public function HelperQuad()
	{			
		super(1, 1);
		
		this.vectexData = mVertexData;
	}
	
}