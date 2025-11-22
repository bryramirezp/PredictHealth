# views/dashboard.py - Dashboard con 6 gráficas de salud

import customtkinter as ctk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
from typing import Optional, Dict, Any
from datetime import datetime
from config import COLORS

class DashboardView(ctk.CTkFrame):
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
            text="📊 Dashboard de Salud",
            font=("Arial", 24, "bold"),
            text_color=COLORS['white']
        )
        title.pack(side="left", padx=20, pady=20)
        
        # Nombre del usuario
        if self.api_service.user_data:
            user_label = ctk.CTkLabel(
                header,
                text=f"Bienvenido, {self.api_service.user_data.get('nombre', '')}",
                font=("Arial", 14),
                text_color=COLORS['white']
            )
            user_label.pack(side="right", padx=20)
        
        # Frame para cards de métricas
        self.metrics_frame = ctk.CTkFrame(self, fg_color=COLORS['gray_light'])
        self.metrics_frame.pack(fill="x", padx=20, pady=(0, 10))
        
        for i in range(4):
            self.metrics_frame.grid_columnconfigure(i, weight=1)
        
        # Scrollable frame para las gráficas
        self.scroll_frame = ctk.CTkScrollableFrame(
            self,
            fg_color=COLORS['gray_light']
        )
        self.scroll_frame.pack(fill="both", expand=True, padx=20, pady=(0, 20))
        
        # Grid para las gráficas (2 columnas x 3 filas)
        self.scroll_frame.grid_columnconfigure(0, weight=1)
        self.scroll_frame.grid_columnconfigure(1, weight=1)
        
    def load_data(self):
        """Cargar datos del dashboard"""
        result = self.api_service.get_estadisticas()
        print(f"📊 Resultado get_estadisticas: {result}")
        if result.get('success'):
            data = result['data']
            print(f"📊 Data recibida: {data}")
            dashboard_data = self.prepare_chart_data(data)
            print(f"📊 Dashboard data preparada: {dashboard_data}")
            self.create_charts(dashboard_data)
        else:
            error_label = ctk.CTkLabel(
                self.scroll_frame,
                text=f"Error al cargar datos: {result.get('message', 'Desconocido')}",
                font=("Arial", 16),
                text_color=COLORS['error_red']
            )
            error_label.pack(pady=50)
    
    def create_chart_frame(self, data, title, row, col, plot_function):
        # Frame contenedor
        frame = ctk.CTkFrame(
            self.scroll_frame,
            fg_color=COLORS['white'],
            corner_radius=10
        )
        frame.grid(row=row, column=col, padx=10, pady=10, sticky="nsew")
        
        # Título de la gráfica
        title_label = ctk.CTkLabel(
            frame,
            text=title,
            font=("Arial", 14, "bold"),
            text_color=COLORS['gray_dark']
        )
        title_label.pack(pady=(15, 5))
        
        # Crear figura de matplotlib
        fig = Figure(figsize=(5, 3.5), dpi=80, facecolor='white')
        ax = fig.add_subplot(111)
        
        # Llamar a la función de ploteo correspondiente
        plot_function(ax, data)
        
        # Ajustar layout
        fig.tight_layout(pad=2)
        
        # Integrar en tkinter
        canvas = FigureCanvasTkAgg(fig, master=frame)
        canvas.draw()
        canvas.get_tk_widget().pack(fill="both", expand=True, padx=10, pady=(0, 10))
    
    def plot_presion_arterial(self, ax, data):
        ax.plot(data['fechas'], data['sistolica'], 
                marker='o', linewidth=2, color=COLORS['error_red'], label='Sistólica')
        ax.plot(data['fechas'], data['diastolica'], 
                marker='o', linewidth=2, color=COLORS['primary_blue'], label='Diastólica')
        ax.set_ylabel('mmHg', fontsize=10)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(60, 140)
    
    def plot_frecuencia_cardiaca(self, ax, data):
        ax.plot(data['fechas'], data['valores'], 
                marker='o', linewidth=2, color=COLORS['secondary_purple'])
        ax.fill_between(range(len(data['valores'])), data['valores'], alpha=0.3, color=COLORS['secondary_purple_light'])
        ax.set_ylabel('BPM', fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(60, 90)
    
    def plot_peso(self, ax, data):
        colors_bar = [COLORS['primary_blue'], COLORS['primary_blue_dark']]
        bars = ax.bar(data['fechas'], data['valores'], color=colors_bar, width=0.6)
        ax.set_ylabel('Kg', fontsize=10)
        ax.grid(True, alpha=0.3, axis='y')
        ax.set_ylim(65, 75)
        
        # Agregar valores encima de las barras
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                    f'{height:.1f}',
                    ha='center', va='bottom', fontsize=9)
    
    def plot_actividad(self, ax, data):
        colors_gradient = [COLORS['success_green'] if p >= 8000 else COLORS['warning_yellow'] for p in data['pasos']]
        ax.bar(data['dias'], data['pasos'], color=colors_gradient, width=0.7)
        ax.axhline(y=10000, color=COLORS['error_red'], linestyle='--', linewidth=1, alpha=0.7, label='Meta: 10k')
        ax.set_ylabel('Pasos', fontsize=10)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3, axis='y')
    
    def plot_sueno(self, ax, data):
        colors_gradient = [COLORS['primary_blue'] if h >= 7 else COLORS['warning_yellow'] for h in data['horas']]
        ax.bar(data['dias'], data['horas'], color=colors_gradient, width=0.7)
        ax.axhline(y=8, color=COLORS['success_green'], linestyle='--', linewidth=1, alpha=0.7, label='Óptimo: 8h')
        ax.set_ylabel('Horas', fontsize=10)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3, axis='y')
        ax.set_ylim(0, 10)
    
    def plot_citas(self, ax, data):
        ax.plot(data['meses'], data['cantidad'], 
                marker='s', linewidth=2.5, markersize=8, 
                color=COLORS['secondary_purple'])
        ax.fill_between(range(len(data['cantidad'])), data['cantidad'], 
                        alpha=0.2, color=COLORS['secondary_purple_light'])
        ax.set_ylabel('Cantidad', fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(0, 5)
        
        # Agregar valores en los puntos
        for i, v in enumerate(data['cantidad']):
            ax.text(i, v + 0.2, str(v), ha='center', fontsize=9)
    
    def refresh_data(self):
        """Refrescar las gráficas"""
        # Limpiar el scroll frame
        for widget in self.scroll_frame.winfo_children():
            widget.destroy()
        
        # Recargar datos
        self.load_data()

    def create_metric_card(self, parent, titulo, valor, estado, color, col):
        """Crear card de métrica"""
        card = ctk.CTkFrame(parent, fg_color=COLORS['white'], corner_radius=10)
        card.grid(row=0, column=col, padx=5, pady=5, sticky="nsew")
        
        title_label = ctk.CTkLabel(
            card,
            text=titulo,
            font=("Arial", 11),
            text_color=COLORS['gray_medium']
        )
        title_label.pack(pady=(15, 5))
        
        value_label = ctk.CTkLabel(
            card,
            text=valor,
            font=("Arial", 20, "bold"),
            text_color=COLORS['gray_dark']
        )
        value_label.pack()
        
        badge = ctk.CTkLabel(
            card,
            text=estado,
            font=("Arial", 10, "bold"),
            text_color=COLORS['white'],
            fg_color=color,
            corner_radius=5,
            padx=10,
            pady=3
        )
        badge.pack(pady=(5, 15))

    def prepare_chart_data(self, real_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convierte datos reales del backend a formato para gráficas"""
        from datetime import datetime
        
        # Datos que SÍ existen y funcionan
        conditions = real_data.get('conditions', [])
        medications = real_data.get('medications', [])
        
        # Timeline de diagnósticos
        timeline_diagnosticos = []
        for cond in conditions:
            if cond.get('diagnosis_date'):
                timeline_diagnosticos.append({
                    'nombre': cond.get('name', 'Sin nombre'),
                    'fecha': cond.get('diagnosis_date'),
                    'notas': cond.get('notes', '')
                })
        timeline_diagnosticos.sort(key=lambda x: x['fecha'] if x['fecha'] else '9999-12-31')
        
        # Medicamentos activos
        medicamentos_activos = []
        for med in medications:
            medicamentos_activos.append({
                'nombre': med.get('name', 'Sin nombre'),
                'dosis': med.get('dosage', 'N/D'),
                'frecuencia': med.get('frequency', 'N/D'),
                'inicio': med.get('start_date', 'N/D')
            })
        
        # Historial de citas (desde JSON local)
        citas_result = self.api_service.get_citas()
        citas_por_mes = {}
        
        if citas_result.get('success'):
            citas = citas_result['data']
            for cita in citas:
                try:
                    fecha = datetime.strptime(cita.get('fecha'), '%Y-%m-%d')
                    mes_key = fecha.strftime('%Y-%m')
                    citas_por_mes[mes_key] = citas_por_mes.get(mes_key, 0) + 1
                except:
                    pass
        
        meses_ordenados = sorted(citas_por_mes.keys())[-6:]
        meses_labels = [datetime.strptime(m, '%Y-%m').strftime('%b') for m in meses_ordenados]
        cantidades = [citas_por_mes[m] for m in meses_ordenados]
        
        return {
            'age': real_data.get('age', 0),
            'bmi': real_data.get('bmi', 0),
            'bmi_classification': real_data.get('bmi_classification', 'Desconocido'),
            'health_score': real_data.get('health_score', 0),
            'timeline_diagnosticos': timeline_diagnosticos,
            'medicamentos_activos': medicamentos_activos,
            'citas_por_mes': {
                'meses': meses_labels if meses_labels else ['Nov'],
                'cantidad': cantidades if cantidades else [3]
            },
            'total_conditions': len(conditions),
            'total_medications': len(medications)
        }


    def update_metric_cards(self, data):
        """Actualizar cards con datos reales del dashboard"""
        # Limpiar cards anteriores
        for widget in self.metrics_frame.winfo_children():
            widget.destroy()
        
        # Obtener datos reales
        edad = data.get('age', 0)
        bmi = data.get('bmi', 0)
        bmi_class = data.get('bmi_classification', 'Desconocido')
        health_score = data.get('health_score', 0)
        
        # Determinar color del health score
        if health_score >= 80:
            score_color = COLORS['success_green']
            score_text = "Excelente"
        elif health_score >= 60:
            score_color = COLORS['primary_blue']
            score_text = "Bueno"
        elif health_score >= 40:
            score_color = COLORS['warning_yellow']
            score_text = "Regular"
        else:
            score_color = COLORS['error_red']
            score_text = "Atención"
        
        # Determinar color del BMI
        if 'Normal' in bmi_class or '✅' in bmi_class:
            bmi_color = COLORS['success_green']
        elif 'Sobrepeso' in bmi_class or '🟠' in bmi_class:
            bmi_color = COLORS['warning_yellow']
        else:
            bmi_color = COLORS['error_red']
        
        # Card 1: Edad
        self.create_metric_card(
            self.metrics_frame, 
            "🎂 Edad", 
            f"{edad} años" if edad else "N/D",
            "Tu edad actual",
            COLORS['primary_blue'],
            0
        )
        
        # Card 2: IMC
        self.create_metric_card(
            self.metrics_frame,
            "⚖️ IMC",
            f"{bmi}" if bmi else "N/D",
            bmi_class if bmi else "Sin datos",
            bmi_color,
            1
        )
        
        # Card 3: Puntuación de Salud
        self.create_metric_card(
            self.metrics_frame,
            "💪 Salud",
            f"{health_score}/100" if health_score else "N/D",
            score_text,
            score_color,
            2
        )
        
        # Card 4: Próxima Cita
        proxima_cita_result = self.api_service.get_proxima_cita()
        
        if proxima_cita_result.get('success') and proxima_cita_result.get('data'):
            cita = proxima_cita_result['data']
            
            # Parsear fecha
            try:
                from datetime import datetime
                fecha_obj = datetime.strptime(cita.get('fecha'), '%Y-%m-%d')
                dias_restantes = (fecha_obj - datetime.now()).days
                
                fecha_texto = fecha_obj.strftime('%d %b')
                
                if dias_restantes == 0:
                    subtexto = "Hoy"
                    color = COLORS['error_red']
                elif dias_restantes == 1:
                    subtexto = "Mañana"
                    color = COLORS['warning_yellow']
                elif dias_restantes <= 7:
                    subtexto = f"En {dias_restantes} días"
                    color = COLORS['warning_yellow']
                else:
                    subtexto = f"En {dias_restantes} días"
                    color = COLORS['success_green']
            except:
                fecha_texto = "Cita programada"
                subtexto = cita.get('fecha', '')
                color = COLORS['primary_blue']
        else:
            fecha_texto = "Sin citas"
            subtexto = "Agenda tu consulta"
            color = COLORS['gray_medium']
        
        self.create_metric_card(
            self.metrics_frame,
            "📅 Próxima Cita",
            fecha_texto,
            subtexto,
            color,
            3
        )
    
    def create_charts(self, data):
        # Actualizar cards con datos reales
        self.update_metric_cards(data)
        
        # Configurar estilo de matplotlib
        plt.style.use('default')
        
        # 1. Timeline de Diagnósticos
        self.create_chart_frame(
            data.get('timeline_diagnosticos', []),
            "Timeline de Diagnósticos",
            0, 0,
            self.plot_timeline_diagnosticos
        )
        
        # 2. Medicamentos Activos
        self.create_chart_frame(
            data.get('medicamentos_activos', []),
            "Medicamentos Activos",
            0, 1,
            self.plot_medicamentos_activos
        )
        
        # 3. Historial de Citas
        self.create_chart_frame(
            data.get('citas_por_mes', {}),
            "Historial de Citas por Mes",
            1, 0,
            self.plot_citas_mensuales
        )
        
        # 4. Resumen de Salud
        self.create_chart_frame(
            data,
            "Resumen de Salud",
            1, 1,
            self.plot_resumen_salud
        )
        
        # 5 y 6: Cards adicionales
        self.create_summary_cards(data)
    
    def plot_timeline_diagnosticos(self, ax, data):
        """Timeline de diagnósticos"""
        if not data:
            ax.text(0.5, 0.5, 'No hay diagnósticos registrados', 
                   ha='center', va='center', fontsize=12, color=COLORS['gray_medium'])
            ax.axis('off')
            return
        
        nombres = [d['nombre'][:30] for d in data]
        y_positions = range(len(nombres))
        
        ax.barh(y_positions, [1]*len(nombres), color=COLORS['primary_blue'], alpha=0.7)
        ax.set_yticks(y_positions)
        ax.set_yticklabels(nombres, fontsize=9)
        ax.set_xlabel('Diagnósticos')
        
        for i, d in enumerate(data):
            if d['fecha']:
                try:
                    fecha = datetime.strptime(d['fecha'], '%Y-%m-%d')
                    ax.text(0.5, i, fecha.strftime('%Y-%m-%d'), 
                           va='center', ha='center', fontsize=8, color='white', weight='bold')
                except:
                    pass
        
        ax.set_xlim(0, 1)
        ax.set_xticks([])
        ax.grid(axis='y', alpha=0.3)
    
    def plot_medicamentos_activos(self, ax, data):
        """Lista de medicamentos"""
        if not data:
            ax.text(0.5, 0.5, 'No hay medicamentos registrados', 
                   ha='center', va='center', fontsize=12, color=COLORS['gray_medium'])
            ax.axis('off')
            return
        
        ax.axis('off')
        ax.text(0.5, 0.95, 'Medicamentos Activos', 
               ha='center', va='top', fontsize=12, weight='bold')
        
        y_start = 0.85
        y_step = 0.15
        
        for i, med in enumerate(data[:6]):
            y_pos = y_start - (i * y_step)
            ax.text(0.05, y_pos, f"💊 {med['nombre']}", 
                   ha='left', va='top', fontsize=10, weight='bold')
            ax.text(0.05, y_pos - 0.04, f"{med['dosis']} - {med['frecuencia']}", 
                   ha='left', va='top', fontsize=8, color=COLORS['gray_medium'])
            if med['inicio'] != 'N/D':
                ax.text(0.95, y_pos, f"Desde: {med['inicio']}", 
                       ha='right', va='top', fontsize=8, color=COLORS['primary_blue'])
        
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
    
    def plot_citas_mensuales(self, ax, data):
        """Citas por mes"""
        meses = data.get('meses', ['Nov'])
        cantidad = data.get('cantidad', [3])
        
        if sum(cantidad) == 0:
            ax.text(0.5, 0.5, 'No hay citas registradas', 
                   ha='center', va='center', fontsize=12, color=COLORS['gray_medium'])
            ax.axis('off')
            return
        
        bars = ax.bar(meses, cantidad, color=COLORS['primary_blue'], alpha=0.7)
        
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{int(height)}',
                   ha='center', va='bottom', fontsize=9, weight='bold')
        
        ax.set_xlabel('Mes')
        ax.set_ylabel('Número de Citas')
        ax.grid(axis='y', alpha=0.3)
    
    def plot_resumen_salud(self, ax, data):
        """Resumen de salud"""
        categorias = ['Condiciones', 'Medicamentos']
        valores = [data.get('total_conditions', 0), data.get('total_medications', 0)]
        colors = [COLORS['error_red'], COLORS['warning_yellow']]
        
        bars = ax.bar(categorias, valores, color=colors, alpha=0.7)
        
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{int(height)}',
                   ha='center', va='bottom', fontsize=12, weight='bold')
        
        ax.set_ylabel('Cantidad')
        ax.set_title('Estado Actual de Salud', fontsize=12, weight='bold', pad=10)
        ax.grid(axis='y', alpha=0.3)
    
    def create_summary_cards(self, data):
        """Cards de resumen"""
        cards_frame = ctk.CTkFrame(self.scroll_frame, fg_color=COLORS['gray_light'])
        cards_frame.grid(row=2, column=0, columnspan=2, sticky="ew", pady=20)
        
        cards_frame.grid_columnconfigure(0, weight=1)
        cards_frame.grid_columnconfigure(1, weight=1)
        
        # Card Condiciones
        self.create_summary_card(
            cards_frame, "🏥 Condiciones", str(data.get('total_conditions', 0)),
            "Diagnosticadas", COLORS['error_red'] if data.get('total_conditions', 0) > 0 else COLORS['success_green'], 0
        )
        
        # Card Medicamentos
        self.create_summary_card(
            cards_frame, "💊 Medicamentos", str(data.get('total_medications', 0)),
            "En tratamiento", COLORS['warning_yellow'] if data.get('total_medications', 0) > 0 else COLORS['success_green'], 1
        )
    
    def create_summary_card(self, parent, title, value, subtitle, color, col):
        """Crear card de resumen"""
        card = ctk.CTkFrame(parent, fg_color=COLORS['white'], corner_radius=10)
        card.grid(row=0, column=col, sticky="ew", padx=10, pady=10)
        
        ctk.CTkLabel(card, text=title, font=("Arial", 14, "bold"), text_color=COLORS['gray_dark']).pack(pady=(20, 5))
        ctk.CTkLabel(card, text=value, font=("Arial", 36, "bold"), text_color=color).pack(pady=5)
        ctk.CTkLabel(card, text=subtitle, font=("Arial", 11), text_color=COLORS['gray_medium']).pack(pady=(5, 20))