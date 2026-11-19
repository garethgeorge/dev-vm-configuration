{ pkgs, lib, ... }:
let
  ghidraMcpVersion = "7.0.0";
  ghidraMcpSrc = pkgs.fetchFromGitHub {
    owner = "bethington";
    repo = "ghidra-mcp";
    rev = "v${ghidraMcpVersion}";
    hash = "sha256-0RWq1bX3fHY2DR0HQ75ylNCWQbKczvsk8m8/8eSW/Sk=";
  };

  ghidraMcpExtension = pkgs.ghidra.buildGhidraExtension {
    pname = "GhidraMCP";
    version = ghidraMcpVersion;
    src = ghidraMcpSrc;

    postPatch = ''
      # Align pom.xml's ghidra.version with nixpkgs's pkgs.ghidra version
      substituteInPlace pom.xml \
        --replace-fail "<ghidra.version>12.1.4</ghidra.version>" "<ghidra.version>${lib.getVersion pkgs.ghidra}</ghidra.version>"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/ghidra/Ghidra/Extensions
      unzip -d $out/lib/ghidra/Ghidra/Extensions build/distributions/*.zip
      for i in $out/lib/ghidra/Ghidra/Extensions/*; do
        touch "$i/.dbDirLock"
      done
      runHook postInstall
    '';
  };

  ghidraWithMcp = pkgs.ghidra.withExtensions (_: [ ghidraMcpExtension ]);

  ghidraMcpHeadlessScript = pkgs.writeShellScriptBin "ghidra-mcp-headless" ''
    set -euo pipefail
    # The guest uid follows the host uid (501 on macOS, 1000 on the Linux
    # hosts), so derive the runtime dir instead of hardcoding it.
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    GHIDRA_HOME="${pkgs.ghidra}/lib/ghidra"
    MCP_JAR="${ghidraMcpExtension}/lib/ghidra/Ghidra/Extensions/GhidraMCP/lib/GhidraMCP-${ghidraMcpVersion}.jar"

    CLASSPATH="$MCP_JAR"
    for jar in "$GHIDRA_HOME"/Ghidra/Framework/*/lib/*.jar \
               "$GHIDRA_HOME"/Ghidra/Features/*/lib/*.jar \
               "$GHIDRA_HOME"/Ghidra/Processors/*/lib/*.jar \
               "$GHIDRA_HOME"/Ghidra/Debug/*/lib/*.jar; do
      [ -f "$jar" ] && CLASSPATH="$CLASSPATH:$jar"
    done

    exec ${pkgs.openjdk21}/bin/java \
      ''${JAVA_OPTS:--Xmx2g -XX:+UseG1GC} \
      -Dghidra.home="$GHIDRA_HOME" \
      -Dapplication.name=GhidraMCP \
      -classpath "$CLASSPATH" \
      com.xebyte.headless.GhidraMCPHeadlessServer \
      "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    ghidraWithMcp
    ghidraMcpHeadlessScript
    openjdk21
    uv
  ];

  systemd.services.ghidra-mcp-headless = {
    description = "GhidraMCP Headless Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [ openjdk21 coreutils bash ];
    environment = {
      HOME = "/home/garethgeorge.linux";
      JAVA_OPTS = "-Xmx2g -XX:+UseG1GC";
      GHIDRA_MCP_ALLOW_SCRIPTS = "1";
    };
    serviceConfig = {
      Type = "simple";
      User = "garethgeorge";
      WorkingDirectory = "/home/garethgeorge.linux";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/garethgeorge.linux/.local/share/ghidra-mcp/projects";
      ExecStart = "${ghidraMcpHeadlessScript}/bin/ghidra-mcp-headless --bind 127.0.0.1 --port 8089";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.services.ghidra-mcp-bridge-init = {
    description = "Install GhidraMCP Python Bridge via uv";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [ uv python3 curl coreutils bash ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "garethgeorge";
      Environment = [
        "HOME=/home/garethgeorge.linux"
      ];
      ExecStart = pkgs.writeShellScript "ghidra-mcp-bridge-init" ''
        set -euo pipefail
        if [ -x "$HOME/.local/bin/bridge-mcp-ghidra" ]; then
          echo "bridge-mcp-ghidra already installed, skipping"
          exit 0
        fi
        ${pkgs.uv}/bin/uv tool install --force "${ghidraMcpSrc}"
      '';
    };
  };
}
