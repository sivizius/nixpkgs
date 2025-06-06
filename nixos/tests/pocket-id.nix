import ./make-test-python.nix (
  { lib, ... }:

  {
    name = "pocket-id";
    meta.maintainers = with lib.maintainers; [
      gepbird
      ymstnt
    ];

    nodes = {
      machine =
        { ... }:
        {
          services.pocket-id = {
            enable = true;
            settings = {
              PORT = 10001;
              INTERNAL_BACKEND_URL = "http://localhost:10002";
              BACKEND_PORT = 10002;
            };
          };
        };
    };

    testScript =
      { nodes, ... }:
      let
        inherit (nodes.machine.services.pocket-id) settings;
        inherit (builtins) toString;
      in
      ''
        machine.wait_for_unit("pocket-id-backend.service")
        machine.wait_for_open_port(${toString settings.BACKEND_PORT})
        machine.wait_for_unit("pocket-id-frontend.service")
        machine.wait_for_open_port(${toString settings.PORT})

        backend_status = machine.succeed("curl -L -o /tmp/backend-output -w '%{http_code}' http://localhost:${toString settings.BACKEND_PORT}/api/users/me")
        assert backend_status == "401"
        machine.succeed("grep 'You are not signed in' /tmp/backend-output")

        frontend_status = machine.succeed("curl -L -o /tmp/frontend-output -w '%{http_code}' http://localhost:${toString settings.PORT}")
        assert frontend_status == "200"
        machine.succeed("grep 'Sign in to Pocket ID' /tmp/frontend-output")
      '';
  }
)
