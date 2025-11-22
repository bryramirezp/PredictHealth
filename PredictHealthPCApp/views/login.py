# views/login.py - Vista de Login

import customtkinter as ctk
from tkinter import Text
from config import COLORS, LOGO_PATH

class LoginView(ctk.CTkFrame):
    def __init__(self, parent, on_login_success):
        super().__init__(parent, fg_color=COLORS['white'])
        self.on_login_success = on_login_success
        self.pack(fill="both", expand=True)
        
        self.create_widgets()
    
    def create_widgets(self):
        # Frame central
        center_frame = ctk.CTkFrame(self, fg_color=COLORS['white'])
        center_frame.place(relx=0.5, rely=0.5, anchor="center")
        
        # Logo
        try:
            from PIL import Image as PILImage
            logo_image = PILImage.open(LOGO_PATH)
            logo_image = logo_image.resize((150, 150))
            logo_ctk = ctk.CTkImage(light_image=logo_image, size=(150, 150))
            logo_label = ctk.CTkLabel(center_frame, image=logo_ctk, text="")
            logo_label.pack(pady=(0, 10))
        except Exception as e:
            print(f"Error cargando logo: {e}")
            # Continuar sin logo si hay error
        
        # Título
        title = ctk.CTkLabel(
            center_frame,
            text="PredictHealth",
            font=("Arial", 32, "bold"),
            text_color=COLORS['primary_blue']
        )
        title.pack(pady=(0, 5))
        
        subtitle = ctk.CTkLabel(
            center_frame,
            text="Tu salud en tus manos",
            font=("Arial", 14),
            text_color=COLORS['gray_medium']
        )
        subtitle.pack(pady=(0, 30))
        
        # Email
        email_label = ctk.CTkLabel(
            center_frame,
            text="Correo electrónico",
            font=("Arial", 12),
            text_color=COLORS['gray_dark']
        )
        email_label.pack(anchor="w", padx=20)
        
        self.email_entry = ctk.CTkEntry(
            center_frame,
            width=350,
            height=45,
            placeholder_text="ejemplo@correo.com",
            border_color=COLORS['primary_blue_light'],
            fg_color=COLORS['white']
        )
        self.email_entry.pack(pady=(5, 15), padx=20)
        
        # Password
        password_label = ctk.CTkLabel(
            center_frame,
            text="Contraseña",
            font=("Arial", 12),
            text_color=COLORS['gray_dark']
        )
        password_label.pack(anchor="w", padx=20)
        
        self.password_entry = ctk.CTkEntry(
            center_frame,
            width=350,
            height=45,
            placeholder_text="password",
            show="•",
            border_color=COLORS['primary_blue_light'],
            fg_color=COLORS['white']
        )
        self.password_entry.pack(pady=(5, 25), padx=20)
        
        # Botón de login
        self.login_button = ctk.CTkButton(
            center_frame,
            text="Iniciar Sesión",
            width=350,
            height=45,
            font=("Arial", 14, "bold"),
            fg_color=COLORS['primary_blue'],
            hover_color=COLORS['primary_blue_dark'],
            command=self.handle_login
        )
        self.login_button.pack(pady=(0, 20))
        
        # Separador
        separator = ctk.CTkFrame(
            center_frame,
            width=350,
            height=1,
            fg_color=COLORS['gray_medium']
        )
        separator.pack(pady=(0, 15))
        
        # Credenciales de prueba
        credentials_label = ctk.CTkLabel(
            center_frame,
            text="Credenciales de prueba:",
            font=("Arial", 11, "bold"),
            text_color=COLORS['gray_dark']
        )
        credentials_label.pack(pady=(0, 5))
        
        # Texto seleccionable para credenciales
        credentials_text_frame = ctk.CTkFrame(center_frame, fg_color=COLORS['white'], corner_radius=5)
        credentials_text_frame.pack(pady=(0, 10), padx=20, fill="x")
        
        credentials_text = Text(
            credentials_text_frame,
            height=1,
            font=("Arial", 10),
            fg=COLORS['gray_dark'],
            bg=COLORS['white'],
            borderwidth=1,
            highlightthickness=1,
            highlightbackground=COLORS['primary_blue_light'],
            highlightcolor=COLORS['primary_blue'],
            wrap="word",
            relief="solid",
            cursor="xterm"
        )
        credentials_text.insert("1.0", "Paciente: paciente1@test.predicthealth.com / Paciente123!")
        credentials_text.config(state="normal", selectbackground=COLORS['primary_blue_light'], exportselection=True)
        credentials_text.pack(padx=10, pady=8, fill="x")
        
        # Aviso de solo pacientes
        patient_only_label = ctk.CTkLabel(
            center_frame,
            text="*Esta app solo funciona para pacientes*",
            font=("Arial", 10, "italic"),
            text_color=COLORS['warning_yellow']
        )
        patient_only_label.pack(pady=(0, 10))
        
        # Mensaje de error
        self.error_label = ctk.CTkLabel(
            center_frame,
            text="",
            font=("Arial", 11),
            text_color=COLORS['error_red']
        )
        self.error_label.pack()
        
        # Enter para login
        self.password_entry.bind('<Return>', lambda e: self.handle_login())
    
    def handle_login(self):
        email = self.email_entry.get().strip()
        password = self.password_entry.get().strip()
        
        if not email or not password:
            self.show_error("Por favor ingresa email y contraseña")
            return
        
        # Validación básica de email
        if '@' not in email:
            self.show_error("Email inválido")
            return
        
        # Llamar al callback con las credenciales
        self.on_login_success(email, password)
    
    def show_error(self, message):
        self.error_label.configure(text=message)
        # Limpiar el error después de 3 segundos
        self.after(3000, lambda: self.error_label.configure(text=""))
    
    def clear_fields(self):
        self.email_entry.delete(0, 'end')
        self.password_entry.delete(0, 'end')
        self.error_label.configure(text="")
