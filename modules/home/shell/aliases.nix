_:

{
  programs.zsh.shellAliases = {
    # ── NixOS ─────────────────────────────────────────────────────────
    nrs = "sudo nixos-rebuild switch --flake ~/.config/nixos";
    nrb = "sudo nixos-rebuild boot --flake ~/.config/nixos";
    nrt = "sudo nixos-rebuild test --flake ~/.config/nixos";
    nfu = "nix flake update";
    ngc = "nix-collect-garbage -d && sudo nix-collect-garbage -d";

    # ── Modern CLI replacements ────────────────────────────────────────
    ls = "eza --icons=always --group-directories-first";
    ll = "eza -lah --icons=always --group-directories-first --git";
    lt = "eza --tree --icons=always -L 2";
    la = "eza -a --icons=always --group-directories-first";
    cat = "bat --style=plain";
    grep = "rg";
    find = "fd";
    cd = "z";
    du = "dust";
    df = "duf";
    top = "btm";

    # ── Git shortcuts ──────────────────────────────────────────────────
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gd = "git diff";
    gco = "git checkout";
    gb = "git branch";
    glog = "git log --oneline --graph --decorate";

    # ── Kubernetes ────────────────────────────────────────────────────
    k = "kubectl";
    kctx = "kubectx";
    kns = "kubens";
    kgp = "kubectl get pods";
    kgs = "kubectl get services";
    kgd = "kubectl get deployments";
    kgn = "kubectl get nodes";
    kdp = "kubectl describe pod";
    kds = "kubectl describe service";
    kdd = "kubectl describe deployment";
    klf = "kubectl logs -f";
    kex = "kubectl exec -it";
    kaf = "kubectl apply -f";
    kdf = "kubectl delete -f";

    # ── Docker ────────────────────────────────────────────────────────
    dk = "docker";
    dkps = "docker ps";
    dkc = "docker compose";
    dkcu = "docker compose up -d";
    dkcd = "docker compose down";
    dkcl = "docker compose logs -f";
    lzd = "lazydocker";

    # ── Safety nets ───────────────────────────────────────────────────
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    mkdir = "mkdir -p";
    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -iv";
  };
}
