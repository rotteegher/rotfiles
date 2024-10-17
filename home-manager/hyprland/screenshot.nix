{
  config,
  isNixOS,
  lib,
  pkgs,
  ...
}: let
  screenshotDir = "$HOME/Pictures/Screenshots";
  iso8601 = "%Y-%m-%dT%H:%M:%S%z";
  # screenshot with rofi options to preselect
  hypr-screenshot = pkgs.writeShellApplication {
    name = "hypr-screenshot";
    runtimeInputs = with pkgs; [
      grimblast
      libnotify
      swappy
      rofi-wayland
    ];
    text = ''
      mesg="Screenshots can be edited with swappy by using Alt+e"
      theme_str="
      * {
          width: 1000;
      }

      window {
          height: 625;
      }

      mainbox {
          children: [listview,message];
      }
      "

      _rofi() {
          rofi -dmenu -sep '|' -disable-history true -kb-custom-1 "Alt-e" -mesg "$mesg" -cycle true -lines 4 -theme-str "$theme_str" "$@"
      }

      choice=$(echo "Selection|Window|Monitor|All" | _rofi)
      # exit code 10 is alt-e
      exit_code=$?

      # first arg is the grimblast command
      screenshot() {
          img="${screenshotDir}/$(date +${iso8601}).png"
          if [ "$exit_code" -eq 10 ]; then
              grimblast save "$1" - | swappy -f - -o "$img"
              notify-send "Screenshot saved to $img" -i "$img"
          else
              grimblast --notify copysave "$1" "$img"
          fi
      }

      # small sleep delay is required so rofi menu doesnt appear in the screenshot
      case "$choice" in
      "All")
          delay=$(echo "0|3|5" | _rofi "$@")
          sleep 0.5
          sleep "$delay"
          screenshot screen
          ;;
      "Monitor")
          delay=$(echo "0|3|5" | _rofi "$@")
          sleep 0.5
          sleep "$delay"
          screenshot output
          ;;
      "Selection")
          screenshot area
          ;;
      "Window")
          delay=$(echo "0|3|5" | _rofi "$@")
          sleep 0.5
          sleep "$delay"
          screenshot active
          ;;
      esac
    '';
  };
  hypr-ocr = pkgs.writeShellApplication {
    name = "hypr-ocr";
    runtimeInputs = with pkgs; [
      tesseract
      grimblast
      wl-clipboard
      libnotify
      rofi-wayland
    ];
    text = ''
      img="$HOME/Pictures/Screenshots/ocr.png"

      # Define language selection and display it with rofi
      lang_option=$(echo -e "eng\njpn" | rofi -dmenu -p "Select OCR Language" -i -lines 2)
    
      # Default to "eng" if no language was selected
      if [ -z "$lang_option" ]; then
        lang_option="eng"
      fi

      # Define PSM options and display them with rofi for selection
      psm_option=$(echo -e "10: single character.\
      \n3: Full automatic p.segm, but no OSD. (Default)\
      \0: Orientation and script detection (OSD) only.\
      \n1: Automatic p.segm. with OSD.\
      \n2: Automatic p.segm., but no OSD, or OCR. (not implemented)\
      \n4: single column variable sizes.\
      \n5: single block of vertically aligned text.\
      \n6: single uniform block of text.\
      \n7: single text line.\
      \n8: single word.\
      \n9: single word in a circle.\
      \n11: Find amap text no order.\
      \n12: Sparse text with OSD.\
      \n13: Raw line. Treat the image as a single text line, bypassing hacks that are Tesseract-specific." | \
      rofi -dmenu -p "Select PSM mode" -i -lines 14)

      # Extract the PSM number from the selection
      psm_number=$(echo "$psm_option" | cut -d ':' -f 1)

      # If no option selected, use the default mode (3)
      if [ -z "$psm_number" ]; then
        psm_number=3
      fi

      # Take screenshot and perform OCR with selected language and PSM mode
      grimblast save area "$img"
      ${pkgs.tesseract}/bin/tesseract -l "$lang_option" --psm "$psm_number" "$img" - | wl-copy
      rm "$img"
      notify-send "$(wl-paste)"
    '';
  };
in {
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    home.packages =
      [
        hypr-ocr
        hypr-screenshot
      ]
      ++ (lib.optionals isNixOS (with pkgs; [
        grimblast
        swappy
      ]));

    # swappy conf
    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir=${screenshotDir}
      save_filename_format=${iso8601}.png
      show_panel=false
      line_size=5
      text_size=20
      text_font=sans-serif
      paint_mode=brush
      early_exit=false
      fill_shape=false
    '';

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mod, backslash, exec, grimblast --notify --freeze copy area"
        "$mod_SHIFT, backslash, exec, hypr-screenshot"
        "$mod_CTRL, backslash, exec, hypr-ocr"
      ];
    };
  };
}
