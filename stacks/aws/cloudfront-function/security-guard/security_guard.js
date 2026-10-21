// CloudFront Function: security_guard
// Runtime: cloudfront-js-2.0
// Event Type: viewer-request

// 1. 常见敏感路径/目录扫描拦截（转小写后前缀匹配）
var BLOCKED_PATH_PREFIXES = [
    '/.env',
    '/.git',
    '/.svn',
    '/.hg',
    '/.aws',
    '/.config',
    '/wp-admin',
    '/wp-login',
    '/wp-includes',
    '/wp-content',
    '/phpmyadmin',
    '/pma',
    '/adminer',
    '/actuator',
    '/swagger',
    '/api-docs',
    '/solr',
    '/console',
    '/telescope',
    '/owa',
    '/webmail'
];

// 2. 常见备份/敏感文件后缀拦截
var BLOCKED_EXTENSIONS = [
    '.bak',
    '.backup',
    '.old',
    '.swp',
    '.sql',
    '.dump',
    '.tar',
    '.tar.gz',
    '.tgz',
    '.zip',
    '.7z',
    '.rar',
    '.ini',
    '.cfg',
    '.yaml',
    '.yml',
    '.log'
];

// 3. 常见恶意扫描器 / 漏洞挖掘工具 User-Agent（包含匹配，转小写）
var BLOCKED_USER_AGENTS = [
    'sqlmap',
    'nikto',
    'acunetix',
    'nmap',
    'masscan',
    'zgrab',
    'dirbuster',
    'gobuster',
    'wprecon',
    'wpscan',
    'hydra',
    'medusa',
    'burpsuite',
    'nuclei',
    'havij'
];

// 4. 允许的 HTTP 方法
var ALLOWED_METHODS = ['GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'];

function handler(event) {
    var request = event.request;
    var uri = request.uri.toLowerCase();
    var method = request.method;

    // 检查 1: HTTP Method 检查
    if (!ALLOWED_METHODS.includes(method)) {
        return blockResponse(405, 'Method Not Allowed');
    }

    // 检查 2: 敏感路径拦截
    for (var i = 0; i < BLOCKED_PATH_PREFIXES.length; i++) {
        if (uri.startsWith(BLOCKED_PATH_PREFIXES[i])) {
            return blockResponse(403, 'Forbidden');
        }
    }

    // 检查 3: 敏感扩展名拦截
    for (var j = 0; j < BLOCKED_EXTENSIONS.length; j++) {
        if (uri.endsWith(BLOCKED_EXTENSIONS[j])) {
            return blockResponse(403, 'Forbidden');
        }
    }

    // 检查 4: User-Agent 检查（拦截缺失/空 UA 以及恶意扫描器）
    if (!request.headers['user-agent'] || !request.headers['user-agent'].value || request.headers['user-agent'].value.trim() === '') {
        return blockResponse(403, 'Forbidden');
    }

    var ua = request.headers['user-agent'].value.toLowerCase();
    for (var k = 0; k < BLOCKED_USER_AGENTS.length; k++) {
        if (ua.includes(BLOCKED_USER_AGENTS[k])) {
            return blockResponse(403, 'Forbidden');
        }
    }

    // 所有检查通过，放行请求给 CloudFront 缓存层或源站
    return request;
}

function blockResponse(statusCode, statusDescription) {
    return {
        statusCode: statusCode,
        statusDescription: statusDescription,
        headers: {
            'content-type': { value: 'application/json' },
            'cache-control': { value: 'no-cache, no-store, must-revalidate' }
        },
        body: {
            encoding: 'text',
            data: JSON.stringify({ error: statusDescription, status: statusCode })
        }
    };
}
