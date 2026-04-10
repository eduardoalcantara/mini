package models

// Config representa as preferências persistidas do usuário.
type Config struct {
	Theme       string `json:"theme"`
	Font        string `json:"font"`
	FontSize    int    `json:"font_size"`
	LineWrap    bool   `json:"line_wrap"`
	LineNumbers bool   `json:"line_numbers"`
}

// DefaultConfig retorna a configuração padrão do app.
func DefaultConfig() Config {
	return Config{
		Theme:       "perplexity-dark",
		Font:        "auto",
		FontSize:    16,
		LineWrap:    true,
		LineNumbers: true,
	}
}
