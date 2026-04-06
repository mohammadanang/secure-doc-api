package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

func main() {
	mux := http.NewServeMux()

	// Endpoint /healthz wajib ada untuk Kubernetes Liveness/Readiness Probe
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		err := json.NewEncoder(w).Encode(HealthResponse{
			Status:  "OK",
			Message: "Service is running securely",
		})
		if err != nil {
			log.Printf("Error encoding JSON response: %v", err)
		}
	})

	// Endpoint dummy untuk API Dokumen
	mux.HandleFunc("/api/v1/documents", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, err := w.Write([]byte(`{"message": "Secure document upload endpoint ready"}`))
		if err != nil {
			log.Printf("Error writing response: %v", err)
		}
	})

	server := &http.Server{
		Addr:              ":8080",
		Handler:           mux,
		ReadHeaderTimeout: 3 * time.Second,
	}

	// Menjalankan server di goroutine agar tidak memblokir proses utama
	go func() {
		log.Println("Starting secure server on port 8080...")
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v\n", err)
		}
	}()

	// Menunggu sinyal interupsi (SIGINT, SIGTERM) dari Kubernetes/OS untuk Graceful Shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// Memberikan waktu maksimal 5 detik untuk menyelesaikan request yang sedang berjalan
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v\n", err)
	}

	log.Println("Server exiting gracefully")
}
