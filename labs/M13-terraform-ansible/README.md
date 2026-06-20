# M13 — Terraform y Ansible

[← Página anterior](../M12-troubleshooting/M12-01-escenarios-incidencias.md) · [Siguiente página →](M13-01-provision-ec2.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en los laboratorios (este módulo tiene dos).

## Qué aprenderás

- La separación entre **provisión** (crear la infraestructura) y **configuración** (instalar y
  ajustar lo que corre dentro).
- Pasar **outputs** de Terraform a Ansible mediante un inventario.
- Un flujo combinado Terraform → Ansible sobre una instancia EC2.

## Teoría

| Herramienta | Responde a | Ejemplo |
|-------------|-----------|---------|
| **Terraform** | ¿Qué infraestructura existe? | Crea la EC2, el security group, la IP |
| **Ansible** | ¿Cómo está configurada por dentro? | Instala nginx, copia config, arranca servicios |

El puente entre ambas es el **inventario**: Terraform sabe la IP de la máquina (un `output`), y
Ansible necesita esa IP para conectarse. El patrón limpio es que Terraform **genere** el inventario
que Ansible consume.

> [!NOTE]
> **No mezcles responsabilidades.** Se puede instalar software con `user_data` o `provisioner` de
> Terraform, pero eso vuelve la infraestructura frágil. Terraform crea; Ansible configura.

## Demostración guiada

> Recorrido del formador. Crea una EC2 real (🔴 AWS): hazlo en la sesión y destruye al final.

1. **Provisión con Terraform.** Se crea una EC2 mínima (free tier) con su security group y se
   exponen `public_ip` y `instance_id` como outputs.
2. **Generar el inventario.** Con un `local_file` (o `terraform output -json`) se produce un
   `inventory.ini` con la IP de la máquina.
3. **Configurar con Ansible.** Un playbook instala un servicio básico (p. ej. nginx) usando ese
   inventario; se comprueba en el navegador/`curl` que responde.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M13-01 | [Provisión de EC2](M13-01-provision-ec2.md) | Crear una EC2 con Terraform y exponer sus datos como outputs/inventario |
| M13-02 | [Configuración con Ansible](M13-02-configuracion-ansible.md) | Instalar un servicio con Ansible usando el inventario generado |

→ Empieza por **[M13-01 — Provisión de EC2](M13-01-provision-ec2.md)**.
