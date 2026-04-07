# 🛡️ Secure Doc API

![Go Version](https://img.shields.io/badge/Go-1.24-00ADD8?style=flat&logo=go)
![Docker](https://img.shields.io/badge/Docker-Distroless-2496ED?style=flat&logo=docker)
![GCP](https://img.shields.io/badge/Google_Cloud-GKE_Autopilot-4285F4?style=flat&logo=googlecloud)
![DevSecOps](https://img.shields.io/badge/DevSecOps-Shift_Left-success)

Secure Doc API adalah implementasi REST API berkinerja tinggi menggunakan **Golang 1.24**, dirancang dengan arsitektur *Zero Trust* dan praktik **DevSecOps** sejak penulisan kode hingga proses *deployment* di lingkungan produksi. 

Proyek portofolio ini mendemonstrasikan otomatisasi CI/CD tingkat lanjut menggunakan infrastruktur *cloud-native* murni di **Google Cloud Platform (GCP)**, dengan fokus pada efisiensi biaya (*auto-scaling*) dan keamanan yang berlapis.

---

## 🏗️ Arsitektur & Alur DevSecOps

Proyek ini mengadopsi prinsip *Shift-Left Security* dan *Least Privilege*, memastikan kerentanan dicegah sedini mungkin:

1. **Native CI/CD Orchestration:** Seluruh otomatisasi dikelola secara terpusat oleh **Google Cloud Build** yang terpicu secara otomatis dari GitHub, menghilangkan redundansi *tools* pihak ketiga.
2. **SAST & Version Pinning:** Menjalankan *Static Application Security Testing* menggunakan `gosec` yang dikunci pada versi `v2.22.0` untuk mencegah *dependency drift* dan menjamin stabilitas *pipeline*.
3. **Secure Containerization:** Aplikasi dibungkus menggunakan teknik *Multi-stage build* dan **Google Distroless Image**. *Container* dijalankan secara eksplisit sebagai *non-root user* (ID: 65532).
4. **Automated Vulnerability Scanning:** *Image* disimpan di **GCP Artifact Registry** yang secara otomatis memindai CVE (Common Vulnerabilities and Exposures) pada *layer* OS.
5. **High Availability & Zero-Trust Runtime:** Aplikasi di-deploy ke **GKE Autopilot** dengan konfigurasi ketat:
   - **Horizontal Pod Autoscaler (HPA):** Efisiensi biaya dengan berjalan pada **1 Pod** saat *idle*, dan otomatis *scale-out* maksimal hingga **3 Pods** ketika utilitas CPU menyentuh 50%.
   - **Self-Healing:** Terintegrasi dengan *Liveness* & *Readiness Probes*.
   - **Immutable Filesystem:** Penerapan `readOnlyRootFilesystem` pada *Security Context* untuk mencegah injeksi *malware* maupun skrip jahat di level *container*.
6. **Strict IAM Governance:** Menggunakan *Service Account* dengan prinsip *Least Privilege* (hanya dibekali *role* spesifik seperti `logging.logWriter`, `artifactregistry.writer`, dan `container.developer`) dengan *output* log yang diamankan via `CLOUD_LOGGING_ONLY`.

---

## 🚀 Teknologi yang Digunakan

* **Bahasa Pemrograman:** Golang (Go 1.24)
* **Keamanan Kode:** `gosec` (Static Code Analysis)
* **Containerization:** Docker (Multi-stage, Distroless)
* **CI/CD Pipeline:** Google Cloud Build (IaC via `cloudbuild.yaml`)
* **Cloud Provider & Infrastructure:** * Google Kubernetes Engine (GKE) Autopilot
  * Google Artifact Registry
  * Google Cloud Logging & IAM

---

## 📂 Struktur Direktori

```text
.
├── cmd/
│   └── server/
│       └── main.go           # Entrypoint aplikasi dengan Graceful Shutdown & Health Probes
├── deploy/
│   └── k8s/
│       ├── deployment.yaml   # Konfigurasi Pod, Distroless User, & Security Context (Read-Only)
│       ├── hpa.yaml          # Horizontal Pod Autoscaler (1 to 3 Replicas)
│       └── service.yaml      # Eksposur publik dengan tipe LoadBalancer
├── .gitignore                # Mencegah kebocoran file lokal dan binari
├── cloudbuild.yaml           # Definisi Pipeline CI/CD Google Cloud Build
├── Dockerfile                # Multi-stage build menggunakan gcr.io/distroless/static
├── go.mod
└── go.sum
```

---

## 🛠️ Menjalankan Secara Lokal

1. **Kloning Repositori**:

   ```bash
   git clone [https://github.com/mohammadanang/secure-doc-api.git](https://github.com/mohammadanang/secure-doc-api.git)
   cd secure-doc-api
   ```

2. **Jalankan Aplikasi**:

   ```bash
   go run ./cmd/server/main.go
   ```

   Aplikasi akan berjalan di `http://localhost:8080`.

3. **Uji Health Check Endpoint**:

   ```bash
   curl http://localhost:8080/healthz
   ```

---

## 📈 Skenario Stress-Test (Auto-Scaling Kubernetes)

Untuk menguji bagaimana HPA (Horizontal Pod Autoscaler) bereaksi terhadap lonjakan traffic secara otomatis di GKE:

1. **Jalankan Load Generator (Di terminal terpisah)**:
   
   Membuat request tanpa henti ke layanan untuk meningkatkan beban CPU.

   ```bash
   kubectl run -i --tty load-generator --rm --image=busybox:1.28 -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://secure-api-service; done"
   ```

2. **Pantau Kinerja HPA secara Real-time**:

   ```bash
   kubectl get hpa secure-api-hpa -w
   ```

   _Anda akan melihat utilisasi CPU melonjak melewati batas 50%, yang akan memicu GKE untuk menambah jumlah replika dari 1 menjadi 3 Pods._

---

## 📖 Publikasi Proyek

Proyek portofolio ini didokumentasikan secara mendalam sebagai seri panduan implementasi DevSecOps di dunia nyata. Anda dapat membaca seri lengkapnya di bawah ini:

* **Part 1**: [Building a Zero-Trust Golang Backend (Part 1): Secure Coding & Distroless Containers]() (_dev.to_)

* **Part 2**: [Building a Zero-Trust Golang Backend (Part 2): CI/CD, Dependency Drift & GCP IAM]() (_dev.to_)

* **Part 3**: [Building a Zero-Trust Golang Backend (Part 3): Deploying to GKE with Strict Security Context]() (_dev.to_)

(_Tautan akan diperbarui seiring dengan publikasi artikel_)

---

Dibuat oleh [Mohammad Anang](https://github.com/mohammadanang)
