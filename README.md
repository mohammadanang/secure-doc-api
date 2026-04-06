# 🛡️ Secure Doc API

![Go Version](https://img.shields.io/badge/Go-1.24-00ADD8?style=flat&logo=go)
![Docker](https://img.shields.io/badge/Docker-Distroless-2496ED?style=flat&logo=docker)
![GCP](https://img.shields.io/badge/Google_Cloud-GKE-4285F4?style=flat&logo=googlecloud)
![DevSecOps](https://img.shields.io/badge/DevSecOps-Shift_Left-success)

Secure Doc API adalah implementasi REST API berkinerja tinggi menggunakan Golang, dirancang dengan arsitektur *Zero Trust* dan praktik **DevSecOps** sejak penulisan kode hingga proses *deployment* di produksi. 

Proyek ini mendemonstrasikan bagaimana membangun dan men-deploy layanan ke **Google Kubernetes Engine (GKE)** menggunakan pipeline CI/CD otomatis, pemindaian kerentanan, dan otentikasi tanpa kunci rahasia (*Keyless Authentication*).

---

## 🏗️ Arsitektur & Alur DevSecOps

Proyek ini mengadopsi prinsip *Shift-Left Security*, di mana pengujian keamanan dilakukan sedini mungkin dalam siklus pengembangan.

1. **SAST (Static Application Security Testing):** Setiap *push* ke repositori akan memicu GitHub Actions untuk menjalankan `gosec` (Go Security Checker) guna mendeteksi celah di level kode.
2. **Keyless Authentication:** Integrasi GitHub Actions ke Google Cloud menggunakan **Workload Identity Federation (WIF)**, menghilangkan kebutuhan untuk menyimpan JSON *Service Account Keys* secara permanen.
3. **Secure Containerization:** Aplikasi dibungkus menggunakan *Multi-stage build* dan **Google Distroless Image**. *Container* dijalankan sebagai *non-root user* untuk mencegah eskalasi hak akses.
4. **Vulnerability Scanning:** *Image* disimpan di **GCP Artifact Registry** yang secara otomatis memindai CVE (Common Vulnerabilities and Exposures) pada layer OS.
5. **High Availability & Secure Runtime:** Aplikasi di-deploy ke **GKE Autopilot** dengan konfigurasi:
   - `replicas: 3` & Horizontal Pod Autoscaler (HPA) untuk skalabilitas.
   - *Liveness & Readiness Probes* untuk *self-healing*.
   - *Read-Only Root Filesystem* (`securityContext`) untuk mencegah injeksi *malware* di level *container*.

---

## 🚀 Teknologi yang Digunakan

* **Bahasa Pemrograman:** Golang (Go 1.24)
* **Keamanan Kode:** `gosec`
* **Containerization:** Docker (Multi-stage, Distroless)
* **CI/CD:** GitHub Actions / Google Cloud Build
* **Cloud Provider:** Google Cloud Platform (GCP)
* **Infrastruktur & Orkestrasi:** GKE, Artifact Registry, Workload Identity Federation

---

## 📂 Struktur Direktori

```text
.
├── cmd/
│   └── server/
│       └── main.go           # Entrypoint aplikasi dengan Graceful Shutdown
├── deploy/
│   └── k8s/
│       ├── deployment.yaml   # Konfigurasi Pod, Replikasi, & Security Context
│       ├── hpa.yaml          # Horizontal Pod Autoscaler
│       └── service.yaml      # Eksposur publik dengan LoadBalancer
├── Dockerfile                # Definisi Distroless image
├── README.md
├── .gitignore
├── cloudbuild.yaml
├── go.mod
└── Makefile
