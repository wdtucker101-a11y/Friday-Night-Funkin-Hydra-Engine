package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(1280, 720, MainMenuState, 240, 240, true));

		#if !mobile
		var fps = new FPS(0, 0, 0xFFFFFF);
		addChild(fps);
		#end

		addEventListener(Event.ENTER_FRAME, update);
	}

	private function update(event:Event)
	{
		if (FlxG.keys.anyJustPressed([F11])) FlxG.fullscreen = !FlxG.fullscreen;
	}
}
