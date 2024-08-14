let
  vijay = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8O84V4KrHZGAtdgY9vTYOGdH/BPcI846sM+MbCYuLX Mainkey";

  kakashi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  zoro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR0qLUZKqwEcUVgsylu53YjX3k24ZDMAhZC6R1O3jxA root@zoro";
  usopp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEHsRr3iq20g3CmsaLYmohTX6TweobdilvDtYrzeN20 root@usopp";

  all = [ vijay kakashi zoro usopp ];
in
{
  "userpassword".publicKeys = all;
  "kubetoken".publicKeys = all;
  "id_ed25519".publicKeys = all;
  "id_ed25519.pub".publicKeys = all;
}
