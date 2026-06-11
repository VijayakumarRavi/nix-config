{
  lib,
  pkgs,
  config,
  system,
  ...
}: let
  config-path =
    if system == "aarch64-darwin"
    then "${config.home.homeDirectory}/Library/Application Support/k9s"
    else "${config.home.homeDirectory}/.config/k9s";
in {
  programs.k9s.enable = true;

  home.activation.removeExistingK9sConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] "echo ${config-path} && rm -rvf ${config-path}/";

  home.file = {
    "${config-path}/config.yaml".text =
      /*
      yaml
      */
      ''
        k9s:
          # Enable periodic refresh of resource browser windows. Default false
          liveViewAutoRefresh: true
          # Represents ui poll intervals. Default 2secs
          refreshRate: 1
          # Toggles whether k9s should exit when CTRL-C is pressed. When set to true, you will need to exist k9s via the :quit command. Default is false.
          noExitOnCtrlC: true
          ui:
            # Set to true to hide K9s logo. Default false
            logoless: true
            # Set to true to hide K9s crumbs. Default false
            crumbsless: false
            # Toggles reactive UI. This option provide for watching on disk artifacts changes and update the UI live  Defaults to false.
            reactive: true
            # colorscheme
            # skin: rose-pine
            skin: transparent
          # Logs configuration
          logger:
            # Defines the number of lines to return. Default 100
            tail: 1000
            # Defines the total number of log lines to allow in the view. Default 1000
            buffer: 10000
            # Go full screen while displaying logs. Default false
            fullScreen: true
          # Global memory/cpu thresholds. When set will alert when thresholds are met.
          thresholds:
            cpu:
              critical: 90
              warn: 70
            memory:
              critical: 90
              warn: 70
      '';
    "${config-path}/skins/transparent.yaml".text =
      /*
      yaml
      */
      ''
        k9s:
          body:
            bgColor: default
          prompt:
            bgColor: default
          info:
            sectionColor: default
          dialog:
            bgColor: default
            labelFgColor: default
            fieldFgColor: default
          frame:
            crumbs:
              bgColor: default
            title:
              bgColor: default
              counterColor: default
            menu:
              fgColor: default
          views:
            charts:
              bgColor: default
            table:
              bgColor: default
              header:
                fgColor: default
                bgColor: default
            xray:
              bgColor: default
            logs:
              bgColor: default
              indicator:
                bgColor: default
                toggleOnColor: default
                toggleOffColor: default
            yaml:
              colonColor: default
              valueColor: default
      '';
    "${config-path}/clusters/home-cluster/home/config.yaml".text =
      /*
      yaml
      */
      ''
        k9s:
          cluster: home-cluster
          namespace:
            active: all
            lockFavorites: true
            favorites:
            - all
            - flux-system
            - media
            - monitoring
            - utils
          view:
            active: pu
      '';
    "${config-path}/plugins.yaml".text =
      /*
      yaml
      */
      ''
        plugins:
          helm-values:
            shortCut: Shift-V
            confirm: false
            description: "Get Helm values"
            scopes:
              - helm
            command: sh
            background: false
            args:
              - -c
              - helm get values $COL-NAME -n $NAMESPACE --kube-context $CONTEXT | nvim -R
          watch-events:
            shortCut: Shift-E
            confirm: false
            description: "Watch events"
            scopes:
              - all
            command: sh
            background: false
            args:
              - -c
              - "watch -n 5 kubectl get events --context $CONTEXT --namespace $NAMESPACE --field-selector involvedObject.name=$NAME"
          stern:
            shortCut: Ctrl-L
            confirm: false
            description: "Logs <Stern>"
            scopes:
              - pods
            command: ${pkgs.stern}/bin/stern
            background: false
            args:
              - --tail
              - 50
              - $FILTER
              - -n
              - $NAMESPACE
              - --context
              - $CONTEXT
      '';
    "${config-path}/views.yaml".text =
      /*
      yaml
      */
      ''
        views:
          # Alters the pod view column layout. Uses GVR as key
          v1/pods:
            # Overrides default sort column
            sortColumn: AGE:asc
            columns:
              - AGE
              - NAMESPACE
              - NAME
              - IP
              - NODE
              - STATUS
              - READY

          # Alters the service view column layout
          v1/services:
            columns:
              - AGE
              - NAMESPACE
              - NAME
              - TYPE
              - CLUSTER-IP
      '';
    "${config-path}/hotkeys.yaml".text =
      /*
      yaml
      */
      ''
        hotKeys:
          # Hitting Shift-0 navigates to your pod view
          pods:
            shortCut:    Shift-1
            description: Viewing pods
            command:     pods

          # Hitting Shift-1 navigates to your deployments
          deployments:
            shortCut:    Shift-2
            description: View deployments
            command:     dp

          # Hitting Shift-3 navigates to your services
          Services:
            shortCut:    Shift-3
            description: View Services
            command:     svc
      '';
  };
}
