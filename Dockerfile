# ==========================================
# Stage 1: Builder
# ==========================================
FROM golang:1.24-alpine AS builder

# Set working directory
WORKDIR /app

# Copy module files (jika Anda sudah menambahkan dependency luar nantinya)
COPY go.mod ./
# COPY go.sum ./ (Uncomment jika go.sum sudah ada)
RUN go mod download

# Copy seluruh kode sumber
COPY . .

# Build binary Golang secara statis (CGO_ENABLED=0) agar kompatibel dengan distroless
# Flag -ldflags="-w -s" digunakan untuk menghapus debug info (memperkecil ukuran file)
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o secure-api ./cmd/server/main.go

# ==========================================
# Stage 2: Final / Runner
# ==========================================
# Menggunakan Google Distroless base image (sangat aman, ukuran super kecil, tanpa shell)
FROM gcr.io/distroless/static:nonroot

WORKDIR /

# Salin binary dari stage builder
COPY --from=builder /app/secure-api .

# Jalankan aplikasi sebagai user non-root (ID 65532 adalah default user nonroot di distroless)
# Ini mencegah ekskalasi hak akses jika container diretas
USER 65532:65532

# Expose port aplikasi
EXPOSE 8080

# Entrypoint langsung menunjuk ke binary
ENTRYPOINT ["/secure-api"]