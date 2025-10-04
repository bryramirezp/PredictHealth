# /backend-flask\app\utils\client_detector.py
# /backend-flask/app/utils/client_detector.py
# Detector de tipo de cliente (web vs móvil)

from flask import request
from typing import Literal

ClientType = Literal['web', 'mobile', 'unknown']

class ClientDetector:
    """Detector para identificar el tipo de cliente que hace la petición"""
    
    # Indicadores de dispositivos móviles
    MOBILE_USER_AGENTS = [
        'android', 'iphone', 'ipad', 'ipod', 'blackberry', 
        'windows phone', 'mobile', 'opera mini', 'opera mobi',
        'kindle', 'silk', 'mobile safari', 'mobile chrome'
    ]
    
    # Indicadores de aplicaciones móviles específicas
    MOBILE_APP_INDICATORS = [
        'predicthealth-mobile', 'android-app', 'ios-app',
        'mobile-app', 'native-app'
    ]
    
    @classmethod
    def detect_client_type(cls, request_obj=None) -> ClientType:
        """
        Detecta el tipo de cliente basado en headers y user agent
        
        Args:
            request_obj: Objeto request de Flask (opcional, usa el global si no se proporciona)
            
        Returns:
            ClientType: 'web', 'mobile', o 'unknown'
        """
        if request_obj is None:
            request_obj = request
            
        # 1. Verificar header personalizado X-Client-Type
        client_type_header = request_obj.headers.get('X-Client-Type', '').lower()
        if client_type_header in ['web', 'mobile']:
            return client_type_header
        
        # 2. Verificar header X-Requested-With para apps móviles
        requested_with = request_obj.headers.get('X-Requested-With', '').lower()
        if 'xmlhttprequest' in requested_with:
            # Es AJAX, verificar si es de app móvil
            user_agent = request_obj.headers.get('User-Agent', '').lower()
            if any(indicator in user_agent for indicator in cls.MOBILE_APP_INDICATORS):
                return 'mobile'
        
        # 3. Verificar User-Agent para dispositivos móviles
        user_agent = request_obj.headers.get('User-Agent', '').lower()
        if any(agent in user_agent for agent in cls.MOBILE_USER_AGENTS):
            return 'mobile'
        
        # 4. Verificar header Accept para preferencias de contenido
        accept_header = request_obj.headers.get('Accept', '').lower()
        if 'application/json' in accept_header:
            return 'web'  # Prefiere JSON, probablemente web
        
        # 5. Verificar si viene de una app móvil por el referer o origin
        referer = request_obj.headers.get('Referer', '').lower()
        origin = request_obj.headers.get('Origin', '').lower()
        
        if any(indicator in referer or indicator in origin 
               for indicator in cls.MOBILE_APP_INDICATORS):
            return 'mobile'
        
        # Por defecto, asumir que es web
        return 'web'
    
    @classmethod
    def is_mobile_client(cls, request_obj=None) -> bool:
        """Verifica si el cliente es móvil"""
        return cls.detect_client_type(request_obj) == 'mobile'
    
    @classmethod
    def is_web_client(cls, request_obj=None) -> bool:
        """Verifica si el cliente es web"""
        return cls.detect_client_type(request_obj) == 'web'
    
    @classmethod
    def get_client_info(cls, request_obj=None) -> dict:
        """
        Obtiene información detallada del cliente
        
        Returns:
            dict: Información del cliente
        """
        if request_obj is None:
            request_obj = request
            
        client_type = cls.detect_client_type(request_obj)
        user_agent = request_obj.headers.get('User-Agent', '')
        
        info = {
            'type': client_type,
            'user_agent': user_agent,
            'is_mobile': client_type == 'mobile',
            'is_web': client_type == 'web',
            'headers': {
                'x_client_type': request_obj.headers.get('X-Client-Type'),
                'x_requested_with': request_obj.headers.get('X-Requested-With'),
                'accept': request_obj.headers.get('Accept'),
                'referer': request_obj.headers.get('Referer'),
                'origin': request_obj.headers.get('Origin')
            }
        }
        
        # Detectar características específicas
        if client_type == 'mobile':
            info['mobile_features'] = cls._detect_mobile_features(user_agent)
        
        return info
    
    @classmethod
    def _detect_mobile_features(cls, user_agent: str) -> dict:
        """Detecta características específicas del dispositivo móvil"""
        user_agent_lower = user_agent.lower()
        
        features = {
            'platform': 'unknown',
            'is_app': False,
            'is_browser': True
        }
        
        # Detectar plataforma
        if 'android' in user_agent_lower:
            features['platform'] = 'android'
        elif 'iphone' in user_agent_lower or 'ipad' in user_agent_lower:
            features['platform'] = 'ios'
        elif 'windows phone' in user_agent_lower:
            features['platform'] = 'windows'
        
        # Detectar si es app nativa
        if any(indicator in user_agent_lower for indicator in cls.MOBILE_APP_INDICATORS):
            features['is_app'] = True
            features['is_browser'] = False
        
        return features

# Funciones de conveniencia para uso directo
def detect_client_type(request_obj=None) -> ClientType:
    """Función de conveniencia para detectar tipo de cliente"""
    return ClientDetector.detect_client_type(request_obj)

def is_mobile_client(request_obj=None) -> bool:
    """Función de conveniencia para verificar si es móvil"""
    return ClientDetector.is_mobile_client(request_obj)

def is_web_client(request_obj=None) -> bool:
    """Función de conveniencia para verificar si es web"""
    return ClientDetector.is_web_client(request_obj)

def get_client_info(request_obj=None) -> dict:
    """Función de conveniencia para obtener información del cliente"""
    return ClientDetector.get_client_info(request_obj)
