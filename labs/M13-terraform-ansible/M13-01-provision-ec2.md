# M13-01 — Provisión de EC2

[← Página anterior](README.md) · [Siguiente página →](M13-02-configuracion-ansible.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Crear una instancia EC2 mínima con Terraform y exponer sus datos (IP, id) como outputs, generando
un inventario para Ansible.

### Prerrequisitos

- Dev container (M01), credenciales activas (ventana AWS) y un par de claves SSH.

### En qué consiste

Defines la EC2 con su security group, la aplicas y generas el `inventory.ini` a partir de los outputs.

### 1 — Define la instancia y el security group

**Acción:** En `labs-sandbox/m13/main.tf`:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web" {
  name = "tfadv-web"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  tags = { Name = "tfadv-web" }
}
```

**Por qué:** Es una máquina mínima (free tier) con SSH y HTTP abiertos para la demo.
**Resultado esperado:** El `plan` propone crear la EC2 y su security group.

### 2 — Expón los datos como outputs

**Acción:**

```hcl
output "public_ip"   { value = aws_instance.web.public_ip }
output "instance_id" { value = aws_instance.web.id }
```

**Por qué:** Ansible necesitará la IP; los outputs son el puente.
**Resultado esperado:** Tras aplicar, `terraform output public_ip` devuelve la IP.

### 3 — Aplica

**Acción:**

```bash
cd labs-sandbox/m13
terraform init
terraform apply
```

**Por qué:** Creas la infraestructura que luego configurará Ansible.
**Resultado esperado:** La EC2 arranca y tiene IP pública.

### 4 — Genera el inventario para Ansible

**Acción:** Crea el inventario a partir del output:

```bash
echo "[web]" > inventory.ini
echo "$(terraform output -raw public_ip) ansible_user=ubuntu" >> inventory.ini
```

**Por qué:** Terraform conoce la IP; Ansible la lee del inventario.
**Resultado esperado:** `inventory.ini` contiene la IP de la instancia bajo `[web]`.

> [!WARNING]
> No destruyas todavía: la EC2 se usa en **M13-02**. Destruye al terminar ese lab.

## Comprueba tu entendimiento

**La instancia existe**
Ejecuta `terraform output public_ip`.
→ Devuelve una IP pública.

**Inventario generado**
Lee `inventory.ini`.
→ Contiene la IP bajo el grupo `[web]`.

## Reto

### 1 — Inventario sin pasos manuales

¿Cómo generarías el inventario automáticamente al aplicar, sin el `echo` a mano?

<details>
<summary>Ver solución</summary>

Usa un recurso `local_file` con una `templatefile(...)` que renderice el inventario a partir de los
atributos de la instancia. Así, cada `apply` regenera el `inventory.ini` actualizado.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `InvalidKeyPair.NotFound` | `key_name` no existe en la región | Crea/importa el par de claves o ajusta `var.key_name` |
| Sin IP pública | Subred sin auto-assign public IP | Usa una subred pública o asigna IP elástica |
| `UnauthorizedOperation` | Falta permiso EC2 | Revisa permisos (M11) / el tester (M01) |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
