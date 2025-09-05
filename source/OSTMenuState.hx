package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.Assets;
import sys.FileSystem;
import sys.io.File;

typedef Song = 
{
    name:String,
    location:String,
    voices:Bool,
    vocalslocation:String
};

class OSTMenuState extends FlxState
{
    var songsArray:Array<FlxText> = [];

    var optionsArray:Array<String> = [];
    var vocalsArray:Array<String> = [];

    var optionSelected:Int = 0;

    var music:FlxSound;
    var vocals:FlxSound;

    var timeRemainingText:FlxText;

    var gameCamera:FlxCamera;
    var hudCamera:FlxCamera;

    var objToLook:FlxSprite;

    var disk:FlxSprite;

    var pauseButton:FlxSprite;
    var playButton:FlxSprite;
    var rewindButton:FlxSprite;
    var speedButton:FlxSprite;
    var slowButton:FlxSprite;
    var manualButton:FlxSprite;

    var manualWindow:ManualSubState;

    var canInteract:Bool = true;

    override public function create()
    {
        gameCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        gameCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(gameCamera);

        hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        hudCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(hudCamera);

        FlxG.mouse.visible = true;

        FlxG.autoPause = false;

        var bgVelocity:Int = 15;
        
        var bg:FlxBackdrop = new FlxBackdrop();
        bg.loadGraphic('assets/images/ui/arrow.png', false);
        bg.velocity.x = bgVelocity;
        bg.velocity.y = bgVelocity;
        bg.screenCenter();
        bg.antialiasing = true;
        bg.visible = true;
        bg.alpha = 0.25;
        add(bg);
        bg.cameras = [gameCamera];

        var fileData:Array<Song>;

        if (FileSystem.exists('assets/music/music.json'))
        {
            fileData = Json.parse(File.getContent('assets/music/music.json'));

            var yPosition:Int = 0;
            for (i in 0...fileData.length)
            {
                var song:Song = fileData[i];
                var text:FlxText = new FlxText(0, 0 + yPosition, 0, '' + song.name, 32);
                text.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
                text.antialiasing = true;
                add(text);
                text.cameras = [hudCamera];
                songsArray.push(text);
                optionsArray.push(song.location);
                if (song.voices = true) vocalsArray.push(song.vocalslocation);
                yPosition += 50;
            }
        }
        else
        {
            Sys.println('Cant reach to the "music.json" file, please try to see if the file isnt damaged or just check the location.');
        }

        var timerBar:FlxSprite = new FlxSprite(0, 25);
        timerBar.loadGraphic('assets/images/ui/timerBar.png', false);
        timerBar.screenCenter(X);
        timerBar.antialiasing = true;
        add(timerBar);
        timerBar.cameras = [gameCamera];

        timeRemainingText = new FlxText(0, 50, FlxG.width, "", 24);
        timeRemainingText.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        timeRemainingText.antialiasing = true;
        add(timeRemainingText);
        timeRemainingText.cameras = [gameCamera];

        objToLook = new FlxSprite(450);
        objToLook.visible = false;
        add(objToLook);
        objToLook.cameras = [hudCamera];

        var alphabg:FlxSprite = new FlxSprite(0, FlxG.height - 25);
        alphabg.makeGraphic(FlxG.width, 25, FlxColor.BLACK);
        alphabg.alpha = 0.65;
        alphabg.antialiasing = true;
        add(alphabg);
        alphabg.cameras = [gameCamera];

        var textbg:FlxText = new FlxText(0, FlxG.height - 25, FlxG.width, 'Press ENTER to play the selected song. Press ESCAPE to return to the Main Menu!', 12);
        textbg.setFormat('assets/fonts/vcr.ttf', 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        textbg.screenCenter(X);
        textbg.antialiasing = true;
        add(textbg);
        textbg.cameras = [gameCamera];

        disk = new FlxSprite(600);
        disk.loadGraphic('assets/images/ui/disk.png', false);
        disk.antialiasing = true;
        disk.screenCenter(Y);
        add(disk);
        disk.cameras = [gameCamera];

        slowButton = new FlxSprite(535, FlxG.height - 100);
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/button_slow.png', 'assets/images/ui/button_slow.xml');
        slowButton.frames = frames;
        slowButton.antialiasing = true;
        slowButton.animation.addByPrefix('idle', 'buttonslow_norm', 24);
        slowButton.animation.addByPrefix('click', 'buttonslow_click', 24);
        slowButton.setGraphicSize(100);
        slowButton.updateHitbox();
        add(slowButton);
        slowButton.cameras = [gameCamera];
        slowButton.animation.play('idle');

        pauseButton = new FlxSprite(655, FlxG.height - 100);
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/button_pause.png', 'assets/images/ui/button_pause.xml');
        pauseButton.frames = frames;
        pauseButton.antialiasing = true;
        pauseButton.animation.addByPrefix('idle', 'buttonpause_norm', 24);
        pauseButton.animation.addByPrefix('click', 'buttonpause_click', 24);
        pauseButton.setGraphicSize(100);
        pauseButton.updateHitbox();
        add(pauseButton);
        pauseButton.cameras = [gameCamera];
        pauseButton.animation.play('idle');

        playButton = new FlxSprite(775, FlxG.height - 100);
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/button_play.png', 'assets/images/ui/button_play.xml');
        playButton.frames = frames;
        playButton.antialiasing = true;
        playButton.animation.addByPrefix('idle', 'buttonplay_norm', 24);
        playButton.animation.addByPrefix('click', 'buttonplay_click', 24);
        playButton.setGraphicSize(100);
        playButton.updateHitbox();
        add(playButton);
        playButton.cameras = [gameCamera];
        playButton.animation.play('idle');

        rewindButton = new FlxSprite(895, FlxG.height - 100);
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/button_rewind.png', 'assets/images/ui/button_rewind.xml');
        rewindButton.frames = frames;
        rewindButton.antialiasing = true;
        rewindButton.animation.addByPrefix('idle', 'buttonreverse_norm', 24);
        rewindButton.animation.addByPrefix('click', 'buttonreverse_click', 24);
        rewindButton.setGraphicSize(100);
        rewindButton.updateHitbox();
        add(rewindButton);
        rewindButton.cameras = [gameCamera];
        rewindButton.animation.play('idle');

        speedButton = new FlxSprite(1015, FlxG.height - 100);
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/button_speed.png', 'assets/images/ui/button_speed.xml');
        speedButton.frames = frames;
        speedButton.antialiasing = true;
        speedButton.animation.addByPrefix('idle', 'buttonspeed_norm', 24);
        speedButton.animation.addByPrefix('click', 'buttonspeed_click', 24);
        speedButton.setGraphicSize(100);
        speedButton.updateHitbox();
        add(speedButton);
        speedButton.cameras = [gameCamera];
        speedButton.animation.play('idle');

        manualButton = new FlxSprite(35, FlxG.height - 95);
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/button_manual.png', 'assets/images/ui/button_manual.xml');
        manualButton.frames = frames;
        manualButton.antialiasing = true;
        manualButton.animation.addByPrefix('idle', 'buttonmanual_norm', 24);
        manualButton.animation.addByPrefix('click', 'buttonmanual_click', 24);
        manualButton.setGraphicSize(100);
        manualButton.updateHitbox();
        add(manualButton);
        manualButton.cameras = [gameCamera];
        manualButton.animation.play('idle');

        var selector = new FlxSprite(100);
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/freeplaySelector.png', 'assets/images/ui/freeplaySelector.xml');
        selector.frames = frames;
        selector.animation.addByPrefix('idleloop', 'arrow pointer loop', 24, true);
        selector.animation.play('idleloop');
        selector.y = FlxG.height - 382.5;
        selector.antialiasing = true;
        //selector.updateHitbox();
        selector.flipX = true;
        add(selector);
        selector.cameras = [gameCamera];

        super.create();

        var newCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        newCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(newCamera);

        manualWindow = new ManualSubState();
        add(manualWindow);
        manualWindow.removeWindow();
        manualWindow.cameras = [newCamera];

        var stickers = new StickersAnimationSubState();
        add(stickers);
        stickers.generateStickers(175, 1, 0);
        stickers.cameras = [newCamera];
        stickers.removeStickers(2);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(manualButton) && FlxG.mouse.justPressed && canInteract == true)
        {
            manualWindow.addWindow();
        }

        if (FlxG.mouse.overlaps(manualButton) && FlxG.mouse.justPressed && canInteract == true)
        {
            manualButton.animation.play('click');
            new FlxTimer().start(0.1, (timer) -> 
            {
                manualButton.animation.play('idle');
            });
        }

        if (music != null && music.playing && FlxG.mouse.overlaps(slowButton) && FlxG.mouse.justPressed && canInteract == true)
        {
            music.pitch -= 0.1;
            if (vocals != null) vocals.pitch = music.pitch;
            slowButton.animation.play('click');
            new FlxTimer().start(0.1, (timer) -> 
            {
                slowButton.animation.play('idle');
            });
        }

        if (music != null && music.playing && FlxG.mouse.overlaps(speedButton) && FlxG.mouse.justPressed && canInteract == true)
        {
            music.pitch += 0.1;
            if (vocals != null) vocals.pitch = music.pitch;
            speedButton.animation.play('click');
            new FlxTimer().start(0.1, (timer) -> 
            {
                speedButton.animation.play('idle');
            });
        }

        if (music != null && music.playing && FlxG.mouse.overlaps(pauseButton) && FlxG.mouse.justPressed && canInteract == true)
        {
            music.pause();
            if (vocals != null) vocals.pause();
            pauseButton.animation.play('click');
            new FlxTimer().start(0.1, (timer) -> 
            {
                pauseButton.animation.play('idle');
            });
        }

        if (music != null && !music.playing && FlxG.mouse.overlaps(playButton) && FlxG.mouse.justPressed && canInteract == true)
        {
            music.resume();
            if (vocals != null) vocals.resume();
            playButton.animation.play('click');
            new FlxTimer().start(0.1, (timer) -> 
            {
                playButton.animation.play('idle');
            });
        }
        else if (music == null && FlxG.mouse.overlaps(playButton) && FlxG.mouse.justPressed && canInteract == true)
        {
            FlxTween.tween(disk, { angle: 0 }, 0.5,
                { 
                    type:       ONESHOT,
                    ease:       FlxEase.backIn,
                    onComplete: null,
                    startDelay: 0,
                    loopDelay:  0.5
                }
            );
            if (music != null && music.playing) 
            {
                music.stop();
            }

            if (vocals != null && vocals.playing)
            {
                vocals.stop();
            }

            music = FlxG.sound.load(optionsArray[optionSelected]);
            if (vocalsArray[optionSelected] != null)
            {
                vocals = FlxG.sound.load(vocalsArray[optionSelected]);
                vocals.play();
            }
            music.play();
            playButton.animation.play('click');
            new FlxTimer().start(0.1, (timer) -> 
            {
                playButton.animation.play('idle');
            });
        }

        if (music != null && music.playing && FlxG.mouse.overlaps(rewindButton) && FlxG.mouse.justPressed && canInteract == true)
        {
            disk.angle -= 20;
            music.pause();
            music.time -= 1500;
            if (vocals != null)
            {
                vocals.pause();
                vocals.time -= 1500;
                vocals.resume();
            }
            music.resume();
            rewindButton.animation.play('click');
            new FlxTimer().start(0.1, (timer) -> 
            {
                rewindButton.animation.play('idle');
            });
        }

        if (music != null && music.playing) disk.angle += (music.pitch * 30) * elapsed;

        hudCamera.follow(objToLook, LOCKON, 1);

        if (music != null && music.playing)
        {
            var remaining:Float = music.length - music.time;
            var minutes:Int = Std.int(remaining / 60);
            var seconds:Int = Std.int(remaining % 60);
            var timeString:String = StringTools.lpad("" + minutes, "0", 2) + ":" + StringTools.lpad("" + seconds, "0", 2);
            timeRemainingText.text = "" + timeString;
        }
        else
        {
            timeRemainingText.text = "--:--";
        }

        if (FlxG.keys.anyJustPressed([ESCAPE]))
        {
            FlxG.switchState(new MainMenuState());
            if (music != null && music.playing) music.destroy();
        }

        if (FlxG.keys.anyJustPressed([ENTER, SPACE])) 
        {
            FlxTween.tween(disk, { angle: 0 }, 0.5,
                { 
                    type:       ONESHOT,
                    ease:       FlxEase.backIn,
                    onComplete: null,
                    startDelay: 0,
                    loopDelay:  0.5
                }
            );
            if (music != null && music.playing) 
            {
                music.stop();
            }

            if (vocals != null && vocals.playing)
            {
                vocals.stop();
            }

            music = FlxG.sound.load(optionsArray[optionSelected]);
            if (vocalsArray[optionSelected] != null)
            {
                vocals = FlxG.sound.load(vocalsArray[optionSelected]);
                vocals.play();
            }
            music.play();
        }

        if (FlxG.keys.anyJustPressed([DOWN, S])) 
        {
            optionSelected = (optionSelected + 1) % songsArray.length;
        }
        else if (FlxG.keys.anyJustPressed([UP, W])) 
        {
            optionSelected = (optionSelected - 1 + songsArray.length) % songsArray.length;
        }

        for (i in 0...songsArray.length)
        {
            var text:FlxText = songsArray[i];
            if (optionSelected == i)
            {
                FlxTween.tween(objToLook, { y: text.y }, 0.5,
                { 
                    type:       ONESHOT,
                    ease:       FlxEase.backIn,
                    onComplete: null,
                    startDelay: 0,
                    loopDelay:  0.5
                }
                );
                text.color = 0x00FF33;
            }
            else
            {
                text.color = 0xFFFFFF;
            }
        }
    }
}

class ManualSubState extends FlxTypedGroup<FlxSprite>
{
    var bg:FlxSprite;
    var alphabg:FlxSprite;
    var text:FlxText;
    var instructions:FlxText;
    var close:FlxSprite;

    var bgbutton:FlxSprite;
    var textbutton:FlxText;

    public function new()
    {
        super();

        bg = new FlxSprite();
        bg.makeGraphic(325, 450, FlxColor.WHITE);
        bg.color = 0x1A1A1A;
        bg.alpha = 1;
        bg.visible = true;
        add(bg);

        alphabg = new FlxSprite();
        alphabg.makeGraphic(325, 50, FlxColor.WHITE);
        alphabg.color = 0x2F2F2F;
        alphabg.alpha = 1;
        alphabg.visible = true;
        add(alphabg);

        text = new FlxText(bg.x + 15, bg.y + 10, 0, 'Manual', 16);
        text.setFormat('assets/fonts/vcr.ttf', 14, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        text.antialiasing = true;
        add(text);

        instructions = new FlxText(15, 65, 0, 'This is the OST Menu, here you can\nlisten all the songs in the game!', 16);
        instructions.setFormat('assets/fonts/vcr.ttf', 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        instructions.antialiasing = true;
        add(instructions);

        close = new FlxSprite(303, 10);
        close.loadGraphic('assets/images/ui/close.png', false);
        close.updateHitbox();
        close.antialiasing = true;
        add(close);
        
        bgbutton = new FlxSprite(bg.x + 15, bg.y + 400);
        bgbutton.makeGraphic(125, 35, FlxColor.WHITE);
        bgbutton.color = 0x343434;
        bgbutton.antialiasing = true;
        add(bgbutton);

        textbutton = new FlxText(bg.x + 20, bg.y + 402.5, 0, 'See Github!', 16);
        textbutton.setFormat('assets/fonts/vcr.ttf', 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        textbutton.antialiasing = true;
        add(textbutton);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(bgbutton) && FlxG.mouse.justPressed)
        {
            FlxG.openURL('https://github.com/wdtucker101-a11y/Friday-Night-Funkin-Hydra-Engine?tab=readme-ov-file');
        }

        if (FlxG.mouse.overlaps(alphabg) && !FlxG.mouse.overlaps(close) && FlxG.mouse.pressed)
        {
            var offsetX = -bg.width / 2;
            var offsetY = -alphabg.height / 2;

            bg.setPosition(FlxG.mouse.x + offsetX, FlxG.mouse.y + offsetY);
            alphabg.setPosition(bg.x, bg.y);
            text.setPosition(bg.x + 15, bg.y + 10);
            instructions.setPosition(bg.x + 15, bg.y + 65);
            close.setPosition(bg.x + bg.width - close.width - 10, bg.y + 10);
            bgbutton.setPosition(bg.x + 15, bg.y + 400);
            textbutton.setPosition(bg.x + 20, bg.y + 402.5);
        }

        if (FlxG.mouse.overlaps(close) && FlxG.mouse.justPressed)
        {
            removeWindow();
        }
    }

    public function addWindow()
    {
        add(bg);
        add(alphabg);
        add(text);
        add(instructions);
        add(close);
        add(bgbutton);
        add(textbutton);
    }

    public function removeWindow()
    {
        remove(bg);
        remove(alphabg);
        remove(text);
        remove(instructions);
        remove(close);
        remove(bgbutton);
        remove(textbutton);
    }
}

