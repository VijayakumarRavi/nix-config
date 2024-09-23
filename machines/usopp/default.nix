{
  imports = [
    ../kubenodes
  ];
  networking.interfaces = {
    eno1 = {
      ipv4.addresses = [
        {
          address = "10.0.1.102";
          prefixLength = 16;
        }
      ];
    };
  };
}
