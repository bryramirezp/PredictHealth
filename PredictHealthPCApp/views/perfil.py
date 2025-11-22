# views/perfil.py - Vista de Perfil

from tkinter import filedialog
from PIL import Image
import os
import customtkinter as ctk
from tkinter import messagebox
from config import COLORS

class PerfilView(ctk.CTkFrame):
    def __init__(self, parent, api_service, on_auth_error=None):
        super().__init__(parent, fg_color=COLORS['gray_light'])
        self.api_service = api_service
        self.on_auth_error = on_auth_error
        self.pack(fill="both", expand=True)
        self.editing = False
        self.editable_fields = {}
        self.profile_data_complete = {}
        
        self.create_widgets()
        self.load_perfil()
    
    def create_widgets(self):
        # Header
        header = ctk.CTkFrame(self, fg_color=COLORS['primary_blue'], height=80)
        header.pack(fill="x", padx=20, pady=(20, 10))
        header.pack_propagate(False)
        
        title = ctk.CTkLabel(
            header,
            text="👤 Mi Perfil",
            font=("Arial", 24, "bold"),
            text_color=COLORS['white']
        )
        title.pack(side="left", padx=20, pady=20)
        
        # Botón de editar
        self.edit_button = ctk.CTkButton(
            header,
            text="✏️ Editar",
            font=("Arial", 13, "bold"),
            fg_color=COLORS['secondary_purple'],
            hover_color=COLORS['secondary_purple_dark'],
            command=self.toggle_edit_mode
        )
        self.edit_button.pack(side="right", padx=20, pady=20)
        
        # Frame central con el formulario
        self.center_frame = ctk.CTkFrame(self, fg_color=COLORS['white'], corner_radius=15)
        self.center_frame.pack(fill="both", expand=True, padx=40, pady=(10, 30))
        
        # Scrollable frame
        self.scroll_frame = ctk.CTkScrollableFrame(
            self.center_frame,
            fg_color=COLORS['white']
        )
        self.scroll_frame.pack(fill="both", expand=True, padx=30, pady=30)
    
    def load_perfil(self):
        # Obtener datos del perfil
        result = self.api_service.get_perfil()
        
        if result.get('success'):
            profile_data = result['data']
            
            # Extraer datos de la estructura del microservicio (personal_info, emails, phones)
            personal_info = profile_data.get('personal_info', {})
            emails = profile_data.get('emails', [])
            phones = profile_data.get('phones', [])
            
            # Construir nombre completo desde first_name y last_name
            first_name = personal_info.get('first_name', '')
            last_name = personal_info.get('last_name', '')
            nombre_completo = f"{first_name} {last_name}".strip()
            
            # Obtener email primario: primero de personal_info.primary_email, luego buscar en emails
            primary_email = personal_info.get('primary_email') or next((e.get('email_address') for e in emails if e.get('is_primary')), '')
            
            # Obtener teléfono primario
            primary_phone = next((p.get('phone_number') for p in phones if p.get('is_primary')), '')
            
            # Construir perfil_data en formato esperado por la vista
            self.perfil_data = {
                'nombre': nombre_completo if nombre_completo else 'Usuario',
                'email': primary_email,
                'telefono': primary_phone,
                'fecha_nacimiento': str(personal_info.get('date_of_birth', ''))
            }
            
            # Guardar también los datos completos para referencia
            self.profile_data_complete = profile_data
            
            self.create_form()
        else:
            # Verificar si es error de autenticación
            if result.get('auth_error') and self.on_auth_error:
                self.on_auth_error()
                return
            
            error_label = ctk.CTkLabel(
                self.scroll_frame,
                text=f"Error al cargar perfil: {result.get('message', 'Desconocido')}",
                font=("Arial", 16),
                text_color=COLORS['error_red']
            )
            error_label.pack(pady=50)
    
    def create_form(self):
        # Limpiar frame
        for widget in self.scroll_frame.winfo_children():
            widget.destroy()
        
        # Avatar section
        avatar_frame = ctk.CTkFrame(self.scroll_frame, fg_color="transparent")
        avatar_frame.pack(pady=(0, 30))
        
        # Mostrar foto directamente sin frame azul
        foto_path = os.path.join(os.path.expanduser('~'), '.predicthealth_avatar.png')
        
        if os.path.exists(foto_path):
            try:
                # Hacer la imagen circular
                avatar_img = self.make_circular_image(foto_path, 120)
                avatar_ctk = ctk.CTkImage(light_image=avatar_img, size=(120, 120))
                self.avatar_label = ctk.CTkLabel(
                    avatar_frame,
                    image=avatar_ctk,
                    text=""
                )
            except:
                # Si falla, mostrar ícono con fondo azul circular
                self.avatar_label = ctk.CTkLabel(
                    avatar_frame,
                    text="👤",
                    font=("Arial", 60),
                    text_color=COLORS['white'],
                    fg_color=COLORS['primary_blue'],
                    corner_radius=60,
                    width=120,
                    height=120
                )
        else:
            # Ícono default con fondo azul circular
            self.avatar_label = ctk.CTkLabel(
                avatar_frame,
                text="👤",
                font=("Arial", 60),
                text_color=COLORS['white'],
                fg_color=COLORS['primary_blue'],
                corner_radius=60,
                width=120,
                height=120
            )
        
        self.avatar_label.pack()
        
        # Frame para botones de foto
        self.photo_buttons_frame = ctk.CTkFrame(avatar_frame, fg_color="transparent")
        
        # Botón cambiar foto
        change_photo_btn = ctk.CTkButton(
            self.photo_buttons_frame,
            text="📷 Cambiar foto",
            width=140,
            height=30,
            font=("Arial", 11),
            fg_color=COLORS['secondary_purple'],
            hover_color=COLORS['secondary_purple_dark'],
            command=self.change_photo
        )
        change_photo_btn.pack(side="left", padx=5)
        
        # Botón eliminar foto
        delete_photo_btn = ctk.CTkButton(
            self.photo_buttons_frame,
            text="🗑️ Eliminar foto",
            width=140,
            height=30,
            font=("Arial", 11),
            fg_color=COLORS['error_red'],
            hover_color="#c0392b",
            command=self.delete_photo
        )
        delete_photo_btn.pack(side="left", padx=5)
        
        # OCULTAR inicialmente - solo mostrar en modo edición
        # NO hacer pack() aquí
        
        # Nombre del usuario
        name_label = ctk.CTkLabel(
            avatar_frame,
            text=self.perfil_data.get('nombre', 'Usuario'),
            font=("Arial", 20, "bold"),
            text_color=COLORS['gray_dark']
        )
        name_label.pack(pady=(10, 0))
        
        # Campos del formulario
        self.entries = {}
        
        # Campos editables y no editables
        self.create_field('nombre', 'Nombre Completo', editable=True)
        self.create_field('email', 'Correo Electrónico', editable=False)
        self.create_field('telefono', 'Teléfono', editable=False)
        self.create_field('fecha_nacimiento', 'Fecha de Nacimiento', editable=True)
        
        # AGREGAR ESTO (si no existe):
        # Botones de guardar/cancelar (ocultos inicialmente)
        self.button_frame = ctk.CTkFrame(self.scroll_frame, fg_color="transparent")
        
        cancel_button = ctk.CTkButton(
            self.button_frame,
            text="Cancelar",
            width=150,
            height=40,
            fg_color=COLORS['gray_medium'],
            hover_color=COLORS['gray_dark'],
            command=self.cancel_edit
        )
        cancel_button.pack(side="left", padx=10)
        
        save_button = ctk.CTkButton(
            self.button_frame,
            text="Guardar Cambios",
            width=150,
            height=40,
            fg_color=COLORS['success_green'],
            hover_color=COLORS['primary_blue'],
            command=self.save_changes
        )
        save_button.pack(side="left", padx=10)
        
        # Ocultar botones inicialmente
        self.button_frame.pack(pady=(30, 0))
        self.button_frame.pack_forget()
    
    def create_field(self, field_id, label_text, editable=True):
        # Frame del campo
        field_frame = ctk.CTkFrame(self.scroll_frame, fg_color="transparent")
        field_frame.pack(fill="x", pady=10)
        
        # Label
        label = ctk.CTkLabel(
            field_frame,
            text=label_text,
            font=("Arial", 13, "bold"),
            text_color=COLORS['gray_dark']
        )
        label.pack(anchor="w")
        
        # Entry
        value = str(self.perfil_data.get(field_id, ''))
        entry = ctk.CTkEntry(
            field_frame,
            width=500,
            height=45,
            font=("Arial", 13),
            fg_color=COLORS['gray_light'],
            border_color=COLORS['primary_blue_light']
        )
        
        # PRIMERO insertar el valor
        entry.insert(0, value)
        
        # LUEGO deshabilitar
        if not editable:
            # Campos no editables (email, teléfono) - siempre disabled
            entry.configure(state="disabled", text_color=COLORS['gray_medium'])
        else:
            # Campos editables - disabled hasta que se active el modo edición
            entry.configure(state="disabled")
        
        entry.pack(pady=(5, 0))
        
        # Guardar referencia y si es editable
        self.entries[field_id] = entry
        self.editable_fields[field_id] = editable

    def toggle_edit_mode(self):
        """Alternar entre modo edición y modo vista"""
        if not self.editing:
            # Activar modo edición
            self.editing = True
            self.edit_button.configure(
                text="❌ Cancelar",
                fg_color=COLORS['error_red'],
                hover_color=COLORS['error_red']
            )
            
            # Habilitar SOLO entries editables
            for field_id, entry in self.entries.items():
                if self.editable_fields.get(field_id, True):
                    entry.configure(state="normal", fg_color=COLORS['white'])
            
            # Mostrar botones de foto
            self.photo_buttons_frame.pack(pady=(15, 0))
            
            # Mostrar botones de guardar/cancelar
            self.button_frame.pack(pady=(30, 0))
        else:
            # Cancelar edición
            self.cancel_edit()
    
    def cancel_edit(self):
        self.editing = False
        self.edit_button.configure(
            text="✏️ Editar",
            fg_color=COLORS['secondary_purple'],
            hover_color=COLORS['secondary_purple_dark']
        )
        
        # Deshabilitar entries y restaurar valores originales
        for field_id, entry in self.entries.items():
            entry.configure(state="normal")
            entry.delete(0, 'end')
            entry.insert(0, str(self.perfil_data.get(field_id, '')))
            
            if self.editable_fields.get(field_id, True):
                entry.configure(state="disabled", fg_color=COLORS['gray_light'])
            else:
                entry.configure(state="disabled", fg_color=COLORS['gray_light'], text_color=COLORS['gray_medium'])
        
        # Ocultar botones de foto
        self.photo_buttons_frame.pack_forget()
        
        # Ocultar botones de guardar/cancelar
        self.button_frame.pack_forget()
    
    def save_changes(self):
        # Recopilar SOLO los datos que cambiaron
        new_data = {}
        for field_id, entry in self.entries.items():
            new_value = entry.get().strip()
            old_value = str(self.perfil_data.get(field_id, ''))
            
            if new_value != old_value:
                new_data[field_id] = new_value
        
        if not new_data:
            messagebox.showinfo("Info", "No hay cambios para guardar")
            self.cancel_edit()
            return
        
        # Validaciones
        if 'nombre' in new_data and not new_data['nombre']:
            messagebox.showerror("Error", "El nombre no puede estar vacío")
            return
        
        if 'email' in new_data and '@' not in new_data['email']:
            messagebox.showerror("Error", "Email inválido")
            return
        
        # Guardar cambios
        result = self.api_service.update_perfil(new_data)
        
        if result.get('success'):
            # Actualizar datos locales
            self.perfil_data.update(new_data)
            
            # Mostrar mensaje diferente si hay campos que solo se guardaron localmente
            if 'email' in new_data or 'telefono' in new_data:
                messagebox.showinfo(
                    "Éxito", 
                    "Nombre y fecha actualizados en el servidor.\nEmail y teléfono guardados localmente."
                )
            else:
                messagebox.showinfo("Éxito", "Perfil actualizado correctamente")
            
            self.cancel_edit()
            
            if 'nombre' in new_data:
                self.refresh_sidebar()
        else:
            # Verificar si es error de autenticación
            if result.get('auth_error') and self.on_auth_error:
                self.on_auth_error()
            else:
                messagebox.showerror("Error", result.get('message', 'Error al actualizar perfil'))

    def change_photo(self):
        """Cambiar foto de perfil"""
        file_path = filedialog.askopenfilename(
            title="Seleccionar foto de perfil",
            filetypes=[("Imágenes", "*.png *.jpg *.jpeg")]
        )
        
        if file_path:
            try:
                # Guardar localmente
                img = Image.open(file_path)
                save_path = os.path.join(os.path.expanduser('~'), '.predicthealth_avatar.png')
                img.save(save_path)
                
                # Actualizar UI con imagen circular
                circular_img = self.make_circular_image(save_path, 120)
                avatar_ctk = ctk.CTkImage(light_image=circular_img, size=(120, 120))
                
                # Recrear el label
                self.avatar_label.destroy()
                self.avatar_label = ctk.CTkLabel(
                    self.avatar_label.master,
                    image=avatar_ctk,
                    text=""
                )
                self.avatar_label.pack()
                
                # Actualizar sidebar
                app = self.winfo_toplevel()
                if hasattr(app, 'update_sidebar_avatar'):
                    app.update_sidebar_avatar()
                
                messagebox.showinfo("Éxito", "Foto de perfil actualizada")
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo cargar la imagen: {str(e)}")

    def delete_photo(self):
        """Eliminar foto de perfil"""
        foto_path = os.path.join(os.path.expanduser('~'), '.predicthealth_avatar.png')
        
        if os.path.exists(foto_path):
            try:
                # Eliminar archivo
                os.remove(foto_path)
                
                # Actualizar UI - recrear todo el avatar
                self.avatar_label.destroy()
                
                self.avatar_label = ctk.CTkLabel(
                    self.avatar_label.master,
                    text="👤",
                    font=("Arial", 60),
                    text_color=COLORS['white'],
                    fg_color=COLORS['primary_blue'],
                    corner_radius=60,
                    width=120,
                    height=120
                )
                self.avatar_label.pack()
                
                # Actualizar sidebar
                app = self.winfo_toplevel()
                if hasattr(app, 'update_sidebar_avatar'):
                    app.update_sidebar_avatar()
                
                messagebox.showinfo("Éxito", "Foto de perfil eliminada")
                
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo eliminar la imagen: {str(e)}")
        else:
            messagebox.showinfo("Info", "No hay foto para eliminar")

    def make_circular_image(self, image_path, size=120):
        """Convertir imagen a circular"""
        from PIL import ImageDraw
        
        # Abrir y redimensionar
        img = Image.open(image_path).convert("RGBA")
        img = img.resize((size, size))
        
        # Crear máscara circular
        mask = Image.new('L', (size, size), 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, size, size), fill=255)
        
        # Aplicar máscara
        output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        output.paste(img, (0, 0))
        output.putalpha(mask)
        
        return output
    
    def refresh_sidebar_photo(self):
        """Refrescar foto en el sidebar después de cambiar/eliminar"""
        app = self.winfo_toplevel()
        if hasattr(app, 'refresh_sidebar_avatar'):
            app.refresh_sidebar_avatar()

    def refresh_sidebar(self):
        """Refrescar el nombre en el sidebar"""
        # Buscar la ventana principal
        app = self.winfo_toplevel()
        if hasattr(app, 'update_sidebar_name'):
            app.update_sidebar_name(self.perfil_data.get('nombre', 'Usuario'))