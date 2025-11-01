# common/reporting.py

import os
import json
import time
import csv
from locust import events
from locust.runners import Runner, MasterRunner, WorkerRunner

# Importar las clases de usuario es necesario para poder modificarlas en el evento init
from .users import DoctorUser, PatientUser, InstitutionUser

# --- Configuración Específica de Reportes ---
REPORT_CONFIG = {
    "html_report_file": "predicthealth_custom_report.html",
    "csv_report_file": "predicthealth_detailed_data.csv"
}

# --- Almacén de Datos Global para este Módulo ---
test_data = {
    "start_time": 0.0, "end_time": 0.0, "request_details": [], "user_counts": [],
    "target_users": 0
}

# --- Listeners de Eventos (Corregidos y Finales) ---

@events.init.add_listener
def on_locust_init(environment, **kwargs):
    """
    Se dispara al iniciar Locust. Lee las variables de entorno y asigna el 
    número exacto de usuarios a cada clase antes de que la prueba comience.
    """
    if isinstance(environment.runner, WorkerRunner):
        return

    print("✅ Applying fixed user counts from environment variables...")
    DoctorUser.fixed_count = int(os.environ.get("DOCTORS", 0))
    PatientUser.fixed_count = int(os.environ.get("PATIENTS", 0))
    InstitutionUser.fixed_count = int(os.environ.get("INSTITUTIONS", 0))

@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """
    Se ejecuta al inicio de la prueba. Resetea los datos y lanza el 'ticker'
    para registrar el número de usuarios.
    """
    test_data["start_time"] = time.time()
    test_data["request_details"], test_data["user_counts"] = [], []
    
    if environment.runner:
        if environment.shape_class:
            test_data["target_users"] = "Shape"
        else:
            test_data["target_users"] = environment.runner.target_user_count

        def ticker(runner: Runner):
            while runner.state not in ("stopped", "stopping", "cleanup"):
                test_data["user_counts"].append((time.time(), runner.user_count))
                time.sleep(1)
        
        environment.runner.greenlet.spawn(ticker, environment.runner)
        
    print("🚀 Starting Load Test...")

@events.request.add_listener
def on_request(name, response_time, response_length, exception, **kwargs):
    test_data["request_details"].append({"timestamp": time.time(), "endpoint": name, "response_time_ms": response_time, "success": 1 if not exception else 0})

@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    print("\n🏁 Load Test Completed. Generating reports...")
    test_data["end_time"] = time.time()
    processed_data = process_final_data()
    generate_html_report(processed_data)
    generate_csv_report(processed_data)

# --- (El resto del código de procesamiento y generación de reportes se mantiene igual) ---
def process_final_data():
    start_ts = test_data["start_time"]
    duration_secs = int(test_data["end_time"] - start_ts)
    if duration_secs <= 0: return None
    time_bins = {sec: {"s": 0, "f": 0, "rt": []} for sec in range(duration_secs + 1)}
    for req in test_data["request_details"]:
        bin_key = int(req["timestamp"] - start_ts)
        if bin_key in time_bins:
            if req["success"]: time_bins[bin_key]["s"] += 1
            else: time_bins[bin_key]["f"] += 1
            time_bins[bin_key]["rt"].append(req["response_time_ms"])
    charts = {"rt": [],"rps": [],"s_cum": [],"f_cum": [],"users": []}
    total_s, total_f = 0, 0
    for sec, data in sorted(time_bins.items()):
        avg_rt = sum(data["rt"]) / len(data["rt"]) if data["rt"] else 0
        total_s, total_f = total_s + data["s"], total_f + data["f"]
        charts["rt"].append({"x": sec, "y": avg_rt})
        charts["rps"].append({"x": sec, "y": data["s"] + data["f"]})
        charts["s_cum"].append({"x": sec, "y": total_s})
        charts["f_cum"].append({"x": sec, "y": total_f})
    if test_data["user_counts"]:
        charts["users"] = [{"x": ts - start_ts, "y": count} for ts, count in test_data["user_counts"]]
    total_reqs = len(test_data["request_details"])
    summary = {"avg_rt": sum(r["response_time_ms"] for r in test_data["request_details"]) / total_reqs if total_reqs else 0,"err_pct": (sum(1 for r in test_data["request_details"] if not r["success"]) / total_reqs * 100) if total_reqs else 0,"avg_rps": total_reqs / duration_secs if duration_secs > 0 else 0, "max_users": test_data["target_users"]}
    return {"summary": summary, "charts": charts, "raw": test_data["request_details"]}
def generate_html_report(processed_data):
    if not processed_data: return
    with open(REPORT_CONFIG["html_report_file"], 'w', encoding='utf-8') as f: f.write(f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>PredictHealth Custom Report</title><script src="https://cdn.jsdelivr.net/npm/chart.js/dist/chart.umd.min.js"></script><style>body{{font-family:sans-serif;margin:20px;background-color:#f4f4f4}} .container{{max-width:1200px;margin:auto;background:white;padding:25px;border-radius:8px;box-shadow:0 0 15px rgba(0,0,0,0.1)}} h1,h2{{text-align:center;color:#333}} .chart-container{{margin-top:40px;padding:20px;border:1px solid #ddd;border-radius:5px}}</style></head><body><div class="container"><h1>Resultados del Test de Carga</h1><h2>Gráficas generadas por Locust:</h2><div class="chart-container"><h3>Response times over time</h3><canvas id="c1"></canvas></div><div class="chart-container"><h3>Users vs RPS</h3><canvas id="c2"></canvas></div><div class="chart-container"><h3>Success vs RPS</h3><canvas id="c3"></canvas></div><div class="chart-container"><h3>Failures over time</h3><canvas id="c4"></canvas></div></div><script>
const opts2=(x,y1,y2)=>({{animation:false,scales:{{x:{{type:'linear',title:{{display:true,text:x}}}},y1:{{type:'linear',position:'left',title:{{display:true,text:y1}}}},y2:{{type:'linear',position:'right',title:{{display:true,text:y2}},grid:{{drawOnChartArea:false}}}}}}}});
const createChart=(ctx,type,datasets,options)=>{{new Chart(ctx,{{type,data:{{datasets}},options}});}};
createChart('c1','line',[{{label:'Avg Response Time (ms)',data:{json.dumps(processed_data['charts']['rt'])},borderColor:'blue',pointRadius:0,borderWidth:2}}],{{animation:false,scales:{{x:{{type:'linear',title:{{display:true,text:'Time (seconds)'}}}},y:{{title:{{display:true,text:'Response Time (ms)'}}}}}}}});
createChart('c2','line',[{{label:'Active Users',data:{json.dumps(processed_data['charts']['users'])},borderColor:'green',yAxisID:'y1',stepped:true,borderWidth:2}},{{label:'RPS',data:{json.dumps(processed_data['charts']['rps'])},borderColor:'red',yAxisID:'y2',pointRadius:0,borderWidth:2}}],opts2('Time (seconds)','Users','RPS'));
createChart('c3','line',[{{label:'Cumulative Success',data:{json.dumps(processed_data['charts']['s_cum'])},borderColor:'teal',yAxisID:'y1',pointRadius:0,borderWidth:2}},{{label:'RPS',data:{json.dumps(processed_data['charts']['rps'])},borderColor:'red',yAxisID:'y2',pointRadius:0,borderWidth:2}}],opts2('Time (seconds)','Success Count','RPS'));
createChart('c4','line',[{{label:'Cumulative Failures',data:{json.dumps(processed_data['charts']['f_cum'])},borderColor:'orange',pointRadius:0,borderWidth:2}}],{{animation:false,scales:{{x:{{type:'linear',title:{{display:true,text:'Time (seconds)'}}}}}}}});
</script></body></html>""")
def generate_csv_report(processed_data):
    if not processed_data: return
    with open(REPORT_CONFIG["csv_report_file"], 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['Resultados - Tablas comparativas de métricas clave'])
        writer.writerow(['Métrica', 'Valor'])
        writer.writerow(['Tiempo promedio de respuesta (ms)', f"{{processed_data['summary']['avg_rt']:.2f}}"])
        writer.writerow(['Tasa de errores (%)', f"{{processed_data['summary']['err_pct']:.2f}}"])
        writer.writerow(['Requests por segundo (RPS)', f"{{processed_data['summary']['avg_rps']:.2f}}"])
        writer.writerow(['Usuarios concurrentes máximos soportados', processed_data['summary']['max_users']])
        writer.writerow([])
        writer.writerow(['Datos para Gráficas - Todas las Peticiones Registradas'])
        if processed_data['raw']:
            dict_writer = csv.DictWriter(f, fieldnames=processed_data['raw'][0].keys())
            dict_writer.writeheader()
            dict_writer.writerows(processed_data['raw'])