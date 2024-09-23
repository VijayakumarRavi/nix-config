{
  # terminal file manager
  programs.yazi = {
    enable = true;
    # Changing working directory when exiting Yazi
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
        sort_by = "natural";
        linemode = "size";
      };
      preview = {
        image_quality = 90;
        max_width = 1920;
        max_height = 1080;
      };
    };
    plugins = {
      smart-enter = ./plugins/smart-enter;
      max-preview = ./plugins/max-preview;
    };
    keymap = {
      manager.prepend_keymap = [
        {
          run = "plugin --sync smart-enter";
          on = ["<Enter>"];
          desc = "Enter the child directory, or open the file";
        }
        {
          run = "leave";
          on = ["<Backspace>"];
          desc = "Go back to the parent directory";
        }
        {
          run = "plugin --sync max-preview";
          on = ["T"];
          desc = "Toggle preview";
        }
      ];
    };
  };
}
