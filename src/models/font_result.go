package models

// FontResult é retornado ao frontend com a fonte e tamanho resolvidos.
type FontResult struct {
	Font     string `json:"font"`
	FontSize int    `json:"font_size"`
}
