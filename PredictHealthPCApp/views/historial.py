# views/historial.py - Vista de Historial Médico

import customtkinter as ctk
from config import COLORS

class HistorialView(ctk.CTkFrame):
    def __init__(self, parent, api_service, on_auth_error=None):
        super().__init__(parent, fg_color=COLORS['gray_light'])
        self.api_service = api_service
        self.on_auth_error = on_auth_error
        self.pack(fill="both", expand=True)
        
        self.create_widgets()
        self.load_data()
    
    def create_widgets(self):
        # Header
        header = ctk.CTkFrame(self, fg_color=COLORS['primary_blue'], height=80)
        header.pack(fill="x", padx=20, pady=(20, 10))
        header.pack_propagate(False)
        
        title = ctk.CTkLabel(
            header,
            text="📋 Mi Expediente Médico",
            font=("Arial", 24, "bold"),
            text_color=COLORS['white']
        )
        title.pack(side="left", padx=20, pady=20)
        
        # Scrollable frame
        self.scroll_frame = ctk.CTkScrollableFrame(
            self,
            fg_color=COLORS['gray_light']
        )
        self.scroll_frame.pack(fill="both", expand=True, padx=20, pady=(0, 20))
    
    def load_data(self):
        # Obtener datos del historial
        result = self.api_service.get_historial_medico()
        
        if result.get('success'):
            data = result['data']
            self.create_medical_record(data)
        else:
            # Verificar si es error de autenticación
            if result.get('auth_error') and self.on_auth_error:
                self.on_auth_error()
                return
            
            error_label = ctk.CTkLabel(
                self.scroll_frame,
                text=f"Error al cargar historial médico: {result.get('message', 'Desconocido')}",
                font=("Arial", 16),
                text_color=COLORS['error_red']
            )
            error_label.pack(pady=50)
    
    def create_medical_record(self, data):
        # 1. Perfil de Salud
        if data.get('health_profile'):
            self.create_section("💪 Perfil General de Salud", self.create_health_profile, data['health_profile'])
        
        # 2. Condiciones Diagnosticadas
        if data.get('conditions'):
            self.create_section("🏥 Condiciones Diagnosticadas", self.create_conditions_list, data['conditions'])
        
        # 3. Medicamentos Actuales
        if data.get('medications'):
            self.create_section("💊 Medicamentos Actuales", self.create_medications_list, data['medications'])
        
        # 4. Alergias
        if data.get('allergies'):
            self.create_section("⚠️ Alergias", self.create_allergies_list, data['allergies'])
        
        # 5. Historial Familiar
        if data.get('family_history'):
            self.create_section("👨‍👩‍👧‍👦 Historial Familiar", self.create_family_history, data['family_history'])
    
    def create_section(self, title, content_function, data):
        # Frame de sección
        section_frame = ctk.CTkFrame(self.scroll_frame, fg_color=COLORS['white'], corner_radius=10)
        section_frame.pack(fill="x", pady=(0, 15))
        
        # Título de sección
        title_label = ctk.CTkLabel(
            section_frame,
            text=title,
            font=("Arial", 18, "bold"),
            text_color=COLORS['primary_blue']
        )
        title_label.pack(anchor="w", padx=20, pady=(20, 10))
        
        # Contenido
        content_function(section_frame, data)
    
    def create_health_profile(self, parent, profile):
        # Grid de 2 columnas
        content_frame = ctk.CTkFrame(parent, fg_color="transparent")
        content_frame.pack(fill="x", padx=20, pady=(0, 20))
        
        content_frame.grid_columnconfigure(0, weight=1)
        content_frame.grid_columnconfigure(1, weight=1)
        
        row = 0
        
        # Altura
        if profile.get('height_cm'):
            self.create_info_item(content_frame, "Altura", f"{profile['height_cm']} cm", row, 0)
            row += 1
        
        # Peso
        if profile.get('weight_kg'):
            self.create_info_item(content_frame, "Peso", f"{profile['weight_kg']} kg", row, 0)
            row += 1
        
        # Tipo de sangre
        if profile.get('blood_type'):
            self.create_info_item(content_frame, "Tipo de sangre", profile['blood_type'], row, 0)
            row += 1
        
        row = 0
        
        # Fumador
        self.create_info_item(
            content_frame, 
            "Fumador", 
            "Sí" if profile.get('is_smoker') else "No",
            row, 1
        )
        row += 1
        
        # Alcohol
        self.create_info_item(
            content_frame,
            "Consume alcohol",
            "Sí" if profile.get('consumes_alcohol') else "No",
            row, 1
        )
        row += 1
        
        # Actividad física
        if profile.get('physical_activity_minutes_weekly'):
            self.create_info_item(
                content_frame,
                "Actividad física semanal",
                f"{profile['physical_activity_minutes_weekly']} minutos",
                row, 1
            )
            row += 1
        
        # Notas (span de 2 columnas)
        if profile.get('notes'):
            notes_label = ctk.CTkLabel(
                content_frame,
                text=f"Notas: {profile['notes']}",
                font=("Arial", 11),
                text_color=COLORS['gray_dark'],
                wraplength=600,
                justify="left"
            )
            notes_label.grid(row=row, column=0, columnspan=2, sticky="w", pady=(10, 0))
    
    def create_info_item(self, parent, label, value, row, col):
        item_frame = ctk.CTkFrame(parent, fg_color="transparent")
        item_frame.grid(row=row, column=col, sticky="w", pady=5, padx=10)
        
        label_widget = ctk.CTkLabel(
            item_frame,
            text=f"{label}:",
            font=("Arial", 11, "bold"),
            text_color=COLORS['gray_medium']
        )
        label_widget.pack(side="left")
        
        value_widget = ctk.CTkLabel(
            item_frame,
            text=value,
            font=("Arial", 11),
            text_color=COLORS['gray_dark']
        )
        value_widget.pack(side="left", padx=(5, 0))
    
    def create_conditions_list(self, parent, conditions):
        if not conditions:
            no_data = ctk.CTkLabel(
                parent,
                text="No hay condiciones registradas",
                font=("Arial", 11),
                text_color=COLORS['gray_medium']
            )
            no_data.pack(padx=20, pady=(0, 20))
            return
        
        for condition in conditions:
            self.create_list_item(
                parent,
                condition.get('name', 'Sin nombre'),
                condition.get('diagnosis_date', 'Fecha desconocida'),
                condition.get('notes', '')
            )
    
    def create_medications_list(self, parent, medications):
        if not medications:
            no_data = ctk.CTkLabel(
                parent,
                text="No hay medicamentos registrados",
                font=("Arial", 11),
                text_color=COLORS['gray_medium']
            )
            no_data.pack(padx=20, pady=(0, 20))
            return
        
        for med in medications:
            dosage = med.get('dosage', 'Sin dosis')
            frequency = med.get('frequency', 'Sin frecuencia')
            details = f"{dosage} - {frequency}"
            
            self.create_list_item(
                parent,
                med.get('name', 'Sin nombre'),
                details,
                f"Inicio: {med.get('start_date', 'Desconocido')}"
            )
    
    def create_allergies_list(self, parent, allergies):
        if not allergies:
            no_data = ctk.CTkLabel(
                parent,
                text="No hay alergias registradas",
                font=("Arial", 11),
                text_color=COLORS['gray_medium']
            )
            no_data.pack(padx=20, pady=(0, 20))
            return
        
        for allergy in allergies:
            severity = allergy.get('severity', 'Desconocida')
            reaction = allergy.get('reaction_description', '')
            
            # Color según severidad
            if severity == 'severe':
                color = COLORS['error_red']
                severity_text = "Severa"
            elif severity == 'moderate':
                color = COLORS['warning_yellow']
                severity_text = "Moderada"
            else:
                color = COLORS['success_green']
                severity_text = "Leve"
            
            self.create_list_item(
                parent,
                allergy.get('name', 'Sin nombre'),
                f"Severidad: {severity_text}",
                reaction,
                badge_color=color
            )
    
    def create_family_history(self, parent, history):
        if not history:
            no_data = ctk.CTkLabel(
                parent,
                text="No hay historial familiar registrado",
                font=("Arial", 11),
                text_color=COLORS['gray_medium']
            )
            no_data.pack(padx=20, pady=(0, 20))
            return
        
        for item in history:
            relative = item.get('relative_type', 'Familiar')
            condition = item.get('condition_name', 'Sin condición')
            notes = item.get('notes', '')
            
            self.create_list_item(
                parent,
                condition,
                f"Familiar: {relative}",
                notes
            )
    
    def create_list_item(self, parent, title, subtitle, notes='', badge_color=None):
        item_frame = ctk.CTkFrame(parent, fg_color=COLORS['gray_light'], corner_radius=8)
        item_frame.pack(fill="x", padx=20, pady=(0, 10))
        
        # Título
        title_label = ctk.CTkLabel(
            item_frame,
            text=title,
            font=("Arial", 13, "bold"),
            text_color=COLORS['gray_dark']
        )
        title_label.pack(anchor="w", padx=15, pady=(15, 0))
        
        # Subtítulo
        if subtitle:
            subtitle_label = ctk.CTkLabel(
                item_frame,
                text=subtitle,
                font=("Arial", 11),
                text_color=COLORS['gray_medium']
            )
            subtitle_label.pack(anchor="w", padx=15, pady=(2, 0))
        
        # Notas
        if notes:
            notes_label = ctk.CTkLabel(
                item_frame,
                text=notes,
                font=("Arial", 10),
                text_color=COLORS['gray_medium'],
                wraplength=600,
                justify="left"
            )
            notes_label.pack(anchor="w", padx=15, pady=(5, 15))
        else:
            ctk.CTkLabel(item_frame, text="", height=10).pack()
        
        # Badge de color (para alergias)
        if badge_color:
            badge = ctk.CTkLabel(
                item_frame,
                text="●",
                font=("Arial", 20),
                text_color=badge_color
            )
            badge.place(relx=0.98, rely=0.5, anchor="e")
    
    def refresh_data(self):
        """Refrescar historial médico"""
        for widget in self.scroll_frame.winfo_children():
            widget.destroy()
        self.load_data()