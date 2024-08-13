let
  vijay = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8O84V4KrHZGAtdgY9vTYOGdH/BPcI846sM+MbCYuLX Mainkey";

  kakashi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  zoro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  usopp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhZX0lXPldSqCLhdreywxzgXSct2XEvDsmFDrpMhk80 root@usopp";

  all = [ vijay kakashi zoro usopp ];
in
{
  "userpassword".publicKeys = all;
  "kubetoken".publicKeys = all;
  "id_ed25519".publicKeys = all;
  "id_ed25519.pub".publicKeys = all;
}
