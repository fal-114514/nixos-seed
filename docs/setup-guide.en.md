# NixOS Setup Guide (English)

This guide provides detailed instructions on how to set up NixOS using this starter configuration.

## 1. Preparation

Clone this repository to your local machine.

```bash
git clone https://github.com/fal-114514/nixos-seed.git nixos-config
cd nixos-config
```

## 2. Understanding the Directory Structure

The configuration is structured to support multiple hosts (machines).

- `hosts/`: Host-specific configurations (personal, template, etc.)
- `modules/`: Shared functional modules (Desktop Environments, etc.)
- `flake.nix`: The main entry point where hosts are defined.

## 3. Creating and Configuring a Host

It is recommended to copy `hosts/template` to create a new host configuration.

### Step A: Generate Hardware Configuration

Run the following on the target machine:

```bash
nixos-generate-config --show-hardware-config > hosts/<your-host-name>/hardware-configuration.nix
```

### Step B: Configure Variables

Edit `hosts/<your-host-name>/variables.nix`.

- `user.name`: Your username
- `system.hostname`: Hostname (must match the definition in `flake.nix`)
- `desktop.enableGnome`, `enableNiri`, etc.: Select your desktop environment
- `inputMethod.type`, `fcitx5Layout`: Input method type and physical keyboard layout (e.g., `"fcitx5"`, `"us"`)

### Step C: Host-Specific Settings

- `hosts/<your-host-name>/configuration.nix`: System-wide settings
- `hosts/<your-host-name>/home.nix`: User-specific settings (Home Manager)
- `hosts/<your-host-name>/config/`: Application configuration files (e.g., Niri config)

## 4. Registering in `flake.nix`

Add your new host to the `outputs` section in `flake.nix`.

```nix
nixosConfigurations = {
  "your-host-name" = mkHost "your-host-name" ./hosts/your-host-name;
};
```

## 5. Applying the Configuration

```bash
sudo nixos-rebuild switch --flake .#your-host-name
```

## Troubleshooting

- **hardware-configuration.nix missing**: Ensure it is placed inside the correct host directory under `hosts/`.
- **Hostname mismatch**: The `system.hostname` in `variables.nix`, the definition in `flake.nix`, and the name used in `nixos-rebuild switch --flake .#name` must all match.
