# script-setup
Pequeños Script post-install de Ubuntu, Entre ellos de configuración y personalización de procesos.

-----------------------------------------------------------------------------
## node-clean

### Descripción:
  Herramienta interactiva para localizar y eliminar carpetas comunes en
  proyectos Node.js (node_modules, .next) dentro de un directorio base.
  en `TARGETS=("node_modules" ".next")`()

### Características:
  - Interfaz TUI basada en dialog
  - Cálculo previo de espacio a liberar
  - Borrado total o selectivo
  - Soporte modo --dry-run
  - Restauración segura del estado de la terminal

### Uso:
```bash
  node-clean [--dry-run]
```