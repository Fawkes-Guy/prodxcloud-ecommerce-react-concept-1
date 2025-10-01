# 1. Grupo de Seguridad (CORREGIDO Y SEGURO)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = aws_vpc.my_vpc.id

  # Permitir tráfico entrante en el puerto 80 (HTTP) desde cualquier lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# 2. Application Load Balancer (ALB)
resource "aws_lb" "my_load_balancer" {
  name               = "prodxcloud-store-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public-us-east-1a.id, aws_subnet.public-us-east-1b.id]
}

# 3. Grupo de Destino para el ALB
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  # Health checks will be configured later by the Kubernetes Ingress controller
}

# 4. Listener para el ALB
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

# 5. Output con el DNS del balanceador
output "load_balancer_dns" {
  value = aws_lb.my_load_balancer.dns_name
}


# --- RECURSOS DE KUBERNETES (COMENTADOS POR AHORA) ---
# Los desplegaremos más adelante con GitHub Actions, como sugiere la guía.
# Esto simplifica la creación inicial de la infraestructura.

/*
provider "kubernetes" {
  # La configuración del provider iría aquí. 
  # Se necesita configurar para que apunte a nuestro cluster EKS.
}

resource "kubernetes_deployment" "prodxcloud_store_deployment" {
  metadata {
    name = "prodxcloud-store"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "prodxcloud-store"
      }
    }
    template {
      metadata {
        labels = {
          app = "prodxcloud-store"
        }
      }
      spec {
        container {
          # ¡IMPORTANTE! Usa el nombre de tu imagen
          image = "fawkes-guy/prodxcloud-store:latest" 
          name  = "prodxcloud-store"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prodxcloud_store_service" {
  metadata {
    name = "prodxcloud-store"
  }
  spec {
    selector = {
      app = "prodxcloud-store"
    }
    port {
      port        = 80
      target_port = 80
    }
    # Para usar un ALB Ingress, el tipo de servicio sería NodePort o ClusterIP
    type = "NodePort" 
  }
}
*/