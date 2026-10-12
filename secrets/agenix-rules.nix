let
  yayad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgmsIaUpS5pT44ZztnEWYIb4+8A6lBYfWnr6Ow32STj";

  beak = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgnN8OjT2vrchLCelmfHTqDyoo2EWmTdyOlQAOG0U1k root@nixos";

  feathers = "age1tjaq3xrpgvl7utvjvkakqjx3av4x4vqmfjdjqge4k6hqwy49q9qqdsu7y6";

in
{
  "k3s-token.age".publicKeys = [ yayad beak feathers ];
  "immich-db-pass.age".publicKeys = [ yayad beak feathers ];
}
