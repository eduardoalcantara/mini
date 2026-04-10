//! System tray icon implementation
//!
//! This module provides tray icon functionality with:
//! - Left click: toggle show/hide window
//! - Right click: context menu (Open, Positioning, Sync, Close)
//! - Monitor detection for tray click location
//! - First-time minimize notification

use std::sync::Arc;
use std::sync::atomic::Ordering;

/// Tray icon handle
pub struct TrayIcon {
    #[cfg(target_os = "windows")]
    inner: Arc<windows_impl::TrayIconInner>,
    #[cfg(not(target_os = "windows"))]
    _private: (),
}

/// Tray icon events
#[derive(Debug, Clone)]
pub enum TrayEvent {
    /// Left click - toggle window visibility
    ToggleWindow,
    /// Right click - show context menu
    ShowContextMenu { x: i32, y: i32 },
    /// Context menu item selected
    MenuItemSelected(MenuItem),
}

/// Context menu items
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MenuItem {
    Open,
    Positioning,
    Sync,
    Close,
}

impl TrayIcon {
    /// Create a new tray icon
    pub fn new() -> anyhow::Result<Self> {
        #[cfg(target_os = "windows")]
        {
            windows_impl::create_tray_icon()
        }
        #[cfg(not(target_os = "windows"))]
        {
            stub_impl::create_tray_icon()
        }
    }

    /// Show the tray icon
    pub fn show(&self) -> anyhow::Result<()> {
        #[cfg(target_os = "windows")]
        {
            windows_impl::show_tray_icon(self)
        }
        #[cfg(not(target_os = "windows"))]
        {
            Ok(())
        }
    }

    /// Hide the tray icon
    pub fn hide(&self) -> anyhow::Result<()> {
        #[cfg(target_os = "windows")]
        {
            windows_impl::hide_tray_icon(self)
        }
        #[cfg(not(target_os = "windows"))]
        {
            Ok(())
        }
    }

    /// Set the window handle to control
    #[cfg(target_os = "windows")]
    pub fn set_window_handle(&self, hwnd: windows::Win32::Foundation::HWND) {
        self.inner.set_window_handle(hwnd);
    }

    /// Check if window should be hidden from taskbar when minimized
    #[cfg(target_os = "windows")]
    pub fn should_hide_from_taskbar(&self) -> bool {
        self.inner.should_hide_from_taskbar.load(Ordering::Relaxed)
    }

    /// Set whether window should be hidden from taskbar when minimized
    #[cfg(target_os = "windows")]
    pub fn set_hide_from_taskbar(&self, hide: bool) {
        self.inner.should_hide_from_taskbar.store(hide, Ordering::Relaxed);
    }

    /// Hide window from taskbar (call when minimizing)
    #[cfg(target_os = "windows")]
    pub fn hide_window_from_taskbar(&self) -> anyhow::Result<()> {
        windows_impl::hide_window_from_taskbar(self)
    }

    /// Show window in taskbar (call when restoring)
    #[cfg(target_os = "windows")]
    pub fn show_window_in_taskbar(&self) -> anyhow::Result<()> {
        windows_impl::show_window_in_taskbar(self)
    }

    /// Install a window procedure hook to intercept minimize button clicks
    #[cfg(target_os = "windows")]
    pub fn install_minimize_hook(&self) -> anyhow::Result<()> {
        windows_impl::install_minimize_hook(self)
    }
}

#[cfg(target_os = "windows")]
mod windows_impl {
    use super::*;
    use windows::Win32::{
        Foundation::{HWND, LPARAM, WPARAM, LRESULT},
        Graphics::Gdi::HBRUSH,
        UI::{
            Shell::{Shell_NotifyIconW, NOTIFYICONDATAW, NIM_ADD, NIM_DELETE, NIF_ICON, NIF_MESSAGE, NIF_TIP, NIF_SHOWTIP},
            WindowsAndMessaging::{
                CreateWindowExW, DefWindowProcW, RegisterClassW, WNDCLASSW, WM_USER, WS_OVERLAPPED,
                WS_EX_TOOLWINDOW, WS_EX_NOACTIVATE, HCURSOR, HICON, WNDCLASS_STYLES,
                GetWindowLongPtrW, SetWindowLongPtrW, GWLP_USERDATA, GWLP_WNDPROC,
                FindWindowW,
                SendMessageW, WM_GETICON, ICON_SMALL, ShowWindow, SW_HIDE, SW_SHOW, SW_RESTORE, SetForegroundWindow,
                IsWindowVisible, WM_SYSCOMMAND, SC_MINIMIZE, CallWindowProcW,
            },
        },
        System::LibraryLoader::GetModuleHandleW,
    };
    use windows::core::PCWSTR;
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;
    use std::sync::atomic::{AtomicPtr, Ordering};

    const WM_TRAYICON: u32 = WM_USER + 1;
    const TRAY_ICON_ID: u32 = 1;

    pub struct TrayIconInner {
        hwnd: AtomicPtr<HWND>,
        icon_id: u32,
        is_visible: std::sync::atomic::AtomicBool,
        pub(crate) should_hide_from_taskbar: std::sync::atomic::AtomicBool,
    }

    impl TrayIconInner {
        fn new() -> Self {
            Self {
                hwnd: AtomicPtr::new(std::ptr::null_mut()),
                icon_id: TRAY_ICON_ID,
                is_visible: std::sync::atomic::AtomicBool::new(false),
                should_hide_from_taskbar: std::sync::atomic::AtomicBool::new(true), // Default: hide from taskbar
            }
        }

        pub(crate) fn set_window_handle(&self, hwnd: HWND) {
            let hwnd_ptr = Box::into_raw(Box::new(hwnd));
            let old = self.hwnd.swap(hwnd_ptr, Ordering::Relaxed);
            if !old.is_null() {
                unsafe { drop(Box::from_raw(old)) };
            }
        }

        fn get_window_handle(&self) -> Option<HWND> {
            let ptr = self.hwnd.load(Ordering::Relaxed);
            if ptr.is_null() {
                None
            } else {
                Some(unsafe { *ptr })
            }
        }
    }

    impl Drop for TrayIconInner {
        fn drop(&mut self) {
            if self.is_visible.load(Ordering::Relaxed) {
                let _ = hide_tray_icon_inner(self);
            }
            let ptr = self.hwnd.swap(std::ptr::null_mut(), Ordering::Relaxed);
            if !ptr.is_null() {
                unsafe { drop(Box::from_raw(ptr)) };
            }
        }
    }

    pub fn create_tray_icon() -> anyhow::Result<TrayIcon> {
        let inner = Arc::new(TrayIconInner::new());

        // Create a hidden window to receive tray icon messages
        unsafe {
            let hinstance = GetModuleHandleW(None)?;
            let class_name = to_wide_string("MiniTrayIconWindow");

            let wc = WNDCLASSW {
                style: WNDCLASS_STYLES(0),
                lpfnWndProc: Some(tray_window_proc as _),
                cbClsExtra: 0,
                cbWndExtra: 0,
                hInstance: hinstance.into(),
                hIcon: HICON::default(),
                hCursor: HCURSOR::default(),
                hbrBackground: HBRUSH::default(),
                lpszMenuName: PCWSTR::null(),
                lpszClassName: PCWSTR::from_raw(class_name.as_ptr()),
            };

            RegisterClassW(&wc);

            let inner_ptr = Box::into_raw(Box::new(inner.clone()));

            let window_name = to_wide_string("Mini Tray Icon");
            let hwnd = CreateWindowExW(
                WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE,
                PCWSTR::from_raw(class_name.as_ptr()),
                PCWSTR::from_raw(window_name.as_ptr()),
                WS_OVERLAPPED,
                0, 0, 0, 0,
                None,
                None,
                Some(hinstance.into()), // Convert HMODULE to HINSTANCE
                Some(inner_ptr as *mut _),
            )?; // CreateWindowExW returns Result<HWND, Error> in windows 0.61

            // Store the inner pointer in window user data
            SetWindowLongPtrW(hwnd, GWLP_USERDATA, inner_ptr as isize);
        }

        Ok(TrayIcon {
            inner,
        })
    }

    unsafe extern "system" fn tray_window_proc(
        hwnd: HWND,
        msg: u32,
        wparam: WPARAM,
        lparam: LPARAM,
    ) -> LRESULT {
        if msg == WM_TRAYICON {
            if let Some(inner) = unsafe { get_tray_icon_inner(hwnd) } {
                match lparam.0 as u32 {
                    // WM_LBUTTONUP - Left click
                    0x0202 => {
                        if let Some(window_hwnd) = inner.get_window_handle() {
                            unsafe {
                                let is_visible = IsWindowVisible(window_hwnd);
                                if is_visible.as_bool() {
                                    // Window is visible: hide it completely
                                    log::info!("Tray icon clicked: window is visible, hiding it");
                                    let _ = ShowWindow(window_hwnd, SW_HIDE);
                                    // Ensure tray icon is visible
                                    let _ = show_tray_icon_inner(&*inner);
                                } else {
                                    // Window is hidden: show it
                                    log::info!("Tray icon clicked: window is hidden, showing it");
                                    let _ = ShowWindow(window_hwnd, SW_RESTORE);
                                    let _ = ShowWindow(window_hwnd, SW_SHOW);
                                    let _ = SetForegroundWindow(window_hwnd);
                                    // Keep tray icon visible (don't hide it)
                                }
                            }
                        }
                    }
                    // WM_RBUTTONUP - Right click
                    0x0205 => {
                        // TODO: Show context menu
                        // For now, restore window if hidden
                        if let Some(window_hwnd) = inner.get_window_handle() {
                            unsafe {
                                let is_visible = IsWindowVisible(window_hwnd);
                                if !is_visible.as_bool() {
                                    // Show window
                                    log::info!("Right click on tray: showing window");
                                    let _ = ShowWindow(window_hwnd, SW_RESTORE);
                                    let _ = ShowWindow(window_hwnd, SW_SHOW);
                                    let _ = SetForegroundWindow(window_hwnd);
                                    // Keep tray icon visible (don't hide it)
                                }
                            }
                        }
                    }
                    _ => {}
                }
            }
            return LRESULT(0);
        }

        unsafe { DefWindowProcW(hwnd, msg, wparam, lparam) }
    }

    unsafe fn get_tray_icon_inner(hwnd: HWND) -> Option<Arc<TrayIconInner>> {
        let ptr = unsafe { GetWindowLongPtrW(hwnd, GWLP_USERDATA) };
        if ptr == 0 {
            return None;
        }
        let inner = unsafe { &*(ptr as *const Arc<TrayIconInner>) };
        Some(inner.clone())
    }

    pub fn show_tray_icon(icon: &TrayIcon) -> anyhow::Result<()> {
        show_tray_icon_inner(&icon.inner)
    }

    fn show_tray_icon_inner(inner: &TrayIconInner) -> anyhow::Result<()> {
        unsafe {
            let mut nid = NOTIFYICONDATAW::default();
            nid.cbSize = std::mem::size_of::<NOTIFYICONDATAW>() as u32;
            nid.uID = inner.icon_id;
            nid.uFlags = NIF_MESSAGE | NIF_TIP | NIF_SHOWTIP;
            nid.uCallbackMessage = WM_TRAYICON;

            // Get the hidden window handle
            let _hinstance = GetModuleHandleW(None)?;
            let class_name = to_wide_string("MiniTrayIconWindow");
            let hwnd = FindWindowW(
                PCWSTR::from_raw(class_name.as_ptr()),
                PCWSTR::null(),
            )?; // FindWindowW returns Result<HWND, Error> in windows 0.61

            nid.hWnd = hwnd;

            // Set tooltip
            let tooltip = to_wide_string("mini");
            let tooltip_bytes = tooltip.as_slice();
            let tooltip_len = tooltip_bytes.len().min(127);
            nid.szTip[..tooltip_len].copy_from_slice(&tooltip_bytes[..tooltip_len]);

            // Try to get icon from window
            if let Some(window_hwnd) = inner.get_window_handle() {
                let icon = SendMessageW(
                    window_hwnd,
                    WM_GETICON,
                    Some(WPARAM(ICON_SMALL as usize)),
                    Some(LPARAM(0)),
                );
                if icon.0 != 0 {
                    nid.hIcon = HICON(icon.0 as _);
                    nid.uFlags |= NIF_ICON;
                }
            }

            let result = Shell_NotifyIconW(NIM_ADD, &nid);
            if result.as_bool() {
                inner.is_visible.store(true, Ordering::Relaxed);
                Ok(())
            } else {
                anyhow::bail!("Failed to add tray icon: {}", std::io::Error::last_os_error())
            }
        }
    }

    pub fn hide_tray_icon(icon: &TrayIcon) -> anyhow::Result<()> {
        hide_tray_icon_inner(&icon.inner)
    }

    fn hide_tray_icon_inner(inner: &TrayIconInner) -> anyhow::Result<()> {
        unsafe {
            let mut nid = NOTIFYICONDATAW::default();
            nid.cbSize = std::mem::size_of::<NOTIFYICONDATAW>() as u32;
            nid.uID = inner.icon_id;

            let _hinstance = GetModuleHandleW(None)?;
            let class_name = to_wide_string("MiniTrayIconWindow");
            let hwnd = FindWindowW(
                PCWSTR::from_raw(class_name.as_ptr()),
                PCWSTR::null(),
            )?; // FindWindowW returns Result<HWND, Error> in windows 0.61

            // Check if window is invalid (HWND.0 is *mut c_void, check if null)
            if hwnd.is_invalid() {
                return Ok(()); // Window already destroyed
            }

            nid.hWnd = hwnd;

            let result = Shell_NotifyIconW(NIM_DELETE, &nid);
            if result.as_bool() {
                inner.is_visible.store(false, Ordering::Relaxed);
                Ok(())
            } else {
                anyhow::bail!("Failed to remove tray icon: {}", std::io::Error::last_os_error())
            }
        }
    }

    fn to_wide_string(s: &str) -> Vec<u16> {
        OsStr::new(s).encode_wide().chain(std::iter::once(0)).collect()
    }

    pub fn hide_window_from_taskbar(icon: &TrayIcon) -> anyhow::Result<()> {
        if let Some(window_hwnd) = icon.inner.get_window_handle() {
            unsafe {
                log::info!("Hiding window completely: HWND={:?}", window_hwnd);

                // Simply hide the window - this will remove it from taskbar
                let _ = ShowWindow(window_hwnd, SW_HIDE);

                // Show tray icon (ensure it's visible)
                show_tray_icon_inner(&icon.inner)?;

                log::info!("Window hidden, tray icon shown");
            }
        }
        Ok(())
    }

    pub fn show_window_in_taskbar(icon: &TrayIcon) -> anyhow::Result<()> {
        if let Some(window_hwnd) = icon.inner.get_window_handle() {
            unsafe {
                log::info!("Showing window: HWND={:?}", window_hwnd);

                // Show the window (restore if minimized, or show if hidden)
                let _ = ShowWindow(window_hwnd, SW_RESTORE);
                let _ = ShowWindow(window_hwnd, SW_SHOW);
                let _ = SetForegroundWindow(window_hwnd);

                // Keep tray icon visible (don't hide it)
                // The tray icon should always be visible when the feature is enabled

                log::info!("Window shown, tray icon remains visible");
            }
        }
        Ok(())
    }

    // Store the original window procedure and tray icon reference
    static ORIGINAL_WNDPROC: std::sync::OnceLock<std::sync::Mutex<Option<unsafe extern "system" fn(HWND, u32, WPARAM, LPARAM) -> LRESULT>>> = std::sync::OnceLock::new();
    static HOOK_TRAY_ICON: std::sync::OnceLock<std::sync::Mutex<Option<Arc<TrayIconInner>>>> = std::sync::OnceLock::new();

    pub fn install_minimize_hook(icon: &TrayIcon) -> anyhow::Result<()> {
        if let Some(window_hwnd) = icon.inner.get_window_handle() {
            unsafe {
                log::info!("Installing minimize hook for HWND={:?}", window_hwnd);

                // Store reference to tray icon inner for the hook
                HOOK_TRAY_ICON.get_or_init(|| std::sync::Mutex::new(Some(icon.inner.clone())));

                // Get the current window procedure
                let current_proc = GetWindowLongPtrW(window_hwnd, GWLP_WNDPROC);
                if current_proc == 0 {
                    anyhow::bail!("Failed to get current window procedure");
                }

                // Store the original procedure
                let original_proc: unsafe extern "system" fn(HWND, u32, WPARAM, LPARAM) -> LRESULT =
                    std::mem::transmute(current_proc);
                ORIGINAL_WNDPROC.get_or_init(|| std::sync::Mutex::new(Some(original_proc)));

                // Install our hook
                let hook_proc: unsafe extern "system" fn(HWND, u32, WPARAM, LPARAM) -> LRESULT = window_proc_hook;
                SetWindowLongPtrW(window_hwnd, GWLP_WNDPROC, hook_proc as isize);

                log::info!("Minimize hook installed successfully");
            }
        }
        Ok(())
    }

    unsafe extern "system" fn window_proc_hook(
        hwnd: HWND,
        msg: u32,
        wparam: WPARAM,
        lparam: LPARAM,
    ) -> LRESULT {
        // Intercept WM_SYSCOMMAND with SC_MINIMIZE
        if msg == WM_SYSCOMMAND {
            let cmd = (wparam.0 & 0xFFF0) as u32;
            if cmd == SC_MINIMIZE {
                // Schedule hide operation to run after message processing
                // This avoids deadlocks by not doing heavy operations in the hook
                std::thread::spawn({
                    let hwnd_copy = hwnd;
                    move || {
                        std::thread::sleep(std::time::Duration::from_millis(10));
                        unsafe {
                            let _ = ShowWindow(hwnd_copy, SW_HIDE);
                        }

                        // Ensure tray icon is visible
                        if let Some(tray_icon_inner) = HOOK_TRAY_ICON.get() {
                            if let Ok(guard) = tray_icon_inner.lock() {
                                if let Some(inner) = guard.as_ref() {
                                    let _ = show_tray_icon_inner(inner);
                                }
                            }
                        }
                    }
                });

                // Still call original procedure but return early
                // This prevents the default minimize behavior
                if let Some(original_proc) = ORIGINAL_WNDPROC.get() {
                    if let Ok(guard) = original_proc.lock() {
                        if let Some(proc) = guard.as_ref() {
                            unsafe {
                                let _ = CallWindowProcW(Some(*proc), hwnd, msg, wparam, lparam);
                            }
                        }
                    }
                }
                return LRESULT(0);
            }
        }

        // Call the original window procedure for all other messages
        if let Some(original_proc) = ORIGINAL_WNDPROC.get() {
            if let Ok(guard) = original_proc.lock() {
                if let Some(proc) = guard.as_ref() {
                    unsafe {
                        return CallWindowProcW(Some(*proc), hwnd, msg, wparam, lparam);
                    }
                }
            }
        }

        // Fallback to DefWindowProcW if original proc not found
        unsafe {
            DefWindowProcW(hwnd, msg, wparam, lparam)
        }
    }
}

#[cfg(not(target_os = "windows"))]
mod stub_impl {
    use super::*;

    pub fn create_tray_icon() -> anyhow::Result<TrayIcon> {
        Ok(TrayIcon { _private: () })
    }
}
