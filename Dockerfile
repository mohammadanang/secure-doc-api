# ==========================================
# Stage 1: Builder
# ==========================================
FROM golang:1.24-alpine AS builder

# Set working directory
WORKDIR /app

COPY go.mod ./

RUN go mod download

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

EXPOSE 8080

ENTRYPOINT ["/secure-api"]