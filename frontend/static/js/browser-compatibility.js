// /frontend\static\js\browser-compatibility.js
// /frontend/static/js/browser-compatibility.js
// Verificación de compatibilidad con navegadores para JSON

class BrowserCompatibilityChecker {
    constructor() {
        this.results = {};
        this.browserInfo = this.detectBrowser();
    }

    /**
     * Detecta información del navegador
     */
    detectBrowser() {
        const userAgent = navigator.userAgent;
        const browsers = {
            chrome: /Chrome/.test(userAgent) && /Google Inc/.test(navigator.vendor),
            firefox: /Firefox/.test(userAgent),
            safari: /Safari/.test(userAgent) && /Apple Computer/.test(navigator.vendor),
            edge: /Edg/.test(userAgent),
            ie: /Trident/.test(userAgent) || /MSIE/.test(userAgent)
        };

        const browser = Object.keys(browsers).find(b => browsers[b]) || 'unknown';
        const version = this.getBrowserVersion(userAgent, browser);

        return {
            name: browser,
            version: version,
            userAgent: userAgent,
            isModern: this.isModernBrowser(browser, version)
        };
    }

    /**
     * Obtiene versión del navegador
     */
    getBrowserVersion(userAgent, browser) {
        const versionPatterns = {
            chrome: /Chrome\/(\d+)/,
            firefox: /Firefox\/(\d+)/,
            safari: /Version\/(\d+)/,
            edge: /Edg\/(\d+)/,
            ie: /(?:MSIE |rv:)(\d+)/
        };

        const match = userAgent.match(versionPatterns[browser]);
        return match ? parseInt(match[1]) : 0;
    }

    /**
     * Determina si es un navegador moderno
     */
    isModernBrowser(browser, version) {
        const modernVersions = {
            chrome: 60,
            firefox: 55,
            safari: 12,
            edge: 79,
            ie: 0 // IE no es considerado moderno
        };

        return version >= modernVersions[browser];
    }

    /**
     * Verifica soporte JSON básico
     */
    checkJSONSupport() {
        const tests = {
            jsonParse: typeof JSON !== 'undefined' && typeof JSON.parse === 'function',
            jsonStringify: typeof JSON !== 'undefined' && typeof JSON.stringify === 'function',
            fetch: typeof fetch !== 'undefined',
            promises: typeof Promise !== 'undefined',
            arrowFunctions: (() => true)(),
            templateLiterals: `test` === 'test',
            destructuring: (() => { const {a} = {a: 1}; return a === 1; })(),
            asyncAwait: (async () => true)() instanceof Promise
        };

        this.results.jsonSupport = tests;
        return tests;
    }

    /**
     * Verifica funcionalidades específicas de JSON
     */
    checkJSONFeatures() {
        const tests = {};

        // JSON.parse con objetos complejos
        try {
            const testObj = {a: 1, b: [2, 3], c: {d: 4}};
            const jsonStr = JSON.stringify(testObj);
            const parsed = JSON.parse(jsonStr);
            tests.complexObjects = JSON.stringify(parsed) === jsonStr;
        } catch (e) {
            tests.complexObjects = false;
        }

        // JSON con caracteres especiales
        try {
            const testStr = '{"text": "áéíóú & < > \\" \'"}';
            const parsed = JSON.parse(testStr);
            const stringified = JSON.stringify(parsed);
            tests.specialChars = stringified.includes('áéíóú');
        } catch (e) {
            tests.specialChars = false;
        }

        // JSON con BigInt (si soportado)
        try {
            const bigInt = 123n;
            const stringified = JSON.stringify(bigInt);
            tests.bigInt = stringified === '"123"';
        } catch (e) {
            tests.bigInt = false;
        }

        // JSON.stringify con funciones (debe ignorar)
        try {
            const obj = {a: 1, fn: () => {}};
            const stringified = JSON.stringify(obj);
            tests.functionHandling = !stringified.includes('fn');
        } catch (e) {
            tests.functionHandling = false;
        }

        this.results.jsonFeatures = tests;
        return tests;
    }

    /**
     * Verifica rendimiento JSON
     */
    async checkJSONPerformance() {
        const tests = {};

        // Tiempo de parsing JSON pequeño
        const smallJSON = '{"test": "value", "item": "value"}';
        const startSmall = performance.now();
        try {
            JSON.parse(smallJSON);
            tests.smallJSONParsing = performance.now() - startSmall;
        } catch (e) {
            tests.smallJSONParsing = -1;
        }

        // Tiempo de parsing JSON grande
        const largeObj = { items: Array(1000).fill({ value: 'test' }) };
        const largeJSON = JSON.stringify(largeObj);
        const startLarge = performance.now();
        try {
            JSON.parse(largeJSON);
            tests.largeJSONParsing = performance.now() - startLarge;
        } catch (e) {
            tests.largeJSONParsing = -1;
        }

        // Tiempo de creación JSON
        const startCreate = performance.now();
        try {
            const jsonString = JSON.stringify({ test: 'value', items: Array(100).fill('item') });
            tests.jsonCreation = performance.now() - startCreate;
        } catch (e) {
            tests.jsonCreation = -1;
        }

        // Tiempo de stringify/parse roundtrip
        const startRoundtrip = performance.now();
        try {
            const original = { a: 1, b: [2, 3], c: { d: 4 } };
            const stringified = JSON.stringify(original);
            const parsed = JSON.parse(stringified);
            tests.jsonRoundtrip = performance.now() - startRoundtrip;
        } catch (e) {
            tests.jsonRoundtrip = -1;
        }

        this.results.jsonPerformance = tests;
        return tests;
    }

    /**
     * Verifica compatibilidad con nuestras utilidades
     */
    checkUtilityCompatibility() {
        const tests = {};

        // PredictHealthAPI (nuestra utilidad principal)
        tests.predictHealthAPI = typeof PredictHealthAPI !== 'undefined';

        // AuthManager
        tests.authManager = typeof window.AuthManager !== 'undefined';
        
        // Funciones específicas de PredictHealthAPI
        if (tests.predictHealthAPI) {
            try {
                const api = PredictHealthAPI;
                tests.apiFetchDashboard = typeof api.fetchDashboard === 'function';
                tests.apiSaveMeasurements = typeof api.saveMeasurements === 'function';
                tests.apiSaveLifestyle = typeof api.saveLifestyle === 'function';
                tests.apiLogout = typeof api.logout === 'function';
            } catch (e) {
                tests.apiMethods = false;
            }
        }
        
        // AuthManager específico (usar instancia global, no crear una nueva)
        if (tests.authManager) {
            try {
                const auth = window.AuthManager;
                tests.authManagerLogin = typeof auth.login === 'function';
                tests.authManagerLogout = typeof auth.logout === 'function';
                tests.authManagerRedirect = typeof auth.redirectToDashboard === 'function';
            } catch (e) {
                tests.authManagerMethods = false;
            }
        }

        this.results.utilityCompatibility = tests;
        return tests;
    }

    /**
     * Verifica manejo de errores JSON
     */
    checkJSONErrorHandling() {
        const tests = {};

        // JSON malformado
        try {
            JSON.parse('{invalid: json}');
            tests.malformedJSON = false; // Si no falla, hay problema
        } catch (e) {
            tests.malformedJSON = e instanceof SyntaxError;
        }

        // JSON con caracteres de escape inválidos
        try {
            JSON.parse('{"test": "\\uINVALID"}');
            tests.invalidEscape = false;
        } catch (e) {
            tests.invalidEscape = e instanceof SyntaxError;
        }

        // JSON muy grande
        try {
            const largeObj = Array(100000).fill({ data: 'test' });
            const largeJSON = JSON.stringify(largeObj);
            JSON.parse(largeJSON);
            tests.largeJSON = true; // Si no falla, está bien
        } catch (e) {
            tests.largeJSON = false;
        }

        // JSON con referencias circulares
        try {
            const circular = { self: null };
            circular.self = circular;
            JSON.stringify(circular);
            tests.circularReference = false;
        } catch (e) {
            tests.circularReference = e.message.includes('circular');
        }

        this.results.jsonErrorHandling = tests;
        return tests;
    }

    /**
     * Verifica seguridad JSON
     */
    checkJSONSecurity() {
        const tests = {};

        // JSON con prototype pollution attempt
        try {
            const maliciousJSON = '{"__proto__": {"isAdmin": true}}';
            const obj = JSON.parse(maliciousJSON);
            // Verificar si la contaminación funcionó
            tests.prototypePollution = obj.__proto__.isAdmin === undefined;
        } catch (e) {
            tests.prototypePollution = true; // Si falla, está protegido
        }

        // JSON con constructor override attempt
        try {
            const maliciousJSON = '{"constructor": {"prototype": {"isAdmin": true}}}';
            const obj = JSON.parse(maliciousJSON);
            tests.constructorOverride = {}.isAdmin === undefined;
        } catch (e) {
            tests.constructorOverride = true; // Si falla, está protegido
        }

        // JSON con funciones maliciosas
        try {
            const maliciousJSON = '{"fn": "alert(1)"}';
            const obj = JSON.parse(maliciousJSON);
            // Verificar que no se ejecute código
            tests.codeInjection = typeof obj.fn === 'string';
        } catch (e) {
            tests.codeInjection = false;
        }

        // JSON con caracteres de control
        try {
            const controlJSON = '{"test": "\\u0000\\u0001\\u0002"}';
            const obj = JSON.parse(controlJSON);
            tests.controlChars = obj.test.includes('\u0000');
        } catch (e) {
            tests.controlChars = false;
        }

        this.results.jsonSecurity = tests;
        return tests;
    }

    /**
     * Ejecuta todas las verificaciones
     */
    async runAllChecks() {
        console.log('🔍 Verificando compatibilidad con navegadores...');
        console.log(`Navegador detectado: ${this.browserInfo.name} ${this.browserInfo.version}`);

        this.checkJSONSupport();
        this.checkJSONFeatures();
        await this.checkJSONPerformance();
        this.checkUtilityCompatibility();
        this.checkJSONErrorHandling();
        this.checkJSONSecurity();

        return this.results;
    }

    /**
     * Genera reporte de compatibilidad
     */
    generateReport() {
        const report = {
            browser: this.browserInfo,
            timestamp: new Date().toISOString(),
            results: this.results,
            summary: this.generateSummary()
        };

        console.log('\n📊 REPORTE DE COMPATIBILIDAD');
        console.log('='.repeat(50));
        console.log(`Navegador: ${this.browserInfo.name} ${this.browserInfo.version}`);
        console.log(`Moderno: ${this.browserInfo.isModern ? '✅ Sí' : '❌ No'}`);
        console.log(`Compatibilidad: ${report.summary.overall}%`);
        
        if (report.summary.overall >= 90) {
            console.log('🎉 ¡Excelente compatibilidad!');
        } else if (report.summary.overall >= 70) {
            console.log('✅ Buena compatibilidad');
        } else {
            console.log('⚠️ Compatibilidad limitada');
        }

        return report;
    }

    /**
     * Genera resumen de compatibilidad
     */
    generateSummary() {
        const categories = ['jsonSupport', 'jsonFeatures', 'utilityCompatibility', 'jsonErrorHandling', 'jsonSecurity'];
        const scores = {};

        categories.forEach(category => {
            if (this.results[category]) {
                const tests = this.results[category];
                const passed = Object.values(tests).filter(Boolean).length;
                const total = Object.values(tests).length;
                scores[category] = Math.round((passed / total) * 100);
            }
        });

        const overall = Math.round(Object.values(scores).reduce((a, b) => a + b, 0) / Object.keys(scores).length);

        return {
            ...scores,
            overall
        };
    }

    /**
     * Verifica si el navegador es compatible
     */
    isCompatible() {
        const summary = this.generateSummary();
        return summary.overall >= 70;
    }

    /**
     * Obtiene recomendaciones de compatibilidad
     */
    getRecommendations() {
        const recommendations = [];
        const summary = this.generateSummary();

        if (!this.browserInfo.isModern) {
            recommendations.push('Actualizar navegador a una versión más reciente');
        }

        if (summary.jsonSupport < 80) {
            recommendations.push('El navegador tiene soporte limitado para JSON');
        }
        
        if (summary.jsonFeatures < 70) {
            recommendations.push('Algunas características JSON no están disponibles');
        }
        
        if (summary.utilityCompatibility < 90) {
            recommendations.push('Revisar carga de utilidades del frontend (API/AuthManager)');
        }
        
        if (summary.jsonSecurity < 60) {
            recommendations.push('Implementar protecciones adicionales para JSON');
        }

        return recommendations;
    }
}

// Función global para ejecutar verificación
window.checkBrowserCompatibility = async function() {
    const checker = new BrowserCompatibilityChecker();
    await checker.runAllChecks();
    const report = checker.generateReport();
    
    // Mostrar recomendaciones
    const recommendations = checker.getRecommendations();
    if (recommendations.length > 0) {
        console.log('\n💡 RECOMENDACIONES:');
        recommendations.forEach(rec => console.log(`• ${rec}`));
    }
    
    return report;
};

// Auto-ejecutar si se especifica
if (window.location.search.includes('check=browser')) {
    document.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            console.log('🔍 Auto-ejecutando verificación de compatibilidad...');
            window.checkBrowserCompatibility();
        }, 2000);
    });
}

// Exportar para uso en módulos
if (typeof module !== 'undefined' && module.exports) {
    module.exports = BrowserCompatibilityChecker;
}
