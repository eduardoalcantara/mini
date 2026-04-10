package main

import (
	"embed"
	"log/slog"
	"os"

	"mini/src/app"

	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/assetserver"
)

//go:embed all:frontend/dist
var assets embed.FS

func main() {
	appInstance := app.New()

	err := wails.Run(&options.App{
		Title:  "Mini",
		Width:  1024,
		Height: 768,
		AssetServer: &assetserver.Options{
			Assets: assets,
		},
		BackgroundColour: &options.RGBA{R: 26, G: 26, B: 31, A: 1},
		OnStartup:        appInstance.Startup,
		Bind: []interface{}{
			appInstance,
		},
	})
	if err != nil {
		slog.Error("falha ao iniciar aplicação", "erro", err)
		os.Exit(1)
	}
}
