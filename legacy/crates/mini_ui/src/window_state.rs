//! Window state management with persistence
//!
//! This module handles saving and loading window position, size, and state
//! to/from `%APPDATA%/mini/window_state.json`

use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

/// Window state information persisted to disk
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WindowState {
    /// X position in pixels
    pub x: i32,
    /// Y position in pixels
    pub y: i32,
    /// Window width in pixels
    pub width: u32,
    /// Window height in pixels
    pub height: u32,
    /// Monitor identifier (UUID or index)
    pub monitor_id: Option<String>,
    /// Whether the window was maximized (never save position when maximized)
    pub is_maximized: bool,
}

impl Default for WindowState {
    fn default() -> Self {
        Self {
            x: 100,
            y: 100,
            width: 800,
            height: 600,
            monitor_id: None,
            is_maximized: false,
        }
    }
}

impl WindowState {
    /// Load window state from disk
    pub fn load() -> Result<Self> {
        let path = Self::state_path()?;

        if !path.exists() {
            return Ok(Self::default());
        }

        let content = std::fs::read_to_string(&path)?;
        let state: WindowState = serde_json::from_str(&content)?;
        Ok(state)
    }

    /// Save window state to disk
    pub fn save(&self) -> Result<()> {
        let path = Self::state_path()?;

        // Create parent directory if it doesn't exist
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }

        let content = serde_json::to_string_pretty(self)?;
        std::fs::write(&path, content)?;
        Ok(())
    }

    /// Get the path to the window state file
    fn state_path() -> Result<PathBuf> {
        let app_data = paths::data_dir();
        Ok(app_data.join("window_state.json"))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_window_state_default() {
        let state = WindowState::default();
        assert_eq!(state.x, 100);
        assert_eq!(state.y, 100);
        assert_eq!(state.width, 800);
        assert_eq!(state.height, 600);
        assert!(!state.is_maximized);
    }

    #[test]
    fn test_window_state_serialization() {
        let state = WindowState {
            x: 200,
            y: 300,
            width: 1024,
            height: 768,
            monitor_id: Some("monitor-1".to_string()),
            is_maximized: false,
        };

        let json = serde_json::to_string(&state).unwrap();
        let deserialized: WindowState = serde_json::from_str(&json).unwrap();

        assert_eq!(state.x, deserialized.x);
        assert_eq!(state.y, deserialized.y);
        assert_eq!(state.width, deserialized.width);
        assert_eq!(state.height, deserialized.height);
        assert_eq!(state.monitor_id, deserialized.monitor_id);
        assert_eq!(state.is_maximized, deserialized.is_maximized);
    }
}
