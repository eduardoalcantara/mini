//! Editor margin adjustment component.
//!
//! Implements the requirement that the editor should have a margin
//! of at least one line height before the first line of text.

use gpui::*;

/// Configuration for editor top margin.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct EditorMarginConfig {
    /// Margin in pixels (default: one line height)
    pub top_margin_px: f32,
}

impl Default for EditorMarginConfig {
    fn default() -> Self {
        Self {
            // Default to 20px (approximately one line height at 14px font)
            top_margin_px: 20.0,
        }
    }
}

impl EditorMarginConfig {
    /// Creates a new margin config with custom margin.
    pub fn new(top_margin_px: f32) -> Self {
        Self { top_margin_px }
    }

    /// Calculates margin based on line height.
    pub fn from_line_height(line_height: f32) -> Self {
        Self {
            top_margin_px: line_height,
        }
    }
}

/// Applies top margin to editor content.
pub fn apply_editor_top_margin(config: EditorMarginConfig) -> impl IntoElement {
    div()
        .h(px(config.top_margin_px))
        .w_full()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_margin() {
        let config = EditorMarginConfig::default();
        assert_eq!(config.top_margin_px, 20.0);
    }

    #[test]
    fn test_custom_margin() {
        let config = EditorMarginConfig::new(30.0);
        assert_eq!(config.top_margin_px, 30.0);
    }

    #[test]
    fn test_from_line_height() {
        let config = EditorMarginConfig::from_line_height(24.0);
        assert_eq!(config.top_margin_px, 24.0);
    }
}
