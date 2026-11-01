# modules/nixos/reverse-engineering.nix
# ── Reverse engineering (opt-in via myconfig.reverseEngineering.enable) ──────
#
# System-level rather than home-level because three things here need privileges
# the HM profile cannot grant: programs.wireshark installs a setcap'd dumpcap
# and creates the group that may use it, kernel.yama.ptrace_scope is a sysctl,
# and bpftrace needs the kernel headers/BTF wired up by the NixOS module set.
# The rest rides along so the whole toolchain lives in one file.
#
# Everything is off by default. A host opts in with
#
#   myconfig.reverseEngineering.enable = true;
#
# which turns on the core kit plus every sub-group; individual groups can then
# be switched back off to trim the closure, e.g.
#
#   myconfig.reverseEngineering.fuzzing.enable = false;
#
{ config, lib, pkgs, ... }:

let
  cfg = config.myconfig.reverseEngineering;

  # Sub-groups default to on, so a single `enable = true` yields the full kit
  # and hosts subtract rather than add. lib.mkEnableOption cannot express this
  # — it hardcodes default = false.
  mkGroup = description: lib.mkOption {
    inherit description;
    type = lib.types.bool;
    default = true;
    example = false;
  };

  # users/ferro/default.nix already puts a bare `python3` in home.packages, and
  # the HM profile precedes /run/current-system/sw on PATH — a plain
  # python3.withPackages here would be permanently shadowed. So the analysis
  # env gets its own command name instead of fighting over `python3`.
  #
  # Exec'ing the env's bin/python3 by store path (rather than symlinking the
  # name) keeps sys.prefix resolution anchored to the env, so site-packages
  # always resolve regardless of how re-python itself was invoked.
  #
  # Built from unstable: angr 9.2.193 in 26.05 is missing setuptools-rust in
  # its build inputs and cannot be built at all. Pulling the whole env from one
  # channel rather than mixing — a buildEnv spanning two python derivations
  # would collide on site-packages.
  rePython = pkgs.writeShellScriptBin "re-python" ''
    exec ${pkgs.unstable.python3.withPackages (ps: with ps; [
      pwntools
      angr
      capstone
      unicorn
      keystone-engine
      ropper
      r2pipe
      lief
      pyelftools
      z3-solver
      frida-python
    ])}/bin/python3 "$@"
  '';
in
{
  options.myconfig.reverseEngineering = {
    enable = lib.mkEnableOption "reverse-engineering and binary-analysis tooling";

    binaryninja.enable = mkGroup "Binary Ninja Free (unfree, built locally — not in the binary cache)";
    scripting.enable = mkGroup "Python exploitation/analysis env (pwntools, angr, frida) exposed as re-python";
    managedCode.enable = mkGroup "Java, Android, .NET and Python bytecode decompilers";
    network.enable = mkGroup "Wireshark, nmap, tcpdump and CAN bus tooling";
    forensics.enable = mkGroup "Disk/memory forensics, steganography and hash tooling";
    fuzzing.enable = mkGroup "Fuzzers, tracers and dynamic-analysis tooling";
    ptraceAnyProcess.enable = mkGroup "Relax kernel.yama.ptrace_scope to 0 so debuggers can attach to non-descendants";
  };

  config = lib.mkIf cfg.enable {
    programs.wireshark = lib.mkIf cfg.network.enable {
      enable = true;
      package = pkgs.wireshark; # Qt GUI; wireshark-cli would be tshark only
    };

    # Yama defaults to 1, which blocks `gdb -p <pid>` and frida attach on any
    # process that is not a child of the tracer. Nothing in
    # hosts/common/security.nix touches this key, so a plain assignment merges
    # with the hardening sysctls there — no mkForce required. This is a
    # deliberate, per-host weakening of a hardening default.
    boot.kernel.sysctl = lib.mkIf cfg.ptraceAnyProcess.enable {
      "kernel.yama.ptrace_scope" = 0;
    };

    environment.systemPackages = with pkgs; [
      # ── Disassemblers ─────────────────────────────────────────────────
      radare2
      rizin
      cutter # Qt GUI on top of rizin

      # ── Debuggers ─────────────────────────────────────────────────────
      gdb
      gef # ships its own `gef` launcher; plain gdb stays untouched
      lldb
      edb
      seer # Qt frontend for gdb

      # ── Binary inspection ─────────────────────────────────────────────
      #
      # binutils-unwrapped, not binutils: the wrapped derivation puts an ld
      # wrapper on the system PATH, which is a known way to confuse builds
      # outside the nix sandbox. The unwrapped one still gives objdump,
      # readelf, nm, strings, c++filt and friends.
      binutils-unwrapped
      binwalk
      elfutils
      patchelf
      checksec
      upx
      detect-it-easy
      flare-floss # strings from obfuscated binaries
      bingrep
      binsider # TUI ELF explorer
      fq # jq for binary formats
      nasm

      # ── Hex editors & binary diff ─────────────────────────────────────
      imhex
      hexyl
      rehex
      ht # hex viewer/editor with a built-in disassembler
      vbindiff
    ]
    ++ lib.optional cfg.binaryninja.enable binaryninja-free
    ++ lib.optionals cfg.scripting.enable [
      rePython
      frida-tools
      ropgadget
    ]
    ++ lib.optionals cfg.managedCode.enable [
      # Java / Android
      jadx
      apktool
      dex2jar
      procyon
      bytecode-viewer
      # .NET
      ilspycmd
      avalonia-ilspy
      # Python bytecode
      #
      # pycdc (decompyle++), not uncompyle6: the latter's xdis dependency
      # fails its own test suite on every interpreter in this nixpkgs rev,
      # and it never supported bytecode past CPython 3.8 anyway.
      pycdc
    ]
    ++ lib.optionals cfg.network.enable [
      nmap
      tcpdump
      termshark # TUI over tshark
      can-utils
    ]
    ++ lib.optionals cfg.forensics.enable [
      # Disk & memory
      sleuthkit
      volatility3
      foremost
      testdisk # also provides photorec
      exiftool
      # Steganography
      steghide
      stegseek
      zsteg
      # Hashes & classical crypto
      john # CPU-only; hashcat is deliberately absent, it needs an OpenCL ICD
      hashid
      xortool
      ssdeep
    ]
    ++ lib.optionals cfg.fuzzing.enable [
      # Fuzzers
      honggfuzz
      radamsa
      cargo-fuzz
      # Dynamic analysis
      valgrind
      rr
      strace
      ltrace
      bpftrace
      # Running foreign binaries
      qemu-user
      wineWow64Packages.stable
      winetricks
    ];
  };
}
