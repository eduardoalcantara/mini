package app

import (
	"context"
	"errors"
	"log/slog"

	"mini/src/models"
	"mini/src/services"

	"github.com/wailsapp/wails/v2/pkg/runtime"
)

// App e a struct principal de bindings do Wails.
type App struct {
	ctx    context.Context
	config *services.ConfigService
}

// New cria uma nova instancia do App.
func New() *App {
	return &App{}
}

// Startup e chamado pelo Wails quando a aplicacao inicia.
func (a *App) Startup(ctx context.Context) {
	a.ctx = ctx
	cfg, err := services.NewConfigService()
	if err != nil {
		slog.Error("falha ao inicializar ConfigService", "err", err)
		return
	}
	a.config = cfg
}

// SetWindowBackground atualiza a cor de fundo da janela (WebView + barra nativa no Windows).
func (a *App) SetWindowBackground(r, g, b uint8) {
	runtime.WindowSetBackgroundColour(a.ctx, r, g, b, 255)
}

// SetWindowTitle atualiza o título da janela e da taskbar.
func (a *App) SetWindowTitle(title string) {
	runtime.WindowSetTitle(a.ctx, title)
}

// SetWindowsTheme alterna o tema do *chrome* nativo (barra de título) entre claro e escuro.
// Deve acompanhar temas claros/escuros da app para a barra não ficar sempre no modo escuro do Windows.
func (a *App) SetWindowsTheme(useLight bool) {
	if useLight {
		runtime.WindowSetLightTheme(a.ctx)
		return
	}
	runtime.WindowSetDarkTheme(a.ctx)
}

// GetConfig retorna a configuração atual do usuário.
func (a *App) GetConfig() (models.Config, error) {
	if a.config == nil {
		return models.DefaultConfig(), nil
	}
	return a.config.Get(), nil
}

// SetConfig persiste a configuração atualizada.
func (a *App) SetConfig(cfg models.Config) error {
	if a.config == nil {
		return errors.New("configuração indisponível")
	}
	return a.config.Set(cfg)
}

// ResolveFont retorna a fonte correta para uma dada extensão de arquivo (ex.: ".go", ".txt").
func (a *App) ResolveFont(fileExt string) (models.FontResult, error) {
	if a.config == nil {
		d := models.DefaultConfig()
		return models.FontResult{Font: "eb-garamond", FontSize: d.FontSize}, nil
	}
	return a.config.ResolveFont(fileExt), nil
}
