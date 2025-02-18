{
  variables,
  config,
  pkgs,
  ...
}: {
  launchd.agents.dnsproxy.serviceConfig = {
    Label = "dnsproxy";
    ProcessType = "Background";
    RunAtLoad = true;
    KeepAlive = true;
    UserName = "${variables.username}";
    ProgramArguments = ["${pkgs.dnsproxy}/bin/dnsproxy" "--config-path=/etc/dnsproxy.yaml"];
    StandardOutPath = "/Users/${variables.username}/Library/Logs/dnsproxy/dnsproxy_output.log";
    StandardErrorPath = "/Users/${variables.username}/Library/Logs/dnsproxy/dnsproxy_output.log";
  };
  launchd.agents.aria2c.serviceConfig = {
    Label = "aria2c";
    ProcessType = "Background";
    RunAtLoad = true;
    KeepAlive = true;
    UserName = "${variables.username}";
    ProgramArguments = [
      "${pkgs.aria2}/bin/aria2c"
      "--continue"
      "--enable-rpc"
      "--rpc-listen-all"
      "--rpc-secret=vijay"
      "--log-level=warn"
      "--max-connection-per-server=16"
      "--dir=/Users/${variables.username}/Downloads/aria"
    ];
    StandardOutPath = "/Users/${variables.username}/Library/Logs/aria2c/aria2c_output.log";
    StandardErrorPath = "/Users/${variables.username}/Library/Logs/aria2c/aria2c_output.log";
  };
}
