job "grafana" {
  datacenters = ["dc1"]
  type        = "service"

  group "grafana-group" {
    count = 1

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:latest"

        ports = ["http"]

        # Environment variables for Grafana container
        env = {
          GF_SECURITY_ADMIN_USER     = "admin"
          GF_SECURITY_ADMIN_PASSWORD = "admin"
        }
      }

      resources {
        cpu    = 500  # MHz
        memory = 512  # MB
      }

      service {
        name = "grafana"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.grafana.rule=Host(`grafana.yourdomain.com`)",
          "traefik.http.routers.grafana.entrypoints=https",
          "traefik.http.routers.grafana.tls.certresolver=myresolver",
          "traefik.http.services.grafana.loadbalancer.server.port=${NOMAD_PORT_http}"
        ]

        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    # Port mapping
    network {
      port "http" {
        static = 3000
      }
    }
  }
}
