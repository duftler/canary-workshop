package main

import (
    "fmt"
    "net/http"
    "os"
    "time"

    "github.com/joho/godotenv"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

func recordMetrics() {
    go func() {
        for {
            opsProcessed.Inc()
            time.Sleep(2 * time.Second)
        }
    }()
}

var (
    opsProcessed = promauto.NewCounter(prometheus.CounterOpts{
        Name: "myapp_processed_ops_total",
        Help: "The total number of processed events",
    })
)

func init() {
    if err := godotenv.Load("local.env"); err != nil {
        fmt.Println("No local.env file found.")
    }
}

func main() {
    someName, exists := os.LookupEnv("SOME_NAME")

    if exists {
  	    fmt.Println(someName)
    } else {
        fmt.Println("No env var set...")
    }

    fmt.Printf("Hi %s...\n", someName)

    recordMetrics()

    http.Handle("/metrics", promhttp.Handler())
    http.HandleFunc("/", HelloServer)
    http.ListenAndServe(":8080", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
    someName := os.Getenv("SOME_NAME")

    fmt.Fprintf(w, "Hello, %s and %s!", r.URL.Path[1:], someName)
}
