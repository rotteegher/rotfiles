{ lib, pkgs, ... }: {
  # saner api for iterating through workspaces in a flat list
  # takes a function that accepts the following attrset {workspace, key, monitor}
  mapWorkspaces = workspaceFn: displays:
    lib.concatMap ({ display_name_output, workspaces, workspace_names ? [ ], ... }:
      let
        namedWorkspaces = lib.zipListsWith (ws: name: {
          workspace = toString ws;
          key = toString (lib.mod ws 10);
          monitor = display_name_output;
          workspace_name = name;
        }) workspaces workspace_names;

        paddedWorkspaces = namedWorkspaces
          ++ lib.drop (builtins.length workspace_names) (lib.map (ws: {
            workspace = toString ws;
            key = toString (lib.mod ws 10);
            monitor = display_name_output;
            workspace_name = toString ws;
          }) (lib.drop (builtins.length workspace_names) workspaces));
      in lib.map workspaceFn paddedWorkspaces) displays;

  # produces ini format strings, takes a single argument of the object
  toQuotedINI = lib.generators.toINI {
    mkKeyValue = lib.flip lib.generators.mkKeyValueDefault "=" {
      mkValueString = v:
        if lib.isString v then
          ''"${v}"''
        else
          lib.generators.mkValueStringDefault { } v;
    };
  };

  # uses the direnv of a directory
  useDirenv = dir: text:
    let direnv = lib.getExe pkgs.direnv;
    in ''
      cd ${dir}
      # activate direnv, it's always bash for a script
      ${direnv} allow && eval "$(${direnv} export bash)"
      ${text}
      cd - > /dev/null
    '';
}
