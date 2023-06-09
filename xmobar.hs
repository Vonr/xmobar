import Xmobar
import Data.List.Utils (replace)

main :: IO ()
main = xmobar $ defaultConfig
  { font = "FantasqueSansM Nerd Font Bold 12"
  , bgColor          = "#282828"
  , fgColor          = "#ebdbb2"
  , alpha            = 0
  , position         = TopSize C 95 22
  , lowerOnStart     = True
  , hideOnStart      = False
  , allDesktops      = True
  , persistent       = True
  , iconRoot         = rel "xpm/"
  , overrideRedirect = False
  , commands = [ Run UnsafeXMonadLog
               , Run $ Cpu                        ["-t", "<total>%","-H","50","--high","red"]     20
               , Run $ Memory                     ["-t", "<used>M <usedratio>%"]                  20
               , Run $ Wireless         "wlan0"   ["-t", "<essid> <quality>%"]                    100
               , Run $ Com              "lux"     ["-G"] "bright"                                 20
               , Run UnsafeStdinReader
               , Run $ PipeReader       "/tmp/cavabar.fifo" "cava"
               , Run $ Com              getvol    [] "vol"                                        20
               , Run $ Com              getmute   [] "mute"                                       20
               , Run $ BatteryP         ["BAT1"]  ["-t", "<left>% <acstatus><watts>W <timeleft>"] 100
               , Run $ Date             "%a %b %d %Y %H:%M" "date"                                50
               ]
  , sepChar = "%"
  , alignSep = "}{"
  , template = concatMap ("  " ++)
             [ cmd   powermenu          1 $ icon "haskell"
             , col $ key "M-Tab"        1 "%UnsafeXMonadLog%"
             , col $ key "M-s"          1 $ icon "cpu"  ++ " %cpu%"
             , col $ key "M-s"          1 $ icon "ram"  ++ " %memory%"
             , col $ key "M-S-w"        1 $ icon "wifi" ++ " %wlan0wi%"
             , col $ key "M-S-b"        1 $ icon "bright" ++ " %bright%"
             , "} %UnsafeStdinReader% {"
             , col $ key "M-S-v"        1 $ cmd "pavucontrol" 3 "%cava% %mute% %vol%"
             , col $ ter "battop"       1 $ icon "batt" ++ " %battery%"
             , col $ key "M-d"          1 $ icon "calendar" ++ " %date%"
             ]
  }
  where
    rel a = ".config/xmobar/" ++ a
    getvol = rel "scripts/getvol"
    getmute = rel "scripts/getmute"
    powermenu = "~/.config/rofi/scripts/powermenu_t1"

    wrap :: [a] -> [a] -> [a] -> [a]
    wrap bef aft mid = bef ++ mid ++ aft

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
    ter value  = cmd $ "alacritty -e "      ++ value
    key value  = cmd $ "xdotool key "       ++ replacePairs [("S", "Shift_L"), ("M", "Super_L"), ("-", "+")] value
      where
        replacePairs :: [(String, String)] -> String -> String
        replacePairs [] s = s
        replacePairs (r:rs) s = replacePairs rs $ uncurry replace r s

    icon :: String -> String
    icon i = "<icon=" ++ i ++ ".xpm/>"
