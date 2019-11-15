package main

import (
    "fmt"
    "math/rand"
    "net/http"
    "os"
    "strconv"
    "time"

    "github.com/joho/godotenv"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var httpRequestRateFloat float64 = 0;
var httpErrorRateFloat float64 = 0;
var jobProcessingTimeStdDevFloat float64 = 1;
var jobProcessingTimeMeanFloat float64 = 0;
var networkLatencyStdDevFloat float64 = 1;
var networkLatencyMeanFloat float64 = 0;

func recordMetrics() {
    go func() {
        for {
            jobProcessingTime.Set(rand.NormFloat64() * jobProcessingTimeStdDevFloat + jobProcessingTimeMeanFloat)

            networkLatency.Set(rand.NormFloat64() * networkLatencyStdDevFloat + networkLatencyMeanFloat)

            httpRequestsToAdd := rand.NormFloat64() + httpRequestRateFloat
            httpRequests.Add(httpRequestsToAdd)
            httpErrors.Add(httpRequestRateFloat * httpErrorRateFloat)

            time.Sleep(1 * time.Second)
        }
    }()
}

var (
    httpRequests = promauto.NewCounter(prometheus.CounterOpts{
        Name: "http_request_count",
        Help: "HTTP requests",
    })
)

var (
    httpErrors = promauto.NewCounter(prometheus.CounterOpts{
        Name: "http_error_count",
        Help: "HTTP errors",
    })
)

var (
    jobProcessingTime = promauto.NewGauge(prometheus.GaugeOpts{
        Name: "job_processing_time",
        Help: "Job processing time",
    })
)

var (
    networkLatency = promauto.NewGauge(prometheus.GaugeOpts{
        Name: "network_latency",
        Help: "Network latency",
    })
)

func init() {
    if err := godotenv.Load("local.env"); err != nil {
        fmt.Println("No local.env file found.")
    }
}

func main() {
    httpRequestRateStr, _ := os.LookupEnv("HTTP_REQUEST_RATE")
    httpErrorRateStr, _ := os.LookupEnv("HTTP_ERROR_RATE")
    httpRequestRateFloat, _ = strconv.ParseFloat(httpRequestRateStr, 64)
    httpErrorRateFloat, _ = strconv.ParseFloat(httpErrorRateStr, 64)

    jobProcessingTimeStdDevStr, _ := os.LookupEnv("JOB_PROCESSING_TIME_STD_DEV")
    jobProcessingTimeMeanStr, _ := os.LookupEnv("JOB_PROCESSING_TIME_MEAN")
    jobProcessingTimeStdDevFloat, _ = strconv.ParseFloat(jobProcessingTimeStdDevStr, 64)
    jobProcessingTimeMeanFloat, _ = strconv.ParseFloat(jobProcessingTimeMeanStr, 64)

    networkLatencyStdDevStr, _ := os.LookupEnv("NETWORK_LATENCY_STD_DEV")
    networkLatencyMeanStr, _ := os.LookupEnv("NETWORK_LATENCY_MEAN")
    networkLatencyStdDevFloat, _ = strconv.ParseFloat(networkLatencyStdDevStr, 64)
    networkLatencyMeanFloat, _ = strconv.ParseFloat(networkLatencyMeanStr, 64)

    recordMetrics()

    http.Handle("/metrics", promhttp.Handler())
    http.HandleFunc("/", HelloServer)
    http.ListenAndServe(":8080", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, %s...", r.URL.Path[1:])
}
