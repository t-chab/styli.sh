{
  description = "Wallpaper switching made easy";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        script-name = "styli.sh";
        script-buildInputs = with pkgs; [ feh ];
        script-src = builtins.readFile ./styli.sh;
        script = (pkgs.writeScriptBin script-name script-src).overrideAttrs
          (old: {
            buildCommand = ''
              ${old.buildCommand}
               patchShebangs $out'';
          });
        packageName = "styli.sh";
      in rec {
        defaultPackage = self.packages.${system}.${packageName};
        packages.${packageName} = pkgs.symlinkJoin {
          name = script-name;
          paths = [ script ] ++ script-buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild =
            "wrapProgram $out/bin/${my-name} --prefix PATH : $out/bin";
        };
      });
}
