{
  imports = [
    ../kubenodes
  ];
  networking.interfaces = {
    eno2 = {
      ipv4.addresses = [
        {
          address = "10.0.1.101";
          prefixLength = 16;
        }
      ];
    };
  };
}
