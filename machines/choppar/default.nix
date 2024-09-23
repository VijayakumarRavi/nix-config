{
  imports = [
    ../kubenodes
  ];
  networking.interfaces = {
    eno1 = {
      ipv4.addresses = [
        {
          address = "10.0.1.103";
          prefixLength = 16;
        }
      ];
    };
  };
}
