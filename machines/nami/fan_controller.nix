{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.pi5_fan_controller = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Pi5 Fan Controller service.";
    };
  };

  config = lib.mkIf config.services.pi5_fan_controller.enable {
    # Write the Python script to a specific location
    environment.etc."pi5_fan_controller.py".text = ''
      from sys import exit as sysexit
      from os import _exit as osexit
      from subprocess import run as srun, PIPE
      from time import sleep
      from datetime import timedelta as td, datetime as dt
      from enum import Enum

      ## Use step values to activate desired FAN value
      STEP1 = 45
      STEP2 = 50
      STEP3 = 55
      DELTA_TEMP = 5

      ## Change these values if you want a more/less responsive fan behavior
      SLEEP_TIMER = 5
      TICKS = 3
      TICK_INTERVAL = 2

      ## These should not be changed
      DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
      fanControlFile = '/sys/class/thermal/cooling_device0/cur_state'
      command = f"${pkgs.coreutils}/bin/tee -a {fanControlFile} > /dev/null"

      class FanState(Enum):
          OFF = 0
          LOW = 2
          MID = 3
          HIGH = 4

      def main(debug=False):
          print("Running FAN control for RPI5 Nixos")
          t0 = dt.now()
          _fs = FanState

          oldSpeed = _fs.OFF
          ticks = 0

          speed = _fs.MID
          lastTemp = 0

          while True:
              sleep(SLEEP_TIMER) # force sleep, just to reduce polling calls
              t1 = dt.now()
              if(t1 + td(minutes=TICKS) > t0):
                  t0 = t1

                  tempOut = getOutput('${pkgs.coreutils}/bin/cat /sys/class/thermal/thermal_zone0/temp')
                  try:
                      cels = int(tempOut[:2])  # Adjusted to match the expected temp format
                  except (IndexError, ValueError) as e:
                      cels = STEP2 + 2 # force avg temp, in case of parsing error

                  if STEP1 < cels < STEP2:
                      speed = _fs.LOW
                  elif STEP2 < cels < STEP3:
                      speed = _fs.MID
                  elif cels >= STEP3:
                      speed = _fs.HIGH

                  deltaTempNeg = lastTemp - DELTA_TEMP
                  deltaTempPos = lastTemp + DELTA_TEMP

                  if oldSpeed != speed and not(deltaTempNeg <= cels <= deltaTempPos):
                      if debug:
                          print(f'oldSpeed: {oldSpeed} | newSpeed: {speed}')
                          print(f'{deltaTempNeg}ºC <= {cels}ºC <= {deltaTempPos}ºC')

                      print(f'{"#"*30}\n' +
                          f'Updating fan speed!\t{t0.strftime(DATETIME_FORMAT)}\n' +
                          f'CPU TEMP: {cels}ºC\n' +
                          f'FAN speed will be set to: {speed}\n' +
                          f'{"#"*30}\n')

                      _speed = -1
                      try:
                          _speed = speed.value
                      except AttributeError:
                          _speed = speed
                      _command = f'echo {_speed} | {command}'
                      callShell(_command)

                      if debug:
                          checkVal = getOutput('${pkgs.coreutils}/bin/cat ' + fanControlFile)
                          print(f'Confirm FAN set to speed: {checkVal}')

                      # Updating values for comparison
                      oldSpeed = speed
                      lastTemp = cels
                      ticks = 0

                  # Log minor details
                  ticks += 1
                  if(ticks > TICKS * TICK_INTERVAL):
                      ticks = 0
                      print(f'Current Temp is: {cels}ºC\t{t0.strftime(DATETIME_FORMAT)}')


      def callShell(cmd, shell=True, debug=False):
          if debug:
              print(f'Calling: [{cmd}]')
          return srun(f'{cmd}', stdout=PIPE, shell=shell)


      def getOutput(cmd, shell=True):
          stdout = callShell(cmd, shell=shell).stdout

          try:
              stdout = stdout.decode('utf-8')
          except:
              pass

          return stdout


      ## RUN SCRIPT
      if __name__ == '__main__':
          try:
              main(True)
          except KeyboardInterrupt:
              print('Interrupted')
              try:
                  sysexit(130)
              except SystemExit:
                  osexit(130)
    '';
    # Create a systemd service for the script
    systemd.services.pi5_fan_controller = {
      description = "Pi5 Fan Controller Service";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 /etc/pi5_fan_controller.py";
        Restart = "always";
        RestartSec = "5s";
        # Make sure the service has the necessary permissions
        AmbientCapabilities = "CAP_SYS_ADMIN";
      };
    };
  };
}
