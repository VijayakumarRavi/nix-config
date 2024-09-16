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
    };
    plugins = {
      smart-enter = ./plugins/smart-enter;
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
      ];
    };
  };
}
