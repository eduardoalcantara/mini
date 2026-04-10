package main

import (
	"embed"
	"log/slog"
	"os"

	"mini/src/app"

	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/assetserver"
	"github.com/wailsapp/wails/v2/pkg/options/windows"
)

//go:embed all:frontend/dist
var assets embed.FS

func main() {
	appInstance := app.New()

	err := wails.Run(&options.App{
		Title:             "",
		Width:             1100,
		Height:            700,
		MinWidth:          600,
		MinHeight:         400,
		HideWindowOnClose: false,
		AssetServer: &assetserver.Options{
			Assets: assets,
		},
		BackgroundColour: &options.RGBA{R: 26, G: 26, B: 31, A: 255},
		OnStartup:        appInstance.Startup,
		Bind: []interface{}{
			appInstance,
		},
		Windows: &windows.Options{
			WebviewIsTransparent: false,
			WindowIsTranslucent:  false,
			DisableWindowIcon:    true,
			Theme:                windows.Dark,
			CustomTheme: &windows.ThemeSettings{
				DarkModeTitleBar:   windows.RGB(26, 26, 31),
				DarkModeTitleText:  windows.RGB(26, 26, 31),
				DarkModeBorder:     windows.RGB(26, 26, 31),
				LightModeTitleBar:  windows.RGB(26, 26, 31),
				LightModeTitleText: windows.RGB(26, 26, 31),
				LightModeBorder:    windows.RGB(26, 26, 31),
			},
		},
	})
	if err != nil {
		slog.Error("falha ao iniciar aplicação", "erro", err)
		os.Exit(1)
	}
}
