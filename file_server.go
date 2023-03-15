package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	const videoDir = "."
	const port = 8081

	http.Handle("/", addHeaders(http.FileServer(http.Dir(videoDir))))
	fmt.Printf("Starting server on %v\n", port)
	log.Printf("Serving %s on HTTP port: %v\n", videoDir, port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%v", port), nil))
}

func addHeaders(h http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		h.ServeHTTP(w, r)
	}
}
