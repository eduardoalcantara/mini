//! Welcome screen component for the mini editor.
//!
//! Displays a welcome screen on first launch with options to:
//! - Open File
//! - Open Folder
//! - Open Tasks Panel
//! - Access Settings
//! - Access Help

use gpui::*;

/// Welcome screen component.
pub struct WelcomeScreen {
    /// Whether this is the first time opening the app
    is_first_open: bool,
}

impl WelcomeScreen {
    /// Creates a new welcome screen.
    pub fn new(is_first_open: bool) -> Self {
        Self { is_first_open }
    }
}

impl Render for WelcomeScreen {
    fn render(&mut self, _window: &mut Window, _cx: &mut Context<Self>) -> impl IntoElement {
        div()
            .size_full()
            .bg(rgb(0xFAF6EF)) // Vanilla Cream background
            .flex()
            .flex_col()
            .items_center()
            .justify_center()
            .gap(px(24.0))
            .p(px(48.0))
            .child(
                div()
                    .max_w(px(600.0))
                    .flex()
                    .flex_col()
                    .gap(px(32.0))
                    .items_center()
                    .child(
                        div()
                            .flex()
                            .gap(px(16.0))
                            .items_center()
                            .child(
                                div()
                                    .text_size(px(24.0))
                                    .font_weight(FontWeight::BOLD)
                                    .text_color(rgb(0x2C2416)) // Dark Brown
                                    .child("mini")
                            )
                    )
                    .child(
                        div()
                            .text_size(px(18.0))
                            .text_color(rgb(0x6B5E4F)) // Medium Brown
                            .child("Minimalist, Intelligent, Nice Interface")
                    )
                    .child(
                        div()
                            .text_size(px(14.0))
                            .text_color(rgb(0x8B7355)) // Muted Brown
                            .child("Welcome to your new text editor")
                    )
                    .child(
                        div()
                            .w_full()
                            .flex()
                            .flex_col()
                            .gap(px(12.0))
                            .child(
                                self.render_button("Abrir Arquivo", rgb(0x3484F7))
                            )
                            .child(
                                self.render_button("Abrir Pasta", rgb(0x3484F7))
                            )
                            .child(
                                self.render_button("Abrir Painel de Tarefas", rgb(0x3484F7))
                            )
                            .child(
                                div()
                                    .w_full()
                                    .flex()
                                    .gap(px(12.0))
                                    .child(
                                        self.render_button("Configurações", rgb(0x6B5E4F))
                                    )
                                    .child(
                                        self.render_button("Ajuda", rgb(0x6B5E4F))
                                    )
                            )
                    )
            )
    }
}

impl WelcomeScreen {
    fn render_button(
        &self,
        label: impl Into<SharedString>,
        bg_color: Rgba,
    ) -> impl IntoElement {
        div()
            .w_full()
            .p(px(12.0))
            .bg(bg_color)
            .text_color(rgb(0xFFFFFF))
            .rounded_md()
            .cursor_pointer()
            .hover(|style| style.opacity(0.9))
            .child(label.into())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_welcome_screen_creation() {
        let screen = WelcomeScreen::new(true);
        assert!(screen.is_first_open);
    }

    #[test]
    fn test_welcome_screen_not_first_open() {
        let screen = WelcomeScreen::new(false);
        assert!(!screen.is_first_open);
    }
}
