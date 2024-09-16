{
  lib,
  config,
  ...
}: {
  home.activation.removeExistingHtoprc = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -fv ${config.home.homeDirectory}/.config/htop/htoprc
  '';
  programs.htop.enable = true;
  home.file.".config/htop/htoprc".text = ''
    # Beware! This file is rewritten by htop when settings are changed in the interface.
    # The parser is also very primitive, and not human-friendly.
    htop_version=3.3.0
    config_reader_min_version=3
    fields=0 48 17 18 38 39 2 46 47 49 1
    hide_kernel_threads=1
    hide_userland_threads=0
    hide_running_in_container=0
    shadow_other_users=0
    show_thread_names=0
    show_program_path=0
    highlight_base_name=0
    highlight_deleted_exe=1
    shadow_distribution_path_prefix=0
    highlight_megabytes=1
    highlight_threads=1
    highlight_changes=0
    highlight_changes_delay_secs=5
    find_comm_in_cmdline=1
    strip_exe_from_cmdline=1
    show_merged_command=0
    header_margin=1
    screen_tabs=0
    detailed_cpu_time=0
    cpu_count_from_one=0
    show_cpu_usage=1
    show_cpu_frequency=0
    update_process_names=0
    account_guest_in_cpu_meter=0
    color_scheme=0
    enable_mouse=1
    delay=15
    hide_function_bar=0
    header_layout=two_50_50
    column_meters_0=AllCPUs2 Blank Memory Swap
    column_meter_modes_0=1 2 1 1
    column_meters_1=Hostname Uptime Battery DateTime Blank DiskIO NetworkIO
    column_meter_modes_1=2 2 2 2 2 2 2
    tree_view=0
    sort_key=46
    tree_sort_key=0
    sort_direction=-1
    tree_sort_direction=1
    tree_view_always_by_pid=0
    all_branches_collapsed=0
    screen:Main=PID USER PRIORITY NICE M_VIRT M_RESIDENT STATE PERCENT_CPU PERCENT_MEM TIME Command
    .sort_key=PERCENT_CPU
    .tree_sort_key=PID
    .tree_view_always_by_pid=0
    .tree_view=0
    .sort_direction=-1
    .tree_sort_direction=1
    .all_branches_collapsed=0
  '';
}
