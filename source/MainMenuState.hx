package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.Json;
import sys.io.File;
#if !neko
import hxwindowmode.WindowColorMode;
#end

class MenuButton extends FlxTypedGroup<FlxSprite>
{
    public var xx:Float;
    public var yy:Float;

    var sprite:FlxSprite;
    var text:FlxText;

    public function new(name:String, ?x:Int = 0, ?y:Int = 0)
    {
        super();

        sprite = new FlxSprite(x, y);
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/freeplayCapsule.png', 'assets/images/ui/freeplayCapsule.xml');
        sprite.frames = frames;
        sprite.animation.addByPrefix('idle', 'mp3 capsule w backing NOT SELECTED', 12, true);
        sprite.animation.addByPrefix('overlaped', 'mp3 capsule w backing', 12, true);
        sprite.antialiasing = true;
        add(sprite);

        text = new FlxText(x - 350, y + 32, FlxG.width, '$name', 16);
        text.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        text.antialiasing = true;
        add(text);

        xx = x;
        yy = y;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        sprite.x = xx;
        text.x = xx - 350;
        sprite.y = yy;
        text.y = yy + 32;

        if (FlxG.mouse.overlaps(this))
        {
            sprite.animation.play('overlaped');
        }
        else 
        {
            sprite.animation.play('idle');
        }
    }
}

class MainMenuState extends FlxState
{
    var options:Array<String> = 
    [
        'OST'
        /*
        'SinglePlayer'#if ONLINE_SUPPORT
        ,
        'MultiPlayer'
        #end
        */
    ];

    var customEngineNames:Array<String> = 
    [
        'JASM',
        'Mattones',
        'Dyingonamoon',
        'Mrg0ld3n'
    ];

    var randomsTexts:Array<String> = 
    [
        'Today is the day!',
        'What game is this?',
        'Dont disturb the creators!',
        'Nah, what do you want from me?'
    ];

    public var optionSelected:Int = 0;

    public var optionsArray:Array<MenuButton> = [];

    var optionCamera:FlxCamera;
    var hudCamera:FlxCamera;
    var resetDataCamera:FlxCamera;

    var optionText:FlxText;

    var optionImage:FlxSprite;

    var optionSelector:FlxSprite;

    var canInteract:Bool = true;

    var resetDataSubState:EraseDataSubState;

    var music:FlxSound;

    static public var buildCount:String = 'Unkown';

    override public function create()
    {
        FlxG.save.bind('funkin', 'hydraengine');

        #if !neko
        WindowColorMode.setDarkMode();
        #end

        hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        hudCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(hudCamera);

        optionCamera = new FlxCamera(0, FlxG.height - 450, FlxG.width, FlxG.height, 1);
        optionCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(optionCamera);

        resetDataCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        resetDataCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(resetDataCamera);

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
        bg.cameras = [hudCamera];

        var xPosition:Int = 0;
        for (i in 0...options.length)
        {
            var obj = options[i];
            var button:MenuButton = new MenuButton(obj, xPosition, FlxG.height - 300);
            add(button);
            button.cameras = [optionCamera];
            optionsArray.push(button);
            xPosition += 600;
        }

        var engineValue = FlxG.random.int(0, customEngineNames.length - 1);

        var engineVer:FlxText = new FlxText(5, FlxG.height - 50, 0, customEngineNames[engineValue] + ' Engine 1.a\nBuild ' + buildCount, 16);
        engineVer.setFormat('assets/fonts/vcr.ttf', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        engineVer.antialiasing = true;
        add(engineVer);
        engineVer.cameras = [hudCamera];

        var textBg:FlxSprite = new FlxSprite();
        textBg.makeGraphic(FlxG.width, 40, FlxColor.BLACK);
        textBg.alpha = 0.5;
        textBg.antialiasing = true;
        textBg.screenCenter(XY);
        textBg.visible = true;
        add(textBg);
        textBg.cameras = [hudCamera];

        optionText = new FlxText(0, 0, FlxG.width, '', 16);
        optionText.setFormat('assets/fonts/vcr.ttf', 27, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        optionText.antialiasing = true;
        optionText.screenCenter(XY);
        add(optionText);
        optionText.cameras = [hudCamera];
        textBg.y = optionText.y;

        optionImage = new FlxSprite(0, 80);
        optionImage.loadGraphic('assets/images/ui/ost.png', false);
        optionImage.setGraphicSize(255);
        optionImage.antialiasing = true;
        optionImage.updateHitbox();
        optionImage.screenCenter(X);
        add(optionImage);
        optionImage.cameras = [hudCamera];

        optionSelector = new FlxSprite();
        var frames = FlxAtlasFrames.fromSparrow('assets/images/ui/freeplaySelector.png', 'assets/images/ui/freeplaySelector.xml');
        optionSelector.frames = frames;
        optionSelector.animation.addByPrefix('idleloop', 'arrow pointer loop', 24, true);
        optionSelector.animation.play('idleloop');
        optionSelector.angle = 90;
        optionSelector.y = FlxG.height - 150;
        optionSelector.antialiasing = true;
        add(optionSelector);
        optionSelector.cameras = [optionCamera];
        optionSelector.x = optionsArray[0].xx + 265;

        #if !mobile
        var resetText:FlxText = new FlxText(10, 5, 0, 'Press R to Reset Data', 16);
        resetText.setFormat('assets/fonts/vcr.ttf', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        resetText.antialiasing = true;
        add(resetText);
        resetText.cameras = [hudCamera];
        #end

        var randomTxt:FlxText = new FlxText(600, 270, 0, '', 22);
        randomTxt.setFormat('assets/fonts/vcr.ttf', 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        randomTxt.angle = 7.5;
        randomTxt.antialiasing = true;
        randomTxt.updateHitbox();
        add(randomTxt);
        randomizeText(randomTxt);
        randomTxt.cameras = [hudCamera];
        FlxTween.tween(randomTxt.scale, { x: 0.75, y: 0.75 }, 0.5, 
        {
            type: LOOPING,
            ease: FlxEase.backIn,
            startDelay: 1,
            loopDelay: 0.5
        });

        resetDataSubState = new EraseDataSubState();
        resetDataSubState.cameras = [resetDataCamera];

        music = FlxG.sound.load('assets/music/menus/menuMusic.ogg', 1, true);

        FlxG.autoPause = true;
        FlxG.mouse.visible = true;
        FlxG.mouse.load('assets/images/ui/cursors/cursor-default.png');

        super.create();

        music.play();
    }

    function randomizeText(text:FlxText)
    {
        var date = Date.now();
        var randomValue = FlxG.random.int(0, randomsTexts.length - 1);
        if (date.getMonth() == 4 && date.getDate() == 1)
        {
            text.text = 'April Fools!';
        }
        else
        {
            text.text = randomsTexts[randomValue] + '';
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        optionCamera.follow(optionSelector, LOCKON, 1);

        if (optionText != null)
        {
            switch(optionSelected)
            {
                case 0:
                    optionText.text = 'Here you can listen all the songs in the game!';
                    optionImage.loadGraphic('assets/images/ui/ost.png', false);
                    optionImage.updateHitbox();
                    FlxTween.tween(optionSelector, { x: optionsArray[0].xx + 265 }, 0.5,
                        { 
                            type:       ONESHOT,
                            ease:       FlxEase.backIn,
                            onComplete: null,
                            startDelay: 0,
                            loopDelay:  0.5
                        }
                    );
                    //optionSelector.x = optionsArray[0].xx + 265;
                case 1:
                    optionText.text = 'Here you can play all the story mode to understand the lore!';
                    optionImage.loadGraphic('assets/images/ui/story mode.png', false);
                    optionImage.updateHitbox();
                    FlxTween.tween(optionSelector, { x: optionsArray[1].xx + 265 }, 0.5,
                        { 
                            type:       ONESHOT,
                            ease:       FlxEase.backIn,
                            onComplete: null,
                            startDelay: 0,
                            loopDelay:  0.5
                        }
                    );
                    //optionSelector.x = optionsArray[1].xx + 265;
                #if ONLINE_SUPPORT
                case 2:
                    optionText.text = 'Here you can play with your friends all the songs in the game!';
                    optionImage.loadGraphic('assets/images/ui/options.png', false);
                    optionImage.updateHitbox();
                    FlxTween.tween(optionSelector, { x: optionsArray[2].xx + 265 }, 0.5,
                        { 
                            type:       ONESHOT,
                            ease:       FlxEase.backIn,
                            onComplete: null,
                            startDelay: 0,
                            loopDelay:  0.5
                        }
                    );
                #end
            }
        }

        if (FlxG.keys.anyJustPressed([ENTER, SPACE]) && canInteract == true)
        {
            select();
        }

        if (FlxG.keys.anyJustPressed([R]))
        {
            canInteract = false;
            add(resetDataSubState);
        }

        if (FlxG.keys.anyJustPressed([RIGHT, D]) && canInteract == true) 
        {
            optionSelected = (optionSelected + 1) % optionsArray.length;
        }
        else if (FlxG.keys.anyJustPressed([LEFT, A]) && canInteract == true) 
        {
            optionSelected = (optionSelected - 1 + optionsArray.length) % optionsArray.length;
        }
    }

    function select()
    {
        if (canInteract)
        {
            canInteract = false;
            var bg:FlxSprite = new FlxSprite();
            bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
            bg.antialiasing = true;
            bg.screenCenter();
            add(bg);
            var newCam:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
            newCam.bgColor = FlxColor.TRANSPARENT;
            FlxG.cameras.add(newCam);
            bg.cameras = [newCam];
            bg.alpha = 1;
            FlxTween.tween(bg, { alpha: 0 }, 1);
            music.destroy();
            FlxG.sound.play('assets/sounds/confirmMenu.ogg', 1);
            FlxG.mouse.visible = false;

            var stickers = new StickersAnimationSubState();
            add(stickers);
            stickers.generateStickers(175, 0, 1);
            stickers.cameras = [resetDataCamera];

            if (optionSelected >= 0)
            {
                switch(optionSelected)
                {
                    case 0:
                        new FlxTimer().start(2.0, (timer) -> 
                        {
                            FlxG.switchState(new OSTMenuState());
                        });
                    case 1:
                    #if ONLINE_SUPPORT
                    case 2:
                    #end
                }
            }
        }
    }
}

class EraseDataSubState extends FlxSubState
{
    var warningText:FlxText;

    var yesText:FlxText;
    var noText:FlxText;

    var optionsArray:Array<FlxText> = [];

    var optionSelected:Int = 0;

    var canInteract:Bool = true;

    public function new()
    {
        super();

        var bg:FlxSprite = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.screenCenter();
        bg.antialiasing = true;
        bg.visible = true;
        bg.alpha = 0.8;
        add(bg);

        warningText = new FlxText(0, 250, FlxG.width, 'Are you sure to erase all saved data?', 16);
        warningText.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        warningText.screenCenter(X);
        warningText.antialiasing = true;
        add(warningText);

        yesText = new FlxText(-350, 350, FlxG.width, 'YES', 16);
        yesText.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        yesText.antialiasing = true;
        add(yesText);
        optionsArray.push(yesText);

        noText = new FlxText(325, 350, FlxG.width, 'NO', 16);
        noText.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        noText.antialiasing = true;
        add(noText);
        optionsArray.push(noText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.anyJustPressed([ENTER]) && canInteract == true)
        {
            select();
        }

        if (FlxG.keys.anyJustPressed([RIGHT, D]) && canInteract == true) 
        {
            optionSelected = (optionSelected + 1) % optionsArray.length;
        }
        else if (FlxG.keys.anyJustPressed([LEFT, A]) && canInteract == true) 
        {
            optionSelected = (optionSelected - 1 + optionsArray.length) % optionsArray.length;
        }

        for (i in 0...optionsArray.length)
        {
            var text:FlxText = optionsArray[i];
            if (i == optionSelected)
            {
                text.color = FlxColor.YELLOW;
            }
            else
            {
                text.color = FlxColor.WHITE;
            }
        }
    }

    function select()
    {
        if (canInteract)
        {
            canInteract = false;
            FlxG.sound.play('assets/sounds/confirmMenu.ogg', 1);
            if (optionSelected >= 0)
            {
                switch(optionSelected)
                {
                    case 0:
                        resetData();
                    case 1:
                        FlxG.resetState();
                }
            }
        }
    }

    function resetData()
    {
        var sound:FlxSound = FlxG.sound.load('assets/sounds/confirmMenu.ogg');
        sound.play();
        new FlxTimer().start(1.0, (timer) -> 
        {
            FlxG.save.erase();
            Sys.println('Game data succesfully erased!');
            FlxG.resetGame();
        });
    }
}
