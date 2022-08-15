import Xmobar.App.Config ( defaultConfig )
import Xmobar.App.Main ( xmobar )
import Xmobar.Config.Types
    ( Align(C),
      Config(font, additionalFonts, bgColor, fgColor, alpha, position,
             lowerOnStart, hideOnStart, allDesktops, persistent, iconRoot,
             overrideRedirect, commands, sepChar, alignSep, template),
      XPosition(TopSize) )
import Xmobar.Plugins.Command ( Command(Com) )
import Xmobar.Plugins.Date ( Date(Date) )
import Xmobar.Plugins.Monitors
    ( Monitors(BatteryP, Cpu, Memory, Wireless) )
import Xmobar.Plugins.StdinReader
    ( StdinReader(UnsafeStdinReader) )
import Xmobar.Plugins.XMonadLog ( XMonadLog(UnsafeXMonadLog) )
import Xmobar.Run.Runnable ( Runnable(Run) )

config :: Config
config = defaultConfig
  { font = "xft:SauceCodePro Nerd Font Mono:weight=bold:pixelsize=14:antialias=true:hinting=true"
  , additionalFonts =
    [ "xft:Mononoki:pixelsize=14:antialias=true:hinting=true"
    , "xft:Font Awesome 6 Free Solid:pixelsize=14"
    , "xft:Font Awesome 6 Brands:pixelsize=14"
    , "xft:Fantasque Sans Mono Nerd Font:pixelsize=14"
    ]
  , bgColor          = "#282828"
  , fgColor          = "#ebdbb2"
  , alpha            = 150
  , position         = TopSize C 95 22
  , lowerOnStart     = True
  , hideOnStart      = False
  , allDesktops      = True
  , persistent       = True
  , iconRoot         = ".xmonad/xpm/"
  , overrideRedirect = False
  , commands = myCommands
  , sepChar = "%"
  , alignSep = "}{"
  , template = "   " ++ action "~/.xmonad/rofi-power-menu.sh"             1 (icon "haskell_20.xpm")
             ++ "  " ++ fc "55aa55" (action "xdotool key Super_L+Tab"     1 "%UnsafeXMonadLog%")
             ++ "  " ++ fc "b8bb26" (action "xdotool key Super_L+s"       1 "%cpu%")
             ++ "  " ++ fc "458588" (action "xdotool key Super_L+s"       1 "%memory%")
             ++ "  " ++ fc "7cff7c" (action "xdotool key Super_L+Shift+W" 1 "%wlan0wi%")
             ++ "  " ++ fc "ffff00" (action "xdotool key Super_L+B"       1 "%brighttext%%bright%")
             ++ "  } %UnsafeStdinReader% {"
             ++ "  " ++ fc "00ffff" (action "xdotool key Super_L+V" 1 $ action "pavucontrol" 3 "%voltext%%vol% %mute%")
             ++ "  " ++ fc "fb4934" (action "alacritty -e battop"   1 "%battery%")
             ++ "  " ++ fc "83a598" (action "xdotool key Super_L+d" 1 "%date%")
  }
  where
    myCommands = [ Run UnsafeXMonadLog
                 , Run $ Cpu                        ["-t", "<fn=4>\xe266</fn>  <total>%","-H","50","--high","red"]    20
                 , Run $ Memory                     ["-t", "<fn=2>\xf233</fn> <used>M <usedratio>%"]                  20
                 , Run $ Wireless         "wlan0"   ["-t", "<fn=4>\xf1eb</fn>  <essid> <quality>%"]                   100
                 , Run $ Com              "echo"    ["<fn=4>\xf5dc</fn>  "] "brighttext"                              0
                 , Run $ Com              "lux"     ["-G"] "bright"                                                   20
                 , Run UnsafeStdinReader
                 , Run $ Com              "echo"    ["<fn=2>\x1f50a</fn> "] "voltext"                                 0
                 , Run $ Com              "getvol"  [] "vol"                                                          20
                 , Run $ Com              "getmute" [] "mute"                                                         20
                 , Run $ BatteryP         ["BAT1"]  ["-t", "<fn=2>\xf242</fn> <left>% <acstatus><watts>W <timeleft>"] 100
                 , Run $ Date             "<fn=4>\xf073</fn>  %a %b %d %Y %H:%M" "date"                               50
                 ]

    wrap :: String -> String -> String -> String
    wrap a b c = a ++ c ++ b

    el :: String -> String -> [(String, String)] -> String -> String
    el e ev attr = wrap
      ("<" ++ val e ev ++ attrs attr ++ ">")
      $ "</" ++ e ++ ">"
      where
        val k [] = k
        val k v  = k  ++ "=" ++ v
        attrs [] = ""
        attrs xs = " " ++ unwords (uncurry val <$> xs)

    fc :: String -> String -> String
    fc c = el "fc" ("#" ++ c) []

    action :: String -> Integer -> String -> String
    action cmd button = el "action" ("`" ++ cmd ++ "`") [("button", show button)]

    icon :: String -> String
    icon i = "<icon=" ++ i ++ "/>"

main :: IO ()
main = xmobar config

