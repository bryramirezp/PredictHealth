# views/reservaciones.py - Vista de Reservaciones

import customtkinter as ctk
from tkinter import messagebox
from datetime import datetime, timedelta
from config import COLORS

class ReservacionesView(ctk.CTkFrame):
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
            text="📅 Mis Citas Médicas",
            font=("Arial", 24, "bold"),
            text_color=COLORS['white']
        )
        title.pack(side="left", padx=20, pady=20)
        
        # Botón agendar
        agendar_btn = ctk.CTkButton(
            header,
            text="+ Agendar Cita",
            font=("Arial", 13, "bold"),
            fg_color=COLORS['success_green'],
            hover_color=COLORS['primary_blue'],
            command=self.mostrar_formulario_cita,
            width=150,
            height=40
        )
        agendar_btn.pack(side="right", padx=20, pady=20)
        
        # Scrollable frame
        self.scroll_frame = ctk.CTkScrollableFrame(
            self,
            fg_color=COLORS['gray_light']
        )
        self.scroll_frame.pack(fill="both", expand=True, padx=20, pady=(0, 20))
    
    def load_data(self):
        # Limpiar frame
        for widget in self.scroll_frame.winfo_children():
            widget.destroy()
        
        # Obtener citas
        result = self.api_service.get_citas()
        
        if result.get('success'):
            citas = result['data']
            
            if not citas:
                self.mostrar_mensaje_vacio()
            else:
                self.mostrar_citas(citas)
        else:
            # Verificar si es error de autenticación
            if result.get('auth_error') and self.on_auth_error:
                self.on_auth_error()
                return
            
            error_label = ctk.CTkLabel(
                self.scroll_frame,
                text=f"Error al cargar citas: {result.get('message')}",
                font=("Arial", 16),
                text_color=COLORS['error_red']
            )
            error_label.pack(pady=50)
    
    def mostrar_mensaje_vacio(self):
        empty_frame = ctk.CTkFrame(self.scroll_frame, fg_color="transparent")
        empty_frame.pack(expand=True, pady=100)
        
        icon = ctk.CTkLabel(
            empty_frame,
            text="📅",
            font=("Arial", 80)
        )
        icon.pack()
        
        msg = ctk.CTkLabel(
            empty_frame,
            text="No tienes citas programadas",
            font=("Arial", 18, "bold"),
            text_color=COLORS['gray_dark']
        )
        msg.pack(pady=(10, 5))
        
        submsg = ctk.CTkLabel(
            empty_frame,
            text="Agenda tu primera consulta médica",
            font=("Arial", 13),
            text_color=COLORS['gray_medium']
        )
        submsg.pack()
    
    def mostrar_citas(self, citas):
        # Separar por estado
        programadas = [c for c in citas if c.get('estado') == 'programada']
        canceladas = [c for c in citas if c.get('estado') == 'cancelada']
        
        # Citas programadas
        if programadas:
            title = ctk.CTkLabel(
                self.scroll_frame,
                text="Citas Programadas",
                font=("Arial", 18, "bold"),
                text_color=COLORS['primary_blue']
            )
            title.pack(anchor="w", pady=(10, 10))
            
            for cita in programadas:
                self.crear_tarjeta_cita(cita, cancelable=True)
        
        # Citas canceladas
        if canceladas:
            title = ctk.CTkLabel(
                self.scroll_frame,
                text="Citas Canceladas",
                font=("Arial", 18, "bold"),
                text_color=COLORS['gray_medium']
            )
            title.pack(anchor="w", pady=(30, 10))
            
            for cita in canceladas:
                self.crear_tarjeta_cita(cita, cancelable=False)
    
    def crear_tarjeta_cita(self, cita, cancelable=True):
        # Determinar color según estado
        if cita.get('estado') == 'programada':
            border_color = COLORS['success_green']
            bg_color = COLORS['white']
        else:
            border_color = COLORS['gray_medium']
            bg_color = COLORS['gray_light']
        
        card = ctk.CTkFrame(
            self.scroll_frame,
            fg_color=bg_color,
            border_color=border_color,
            border_width=2,
            corner_radius=10
        )
        card.pack(fill="x", pady=(0, 15))
        
        # Grid layout
        card.grid_columnconfigure(1, weight=1)
        
        # Fecha (columna izquierda)
        fecha_frame = ctk.CTkFrame(card, fg_color="transparent", width=100)
        fecha_frame.grid(row=0, column=0, rowspan=3, padx=20, pady=20, sticky="n")
        fecha_frame.pack_propagate(False)
        
        # Parsear fecha
        try:
            fecha_obj = datetime.strptime(cita.get('fecha'), '%Y-%m-%d')
            mes = fecha_obj.strftime('%b').upper()
            dia = fecha_obj.strftime('%d')
        except:
            mes = "---"
            dia = "--"
        
        mes_label = ctk.CTkLabel(
            fecha_frame,
            text=mes,
            font=("Arial", 14, "bold"),
            text_color=COLORS['primary_blue']
        )
        mes_label.pack()
        
        dia_label = ctk.CTkLabel(
            fecha_frame,
            text=dia,
            font=("Arial", 36, "bold"),
            text_color=COLORS['gray_dark']
        )
        dia_label.pack()
        
        hora_label = ctk.CTkLabel(
            fecha_frame,
            text=cita.get('hora', ''),
            font=("Arial", 12),
            text_color=COLORS['gray_medium']
        )
        hora_label.pack()
        
        # Info (columna derecha)
        info_frame = ctk.CTkFrame(card, fg_color="transparent")
        info_frame.grid(row=0, column=1, sticky="ew", padx=20, pady=(20, 5))
        
        doctor_label = ctk.CTkLabel(
            info_frame,
            text=f"Dr(a). {cita.get('doctor_name', 'Sin asignar')}",
            font=("Arial", 16, "bold"),
            text_color=COLORS['gray_dark'],
            anchor="w"
        )
        doctor_label.pack(anchor="w")
        
        # Especialidad
        if cita.get('specialty'):
            specialty_label = ctk.CTkLabel(
                info_frame,
                text=f"Especialidad: {cita.get('specialty')}",
                font=("Arial", 11),
                text_color=COLORS['primary_blue'],
                anchor="w"
            )
            specialty_label.pack(anchor="w", pady=(2, 0))
        
        motivo_label = ctk.CTkLabel(
            info_frame,
            text=f"Motivo: {cita.get('motivo', 'Consulta general')}",
            font=("Arial", 12),
            text_color=COLORS['gray_medium'],
            anchor="w"
        )
        motivo_label.pack(anchor="w", pady=(5, 0))
        
        # Estado badge
        estado_frame = ctk.CTkFrame(card, fg_color="transparent")
        estado_frame.grid(row=1, column=1, sticky="ew", padx=20, pady=5)
        
        if cita.get('estado') == 'programada':
            badge_color = COLORS['success_green']
            badge_text = "✓ Programada"
        else:
            badge_color = COLORS['error_red']
            badge_text = "✗ Cancelada"
        
        badge = ctk.CTkLabel(
            estado_frame,
            text=badge_text,
            font=("Arial", 11, "bold"),
            text_color=COLORS['white'],
            fg_color=badge_color,
            corner_radius=5,
            padx=10,
            pady=5
        )
        badge.pack(side="left")
        
        # Botones
        if cancelable:
            buttons_frame = ctk.CTkFrame(card, fg_color="transparent")
            buttons_frame.grid(row=2, column=1, sticky="ew", padx=20, pady=(5, 20))
            
            cancelar_btn = ctk.CTkButton(
                buttons_frame,
                text="Cancelar Cita",
                font=("Arial", 11),
                fg_color=COLORS['error_red'],
                hover_color="#c0392b",
                command=lambda c=cita: self.cancelar_cita(c),
                width=120,
                height=30
            )
            cancelar_btn.pack(side="right")
    
    def mostrar_formulario_cita(self):
        # Ventana modal para agendar cita
        dialog = ctk.CTkToplevel(self)
        dialog.title("Agendar Nueva Cita")
        dialog.geometry("500x600")
        dialog.transient(self)
        dialog.grab_set()
        
        # Centrar ventana
        dialog.update_idletasks()
        x = (dialog.winfo_screenwidth() // 2) - (500 // 2)
        y = (dialog.winfo_screenheight() // 2) - (600 // 2)
        dialog.geometry(f"500x600+{x}+{y}")
        
        # Header
        header = ctk.CTkFrame(dialog, fg_color=COLORS['primary_blue'], height=60)
        header.pack(fill="x")
        header.pack_propagate(False)
        
        title = ctk.CTkLabel(
            header,
            text="📅 Nueva Cita Médica",
            font=("Arial", 18, "bold"),
            text_color=COLORS['white']
        )
        title.pack(pady=15)
        
        # Formulario
        form_frame = ctk.CTkScrollableFrame(dialog, fg_color=COLORS['gray_light'])
        form_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Doctor
        ctk.CTkLabel(
            form_frame,
            text="Selecciona Doctor:",
            font=("Arial", 13, "bold"),
            text_color=COLORS['gray_dark']
        ).pack(anchor="w", pady=(10, 5))
        
        # Obtener doctores
        doctores_result = self.api_service.get_doctores_disponibles()
        
        if doctores_result.get('success'):
            doctores = doctores_result['data']
            doctores_nombres = [
                f"Dr(a). {d.get('first_name', '')} {d.get('last_name', '')} - {d.get('specialty_name', 'General')}"
                for d in doctores
            ]
        else:
            # Verificar si es error de autenticación
            if doctores_result.get('auth_error') and self.on_auth_error:
                self.on_auth_error()
                dialog.destroy()
                return
            
            doctores = []
            doctores_nombres = ["No hay doctores disponibles"]
        
        doctor_var = ctk.StringVar(value=doctores_nombres[0] if doctores_nombres else "")
        doctor_menu = ctk.CTkOptionMenu(
            form_frame,
            variable=doctor_var,
            values=doctores_nombres,
            width=440,
            height=40,
            font=("Arial", 12)
        )
        doctor_menu.pack(pady=(0, 15))
        
        # Fecha
        ctk.CTkLabel(
            form_frame,
            text="Fecha:",
            font=("Arial", 13, "bold"),
            text_color=COLORS['gray_dark']
        ).pack(anchor="w", pady=(10, 5))
        
        fecha_entry = ctk.CTkEntry(
            form_frame,
            placeholder_text="YYYY-MM-DD",
            width=440,
            height=40
        )
        fecha_entry.pack(pady=(0, 15))
        
        # Sugerencia de fecha
        fecha_sugerida = (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')
        fecha_entry.insert(0, fecha_sugerida)
        
        # Hora
        ctk.CTkLabel(
            form_frame,
            text="Hora:",
            font=("Arial", 13, "bold"),
            text_color=COLORS['gray_dark']
        ).pack(anchor="w", pady=(10, 5))
        
        horas = [f"{h:02d}:00" for h in range(8, 18)]
        hora_var = ctk.StringVar(value="09:00")
        hora_menu = ctk.CTkOptionMenu(
            form_frame,
            variable=hora_var,
            values=horas,
            width=440,
            height=40
        )
        hora_menu.pack(pady=(0, 15))
        
        # Motivo
        ctk.CTkLabel(
            form_frame,
            text="Motivo de la consulta:",
            font=("Arial", 13, "bold"),
            text_color=COLORS['gray_dark']
        ).pack(anchor="w", pady=(10, 5))
        
        motivo_entry = ctk.CTkTextbox(
            form_frame,
            width=440,
            height=100
        )
        motivo_entry.pack(pady=(0, 20))
        
        # Botones
        buttons_frame = ctk.CTkFrame(form_frame, fg_color="transparent")
        buttons_frame.pack(pady=20)
        
        def guardar_cita():
                # Validar
                if not fecha_entry.get() or not motivo_entry.get("1.0", "end-1c").strip():
                    messagebox.showerror("Error", "Por favor completa todos los campos")
                    return
                
                # Obtener índice del doctor seleccionado
                doctor_idx = doctores_nombres.index(doctor_var.get())
                doctor_seleccionado = doctores[doctor_idx]
                
                # Crear cita
                cita_data = {
                    'doctor_id': str(doctor_seleccionado.get('id')),
                    'doctor_name': f"{doctor_seleccionado.get('first_name', '')} {doctor_seleccionado.get('last_name', '')}",
                    'specialty': doctor_seleccionado.get('specialty_name', 'General'),
                    'fecha': fecha_entry.get(),
                    'hora': hora_var.get(),
                    'motivo': motivo_entry.get("1.0", "end-1c").strip()
                }
                
                result = self.api_service.crear_cita(cita_data)
                
                if result.get('success'):
                    messagebox.showinfo("Éxito", "✅ Cita agendada correctamente")
                    dialog.destroy()
                    self.load_data()
                else:
                    # Verificar si es error de autenticación
                    if result.get('auth_error') and self.on_auth_error:
                        self.on_auth_error()
                        dialog.destroy()
                    else:
                        messagebox.showerror("Error", result.get('message', 'Error al agendar cita'))
        ctk.CTkButton(
            buttons_frame,
            text="Cancelar",
            width=100,
            fg_color=COLORS['gray_medium'],
            hover_color=COLORS['gray_dark'],
            command=dialog.destroy
        ).pack(side="left", padx=5)
            
        ctk.CTkButton(
            buttons_frame,
            text="Agendar",
            width=100,
            fg_color=COLORS['success_green'],
            hover_color=COLORS['primary_blue'],
            command=guardar_cita
        ).pack(side="left", padx=5)
        
    def cancelar_cita(self, cita):
        # Confirmar
        confirm = messagebox.askyesno(
            "Confirmar Cancelación",
            f"¿Estás seguro de cancelar la cita con Dr(a). {cita.get('doctor_name')}?"
        )
        
        if confirm:
            result = self.api_service.cancelar_cita(cita.get('id'))
            
            if result.get('success'):
                messagebox.showinfo("Éxito", "Cita cancelada")
                self.load_data()
            else:
                # Verificar si es error de autenticación
                if result.get('auth_error') and self.on_auth_error:
                    self.on_auth_error()
                else:
                    messagebox.showerror("Error", result.get('message', 'Error al cancelar'))
    
    def refresh_data(self):
        """Refrescar citas"""
        self.load_data()