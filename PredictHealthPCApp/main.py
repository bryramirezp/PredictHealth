# main.py - Aplicación Principal de PredictHealth

import customtkinter as ctk
from tkinter import messagebox
from PIL import Image
import sys
import os

# Importar configuración
from config import COLORS, APP_TITLE, WINDOW_SIZE, LOGO_PATH

# Importar servicios
from services.api_service import APIService

# Importar vistas
from views.login import LoginView
from views.dashboard import DashboardView
from views.reservaciones import ReservacionesView
from views.perfil import PerfilView
from views.historial import HistorialView

class PredictHealthApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        # Configurar ventana
        self.title(APP_TITLE)
        
        # Establecer tamaño mínimo
        self.minsize(1200, 800)
        
        # Configurar tamaño inicial
        width, height = map(int, WINDOW_SIZE.split('x'))
        self.geometry(f'{width}x{height}')
        
        # Centrar ventana
        self.center_window()
        
        # Configurar tema
        ctk.set_appearance_mode("light")
        ctk.set_default_color_theme("blue")
        
        # Inicializar API service
        self.api_service = APIService()
        
        # Variable para la vista actual
        self.current_view = None
        
        # Mostrar login al inicio
        self.show_login()
    
    def center_window(self):
        """Centrar la ventana en la pantalla"""
        self.update_idletasks()
        # Obtener dimensiones de la ventana
        width = self.winfo_width()
        height = self.winfo_height()
        
        # Si las dimensiones son muy pequeñas (ventana no renderizada), usar valores por defecto
        if width < 100 or height < 100:
            width, height = map(int, WINDOW_SIZE.split('x'))
        
        # Calcular posición centrada
        screen_width = self.winfo_screenwidth()
        screen_height = self.winfo_screenheight()
        x = (screen_width // 2) - (width // 2)
        y = (screen_height // 2) - (height // 2)
        
        # Aplicar geometría
        self.geometry(f'{width}x{height}+{x}+{y}')
    
    def clear_window(self):
        """Limpiar todos los widgets de la ventana"""
        for widget in self.winfo_children():
            widget.destroy()
    
    def show_login(self):
        """Mostrar vista de login"""
        self.clear_window()
        self.current_view = LoginView(self, self.handle_login)
    
    def handle_login(self, email, password):
        """Manejar el proceso de login"""
        # Llamar al API service
        result = self.api_service.login(email, password)
        
        if result.get('success'):
            # Login exitoso, mostrar aplicación principal
            self.show_main_app()
        else:
            # Mostrar error
            error_message = result.get('message', 'Credenciales inválidas')
            messagebox.showerror("Error de Login", error_message)
    
    def handle_auth_error(self):
        """Manejar error de autenticación (token expirado)"""
        messagebox.showwarning(
            "Sesión Expirada",
            "Tu sesión ha expirado. Por favor, inicia sesión nuevamente."
        )
        self.api_service.logout()
        self.show_login()
    
    def show_main_app(self):
        """Mostrar la aplicación principal con navegación"""
        self.clear_window()
        
        # Frame principal con sidebar
        main_container = ctk.CTkFrame(self, fg_color=COLORS['white'])
        main_container.pack(fill="both", expand=True)
        
        # Sidebar
        sidebar = ctk.CTkFrame(
            main_container,
            width=250,
            fg_color=COLORS['primary_blue_dark'],
            corner_radius=0
        )
        sidebar.pack(side="left", fill="y")
        sidebar.pack_propagate(False)
        
        # Logo y título en sidebar
        try:
            from PIL import Image as PILImage
            logo_image = PILImage.open(LOGO_PATH)
            logo_image = logo_image.resize((80, 80))
            logo_ctk = ctk.CTkImage(light_image=logo_image, size=(80, 80))
            logo_label = ctk.CTkLabel(sidebar, image=logo_ctk, text="")
            logo_label.pack(pady=(30, 10))
        except Exception as e:
            print(f"Error cargando logo: {e}")
        
        app_name = ctk.CTkLabel(
            sidebar,
            text="PredictHealth",
            font=("Arial", 18, "bold"),
            text_color=COLORS['white']
        )
        app_name.pack(pady=(0, 20))
        
        # Usuario actual con foto
        if self.api_service.user_data:
            user_frame = ctk.CTkFrame(sidebar, fg_color="transparent")
            user_frame.pack(pady=(0, 20), padx=15)
            
            # Ruta de la foto
            foto_path = os.path.join(os.path.expanduser('~'), '.predicthealth_avatar.png')
            
            # Mostrar foto o iniciales
            if os.path.exists(foto_path):
                try:
                    from PIL import Image, ImageDraw
                    
                    # Hacer imagen circular
                    img = Image.open(foto_path).convert("RGBA")
                    img = img.resize((60, 60))
                    
                    # Crear máscara circular
                    mask = Image.new('L', (60, 60), 0)
                    draw = ImageDraw.Draw(mask)
                    draw.ellipse((0, 0, 60, 60), fill=255)
                    
                    # Aplicar máscara
                    output = Image.new('RGBA', (60, 60), (0, 0, 0, 0))
                    output.paste(img, (0, 0))
                    output.putalpha(mask)
                    
                    avatar_ctk = ctk.CTkImage(light_image=output, size=(60, 60))
                    user_icon = ctk.CTkLabel(
                        user_frame,
                        image=avatar_ctk,
                        text=""
                    )
                except:
                    user_icon = ctk.CTkLabel(
                        user_frame,
                        text="👤",
                        font=("Arial", 30),
                        text_color=COLORS['white']
                    )
            else:
                user_icon = ctk.CTkLabel(
                    user_frame,
                    text="👤",
                    font=("Arial", 30),
                    text_color=COLORS['white']
                )
            
            user_icon.pack()
            
            self.user_icon_label = user_icon
            
            self.user_name_label = ctk.CTkLabel(
                user_frame,
                text=self.api_service.user_data.get('nombre', 'Usuario'),
                font=("Arial", 12, "bold"),
                text_color=COLORS['white']
            )
            self.user_name_label.pack()
        
        # Separador
        separator = ctk.CTkFrame(sidebar, height=2, fg_color=COLORS['primary_blue_light'])
        separator.pack(fill="x", padx=20, pady=(0, 20))
        
        # Botones de navegación
        nav_buttons = [
            ("📊 Dashboard", self.show_dashboard),
            ("📅 Reservaciones", self.show_reservaciones),
            ("📋 Historial Médico", self.show_historial),
            ("👤 Mi Perfil", self.show_perfil),
        ]
        
        self.nav_buttons = []
        for text, command in nav_buttons:
            btn = ctk.CTkButton(
                sidebar,
                text=text,
                font=("Arial", 13),
                fg_color="transparent",
                hover_color=COLORS['primary_blue'],
                anchor="w",
                height=45,
                command=command
            )
            btn.pack(fill="x", padx=15, pady=5)
            self.nav_buttons.append(btn)
        
        # Botón de logout al final
        logout_button = ctk.CTkButton(
            sidebar,
            text="🚪 Cerrar Sesión",
            font=("Arial", 13),
            fg_color=COLORS['error_red'],
            hover_color="#C53030",
            height=45,
            command=self.handle_logout
        )
        logout_button.pack(side="bottom", fill="x", padx=15, pady=20)
        
        # Content frame (donde se muestran las vistas)
        self.content_frame = ctk.CTkFrame(
            main_container,
            fg_color=COLORS['gray_light'],
            corner_radius=0
        )
        self.content_frame.pack(side="right", fill="both", expand=True)
        
        # Mostrar dashboard por defecto
        self.show_dashboard()
    
    def clear_content(self):
        """Limpiar el área de contenido"""
        for widget in self.content_frame.winfo_children():
            widget.destroy()
    
    def highlight_nav_button(self, index):
        """Resaltar el botón de navegación activo"""
        for i, btn in enumerate(self.nav_buttons):
            if i == index:
                btn.configure(fg_color=COLORS['primary_blue'])
            else:
                btn.configure(fg_color="transparent")
    
    def show_dashboard(self):
        """Mostrar vista de dashboard"""
        self.clear_content()
        self.highlight_nav_button(0)
        self.current_view = DashboardView(self.content_frame, self.api_service, self.handle_auth_error)
    
    def show_reservaciones(self):
        """Mostrar vista de reservaciones"""
        self.clear_content()
        self.highlight_nav_button(1)
        self.current_view = ReservacionesView(self.content_frame, self.api_service, self.handle_auth_error)
    
    def show_historial(self):
        """Mostrar vista de historial médico"""
        self.clear_content()
        self.highlight_nav_button(2)
        self.current_view = HistorialView(self.content_frame, self.api_service, self.handle_auth_error)
    
    def show_perfil(self):
        """Mostrar vista de perfil"""
        self.clear_content()
        self.highlight_nav_button(3)
        self.current_view = PerfilView(self.content_frame, self.api_service, self.handle_auth_error)
    
    def handle_logout(self):
        """Manejar el cierre de sesión"""
        response = messagebox.askyesno(
            "Cerrar Sesión",
            "¿Estás seguro que deseas cerrar sesión?"
        )
        
        if response:
            self.api_service.logout()
            self.show_login()

    def update_sidebar_name(self, new_name):
        """Actualizar nombre en sidebar"""
        if hasattr(self, 'user_name_label'):
            self.user_name_label.configure(text=new_name)

    def update_sidebar_avatar(self):
        """Actualizar avatar en el sidebar"""
        if not hasattr(self, 'user_icon_label'):
            return
        
        foto_path = os.path.join(os.path.expanduser('~'), '.predicthealth_avatar.png')
        
        if os.path.exists(foto_path):
            try:
                from PIL import Image, ImageDraw
                
                # Hacer imagen circular
                img = Image.open(foto_path).convert("RGBA")
                img = img.resize((60, 60))
                
                mask = Image.new('L', (60, 60), 0)
                draw = ImageDraw.Draw(mask)
                draw.ellipse((0, 0, 60, 60), fill=255)
                
                output = Image.new('RGBA', (60, 60), (0, 0, 0, 0))
                output.paste(img, (0, 0))
                output.putalpha(mask)
                
                avatar_ctk = ctk.CTkImage(light_image=output, size=(60, 60))
                self.user_icon_label.configure(image=avatar_ctk, text="")
            except:
                self.user_icon_label.configure(image="", text="👤", font=("Arial", 30))
        else:
            self.user_icon_label.configure(image="", text="👤", font=("Arial", 30))

def main():
    """Función principal"""
    try:
        app = PredictHealthApp()
        app.mainloop()
    except KeyboardInterrupt:
        print("\nAplicación cerrada por el usuario")
        sys.exit(0)
    except Exception as e:
        print(f"Error fatal: {e}")
        messagebox.showerror("Error Fatal", f"Ocurrió un error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()

