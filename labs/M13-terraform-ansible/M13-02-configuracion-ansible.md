# M13-02 — Configuración con Ansible

[← Página anterior](M13-01-provision-ec2.md) · [Siguiente página →](../M14-caso-integrador/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Configurar la EC2 creada en M13-01 con Ansible: instalar y arrancar un servicio web usando el
inventario generado por Terraform.

### Prerrequisitos

- La EC2 de M13-01 corriendo y su `inventory.ini`. Clave SSH disponible.

### En qué consiste

Escribes un playbook que instala nginx y lo ejecutas contra el inventario; compruebas que responde.

### 1 — Escribe el playbook

**Acción:** Crea `labs-sandbox/m13/site.yml`:

```yaml
- hosts: web
  become: true
  tasks:
    - name: Instalar nginx
      apt:
        name: nginx
        state: present
        update_cache: true
    - name: Asegurar nginx arrancado
      service:
        name: nginx
        state: started
        enabled: true
```

**Por qué:** Ansible se encarga de la **configuración** (lo que corre dentro de la máquina).
**Resultado esperado:** Un playbook que instala y arranca nginx.

### 2 — Comprueba la conectividad

**Acción:**

```bash
cd labs-sandbox/m13
ansible -i inventory.ini web -m ping --private-key ~/.ssh/tu-clave
```

**Por qué:** Confirmas que Ansible llega a la máquina antes de configurar.
**Resultado esperado:** `pong` desde el host.

> [!TIP]
> Si la primera conexión SSH pregunta por el fingerprint, exporta
> `ANSIBLE_HOST_KEY_CHECKING=False` para la demo (no en producción).

### 3 — Ejecuta el playbook

**Acción:**

```bash
ansible-playbook -i inventory.ini site.yml --private-key ~/.ssh/tu-clave
```

**Por qué:** Aplicas la configuración sobre la infraestructura provista por Terraform.
**Resultado esperado:** El play termina con `ok`/`changed` y sin `failed`.

### 4 — Verifica el servicio

**Acción:**

```bash
curl http://$(terraform output -raw public_ip)
```

**Por qué:** Compruebas el resultado del flujo combinado de punta a punta.
**Resultado esperado:** Responde el HTML por defecto de nginx.

### 5 — Limpia

**Acción:** `terraform destroy` en `labs-sandbox/m13`.
**Por qué:** No dejes la EC2 corriendo tras la práctica.
**Resultado esperado:** La instancia y el security group se eliminan.

> [!WARNING]
> Una EC2 olvidada genera coste. Destruye al terminar la sesión.

## Comprueba tu entendimiento

**Ansible llega a la máquina**
Ejecuta el módulo `ping`.
→ Devuelve `pong`.

**El servicio responde**
Haz `curl` a la IP pública.
→ Responde nginx.

## Reto

### 1 — Provisión y configuración en un solo flujo

¿Cómo encadenarías `terraform apply` y `ansible-playbook` para que un único comando deje la máquina
lista?

<details>
<summary>Ver solución</summary>

Un script (o un job de CI) que: 1) `terraform apply -auto-approve`, 2) genere el inventario desde
`terraform output -json`, 3) lance `ansible-playbook`. Cada herramienta mantiene su
responsabilidad, pero el flujo queda automatizado de punta a punta.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `UNREACHABLE` / timeout SSH | Security group sin puerto 22 o IP equivocada | Revisa el SG y el inventario |
| `Permission denied (publickey)` | Clave o usuario incorrectos | Usa `--private-key` correcto y `ansible_user=ubuntu` |
| `Host key verification failed` | Fingerprint no aceptado | `ANSIBLE_HOST_KEY_CHECKING=False` (solo demo) |
| La EC2 sigue tras la práctica | Olvidaste destruir | `terraform destroy` |
