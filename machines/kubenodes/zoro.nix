{
  networking.interfaces = {
    eno1 = {
      ipv4.addresses = [
        {
          address = "10.0.1.101";
          prefixLength = 16;
        }
      ];
    };
  };
}
