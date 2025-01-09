{
  config,
  pkgs,
  ...
}: {
  launchd.agents.dnsproxy.serviceConfig = {
    Label = "dnsproxy";
    ProcessType = "Background";
    RunAtLoad = true;
    KeepAlive = true;
    ProgramArguments = ["${pkgs.dnsproxy}/bin/dnsproxy" "--config-path=${config.sops.secrets."kakashi.yaml".path}"];
    StandardOutPath = "/Users/vijay/Library/Logs/dnsproxy/dnsproxy_output.log";
    StandardErrorPath = "/Users/vijay/Library/Logs/dnsproxy/dnsproxy_output.log";
  };
  launchd.agents.aria2c.serviceConfig = {
    Label = "aria2c";
    ProcessType = "Background";
    RunAtLoad = true;
    KeepAlive = true;
    ProgramArguments = ["${pkgs.aria2}/bin/aria2c" "--enable-rpc" "--rpc-listen-all" "--rpc-secret=vijay"];
    StandardOutPath = "/Users/vijay/Library/Logs/aria2c/aria2c_output.log";
    StandardErrorPath = "/Users/vijay/Library/Logs/aria2c/aria2c_output.log";
  };
}
