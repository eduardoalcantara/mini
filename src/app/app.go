package app

import "context"

// App e a struct principal de bindings do Wails.
// Esta camada apenas orquestra chamadas para services.
type App struct {
	ctx context.Context
}

// New cria uma nova instancia do App.
func New() *App {
	return &App{}
}

// Startup e chamado pelo Wails quando a aplicacao inicia.
func (a *App) Startup(ctx context.Context) {
	a.ctx = ctx
}
