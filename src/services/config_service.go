package services

import (
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"strings"

	"mini/src/models"
)

// rawConfig permite distinguir omissão de false em campos booleanos.
type rawConfig struct {
	Theme       string `json:"theme"`
	Font        string `json:"font"`
	FontSize    int    `json:"font_size"`
	LineWrap    *bool  `json:"line_wrap"`
	LineNumbers *bool  `json:"line_numbers"`
}

var (
	validThemes = map[string]struct{}{
		"perplexity-dark":      {},
		"github-light-default": {},
		"claude-code-light":    {},
		"moleskine-light":      {},
	}
	validFonts = map[string]struct{}{
		"auto":           {},
		"eb-garamond":    {},
		"jetbrains-mono": {},
		"other":          {},
	}

	codeExts = map[string]struct{}{
		".md": {}, ".js": {}, ".ts": {}, ".go": {}, ".json": {}, ".yaml": {}, ".yml": {}, ".toml": {},
		".html": {}, ".css": {}, ".scss": {}, ".py": {}, ".sh": {}, ".bash": {}, ".zsh": {},
		".rs": {}, ".c": {}, ".cpp": {}, ".h": {}, ".java": {}, ".kt": {}, ".rb": {}, ".php": {}, ".sql": {},
	}
)

// ConfigService gerencia leitura e persistência das configurações do usuário.
type ConfigService struct {
	path   string
	config models.Config
}

// NewConfigService inicializa o serviço, lendo ou criando o config.json.
func NewConfigService() (*ConfigService, error) {
	exe, err := os.Executable()
	if err != nil {
		return nil, err
	}
	path := filepath.Join(filepath.Dir(exe), "config.json")

	svc := &ConfigService{path: path}
	if err := svc.load(); err != nil {
		return nil, err
	}
	return svc, nil
}

func (s *ConfigService) load() error {
	data, err := os.ReadFile(s.path)
	if errors.Is(err, os.ErrNotExist) {
		s.config = models.DefaultConfig()
		return s.save()
	}
	if err != nil {
		return err
	}
	var raw rawConfig
	if err := json.Unmarshal(data, &raw); err != nil {
		slog.Warn("config.json inválido — usando padrões", "erro", err)
		s.config = models.DefaultConfig()
		return s.save()
	}
	s.config = normalizeLoaded(raw)
	if err := s.save(); err != nil {
		return err
	}
	return nil
}

func normalizeLoaded(c rawConfig) models.Config {
	def := models.DefaultConfig()
	out := def
	if c.Theme != "" {
		out.Theme = c.Theme
	}
	if c.Font != "" {
		out.Font = c.Font
	}
	if c.FontSize != 0 {
		out.FontSize = c.FontSize
	}
	if c.LineWrap != nil {
		out.LineWrap = *c.LineWrap
	}
	if c.LineNumbers != nil {
		out.LineNumbers = *c.LineNumbers
	}
	return validateAndFix(out)
}

func validateAndFix(c models.Config) models.Config {
	if _, ok := validThemes[c.Theme]; !ok {
		c.Theme = models.DefaultConfig().Theme
	}
	if _, ok := validFonts[c.Font]; !ok {
		c.Font = models.DefaultConfig().Font
	}
	if c.FontSize < 10 {
		c.FontSize = 10
	}
	if c.FontSize > 18 {
		c.FontSize = 18
	}
	return c
}

func (s *ConfigService) save() error {
	data, err := json.MarshalIndent(s.config, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(s.path, data, 0o644)
}

// Get retorna uma cópia da configuração atual.
func (s *ConfigService) Get() models.Config {
	return s.config
}

// Set valida, atualiza e persiste.
func (s *ConfigService) Set(cfg models.Config) error {
	n := validateAndFix(cfg)
	if _, ok := validThemes[n.Theme]; !ok {
		return fmt.Errorf("theme inválido: %q", cfg.Theme)
	}
	if _, ok := validFonts[n.Font]; !ok {
		return fmt.Errorf("font inválida: %q", cfg.Font)
	}
	if n.FontSize < 10 || n.FontSize > 18 {
		return fmt.Errorf("font_size fora do intervalo 10–18: %d", cfg.FontSize)
	}
	s.config = n
	return s.save()
}

// ResolveFont retorna o identificador de fonte para CSS e o tamanho.
func (s *ConfigService) ResolveFont(fileExt string) models.FontResult {
	ext := strings.ToLower(strings.TrimSpace(fileExt))
	if ext != "" && !strings.HasPrefix(ext, ".") {
		ext = "." + ext
	}
	font := s.resolveFontSlug(ext)
	return models.FontResult{Font: font, FontSize: s.config.FontSize}
}

func (s *ConfigService) resolveFontSlug(ext string) string {
	switch s.config.Font {
	case "jetbrains-mono":
		return "jetbrains-mono"
	case "eb-garamond":
		return "eb-garamond"
	case "other":
		return "eb-garamond"
	case "auto":
		if _, ok := codeExts[ext]; ok {
			return "jetbrains-mono"
		}
		return "eb-garamond"
	default:
		return "eb-garamond"
	}
}
