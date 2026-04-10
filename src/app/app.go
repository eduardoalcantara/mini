package app

import (
	"context"
	"errors"
	"log/slog"

	"mini/src/models"
	"mini/src/services"
)

// App e a struct principal de bindings do Wails.
type App struct {
	config *services.ConfigService
}

// New cria uma nova instancia do App.
func New() *App {
	return &App{}
}

// Startup e chamado pelo Wails quando a aplicacao inicia.
func (a *App) Startup(ctx context.Context) {
	_ = ctx
	cfg, err := services.NewConfigService()
	if err != nil {
		slog.Error("falha ao inicializar ConfigService", "err", err)
		return
	}
	a.config = cfg
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
