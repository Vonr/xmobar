import Xmobar

main :: IO ()
main = xmobar $ defaultConfig
  { font = "xft:SauceCodePro Nerd Font Mono:weight=bold:pixelsize=14:antialias=true:hinting=true"
  , additionalFonts =
    [ "xft:Mononoki:pixelsize=14:antialias=true:hinting=true"
    , "xft:Font Awesome 6 Free Solid:pixelsize=14"
    , "xft:Font Awesome 6 Brands:pixelsize=14"
    , "xft:Fantasque Sans Mono Nerd Font:pixelsize=14"
    ]
  , bgColor          = "#282828"
  , fgColor          = "#ebdbb2"
  , alpha            = 0
  , position         = TopSize C 95 22
  , lowerOnStart     = True
  , hideOnStart      = False
  , allDesktops      = True
  , persistent       = True
  , iconRoot         = ".xmonad/xpm/"
  , overrideRedirect = False
  , commands = [ Run UnsafeXMonadLog
               , Run $ Cpu                        ["-t", "<total>%","-H","50","--high","red"]    20
               , Run $ Memory                     ["-t", "<used>M <usedratio>%"]                  20
               , Run $ Wireless         "wlan0"   ["-t", "<essid> <quality>%"]                   100
               , Run $ Com              "lux"     ["-G"] "bright"                                                   20
               , Run UnsafeStdinReader
               , Run $ Com              "getvol"  [] "vol"                                                          20
               , Run $ Com              "getmute" [] "mute"                                                         20
               , Run $ BatteryP         ["BAT1"]  ["-t", "<left>% <acstatus><watts>W <timeleft>"] 100
               , Run $ Date             "%a %b %d %Y %H:%M" "date"                               50
               ]
  , sepChar = "%"
  , alignSep = "}{"
  , template = concatMap ("  " ++)
             [ scr "rofi-power-menu.sh"    1 (icon "haskell_20.xpm")
             , col $ key "Super_L+Tab"     1 "%UnsafeXMonadLog%"
             , col $ key "Super_L+s"       1 $ nf "\xe266" ++ "  %cpu%"
             , col $ key "Super_L+s"       1 $ nf "\xf233" ++ "  %memory%"
             , col $ key "Super_L+Shift+W" 1 $ nf "\xf1eb" ++ "  %wlan0wi%"
             , col $ key "Super_L+B"       1 $ nf "\xf5dc" ++ " %bright%"
             , "} %UnsafeStdinReader% {"
             , col $ key "Super_L+V"       1 $ cmd "pavucontrol" 3 $ nf "\xfa7d" ++ "  %vol% %mute%"
             , col $ ter "battop"          1 $ nf "\xf242" ++ "  %battery%"
             , col $ key "Super_L+d"       1 $ nf "\xf073" ++ "  %date%"
             ]
  }
  where
    wrap :: [a] -> [a] -> [a] -> [a]
    wrap bef aft mid = bef ++ mid ++ aft

    nf :: String -> String
    nf a = "<fn=4>" ++ a ++ "</fn>"

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

    col = fc "34ac90"
    cmd :: String -> Integer -> String -> String
    cmd value button = el "action" ("`" ++ value ++ "`") [("button", show button)]
    key value = cmd ("xdotool key " ++ value)
    ter value = cmd ("alacritty -e " ++ value)
    scr script = cmd $ "~/.xmonad/scripts/" ++ script

    icon :: String -> String
    icon i = "<icon=" ++ i ++ "/>"

