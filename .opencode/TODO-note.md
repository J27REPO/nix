# Pendiente de revisar

## vicinae no abre con Windows Key (bindr)
- Fichero: `home/hyprland.nix:40`
- Cambiado a: `"SUPER, SUPER_L, exec, vicinae open"`
- `exec-once` mantiene `"vicinae server"` para el daemon
- Si tras reboot sigue sin funcionar:
  1. Probar `vicinae open` directo en terminal
  2. Verificar que `vicinae server` en `exec-once` está iniciando bien
  3. `which vicinae` para confirmar PATH
