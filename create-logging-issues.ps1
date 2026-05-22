# ============================================================
# create-logging-issues.ps1
# Buat semua GitHub Issues untuk implementasi logging SamStore
# Prasyarat: gh auth login sudah dilakukan
# Jalankan dari PowerShell: .\create-logging-issues.ps1
# ============================================================

Write-Host "Creating GitHub Issues for SamStore Logging Standardization..." -ForegroundColor Cyan

# --- Issue 1: SS-APIGateway ---
gh issue create `
  --repo "jhony-samosir/SS-APIGateway" `
  --title "feat(logging): Standardize structured JSON logging to stdout for Fluent Bit ingestion" `
  --label "enhancement" `
  --body "## Tujuan
Menstandarisasi output log dari SS-APIGateway agar berformat JSON terstruktur yang diarahkan ke stdout. Hal ini memungkinkan Fluent Bit (di infra SS-Logging) untuk mengumpulkan dan meneruskan log ke Loki tanpa modifikasi tambahan.

## Konteks Teknis
- Framework: ASP.NET 10 / .NET 10
- Sudah terdapat CorrelationIdMiddleware yang membangun logging scope.
- Sudah menggunakan AddGatewayObservability() dengan OpenTelemetry.
- Tidak menggunakan MediatR (YARP gateway pattern).

## Task List
- [ ] Tambahkan package Serilog (Serilog.AspNetCore, Serilog.Sinks.Console, Serilog.Formatting.Compact) ke SS.APIGateway.csproj
- [ ] Konfigurasi builder.Host.UseSerilog() di Program.cs dengan CompactJsonFormatter
- [ ] Tambahkan app.UseSerilogRequestLogging() di pipeline middleware
- [ ] Update CorrelationIdMiddleware.cs untuk menggunakan LogContext.PushProperty dari Serilog agar CorrelationId muncul di setiap log line sebagai field JSON
- [ ] Update appsettings.json dengan konfigurasi Serilog log level

## Format JSON Log yang Diharapkan
{ service: 'ss-api-gateway', CorrelationId: '...', Method: 'GET', Path: '/api/...', StatusCode: 200 }

## Referensi
Infrastruktur logging: https://github.com/jhony-samosir/SS-Logging"

Write-Host "Issue 1 created for SS-APIGateway" -ForegroundColor Green

# --- Issue 2: SS-AuthService ---
gh issue create `
  --repo "jhony-samosir/SS-AuthService" `
  --title "feat(logging): Implement structured JSON logging with MediatR pipeline behavior for Loki integration" `
  --label "enhancement" `
  --body "## Tujuan
Mengimplementasikan structured logging berformat JSON di SS-AuthService menggunakan Serilog, termasuk sebuah MediatR Pipeline Behavior terpusat untuk mencatat semua request/response di Application layer sesuai pola Clean Architecture.

## Konteks Teknis
- Framework: ASP.NET 10 / .NET 10
- Arsitektur: Clean Architecture (API -> Application -> Domain <- Infrastructure)
- Application layer menggunakan MediatR 14.x
- Terdapat ExceptionMiddleware dan GatewayOnlyMiddleware di layer API
- Terdapat SS.AuthService.Infrastructure.Diagnostics yang perlu diperhatikan agar tidak duplikasi

## Task List
- [ ] Tambahkan package Serilog ke SS.AuthService.API.csproj dan SS.AuthService.Application.csproj
- [ ] Konfigurasi builder.Host.UseSerilog() di Program.cs dengan CompactJsonFormatter
- [ ] Tambahkan app.UseSerilogRequestLogging() di pipeline middleware
- [ ] Buat LoggingBehavior di src/SS.AuthService.Application/Common/Behaviors/LoggingBehavior.cs
- [ ] Register LoggingBehavior ke MediatR pipeline di DependencyInjection.cs
- [ ] Buat/modifikasi middleware untuk propagasi X-Correlation-Id dari Gateway ke Serilog LogContext (JANGAN generate ID baru, gunakan dari gateway)
- [ ] Update appsettings.json dengan konfigurasi Serilog log level
- [ ] Pastikan LoggingBehavior TIDAK mencatat password, token, atau PII apapun

## Format JSON Log yang Diharapkan
{ service: 'ss-auth-service', CorrelationId: '...', RequestName: 'LoginCommand', DurationMs: 120 }

## Referensi
Infrastruktur logging: https://github.com/jhony-samosir/SS-Logging"

Write-Host "Issue 2 created for SS-AuthService" -ForegroundColor Green

# --- Issue 3: SS-CatalogService ---
gh issue create `
  --repo "jhony-samosir/SS-CatalogService" `
  --title "feat(logging): Implement structured JSON logging with slog for Fluent Bit + Loki integration" `
  --label "enhancement" `
  --body "## Tujuan
Mengimplementasikan structured logging berformat JSON di SS-CatalogService menggunakan package log/slog standar Go (tersedia sejak Go 1.21), tanpa menambahkan dependency eksternal baru. Log diarahkan ke stdout dan akan dikumpulkan oleh Fluent Bit.

## Konteks Teknis
- Language: Go 1.26
- HTTP Framework: Gin
- ORM: GORM dengan driver pgx (PostgreSQL)
- Sudah terdapat CorrelationIDMiddleware yang menyimpan correlation_id ke Gin context -- perlu diintegrasikan ke log context.

## Task List
- [ ] Setup slog.Logger dengan JSONHandler di cmd/api/main.go dan set sebagai default logger
- [ ] Injeksi logger ke RouterConfig dan teruskan ke handler/usecase via constructor
- [ ] Buat RequestLoggerMiddleware di internal/delivery/http/middleware/logger_middleware.go yang membaca correlation_id dari Gin context
- [ ] Daftarkan middleware logger di SetupRouter() di router.go setelah CorrelationIDMiddleware
- [ ] Tambahkan log audit (Create/Update/Delete) di repository layer PostgreSQL (internal/repository/postgres/)
- [ ] Injeksi logger ke usecase kompleks (ImportUsecase, InventoryCommand)
- [ ] Pastikan TIDAK ada data sensitif (PII, harga draft) yang masuk ke log

## Format JSON Log yang Diharapkan
{ level: 'INFO', msg: 'http_request', service: 'ss-catalog-service', method: 'POST', path: '/api/catalog/v1/products', status: 201, duration_ms: 88, correlation_id: '...' }

## Referensi
Infrastruktur logging: https://github.com/jhony-samosir/SS-Logging"

Write-Host "Issue 3 created for SS-CatalogService" -ForegroundColor Green

# --- Issue 4: SS-App ---
gh issue create `
  --repo "jhony-samosir/SS-App" `
  --title "feat(logging): Implement server-side structured JSON logging with pino for SSR error tracking" `
  --label "enhancement" `
  --body "## Tujuan
Mengimplementasikan structured logging berformat JSON di sisi server (SSR/API Routes) pada SS-App menggunakan library pino. Log akan ditulis ke stdout dan dikumpulkan oleh Fluent Bit dari container Next.js.

## Konteks Teknis
- Framework: Next.js 16 (App Router)
- Sisi server: SSR page components + Server Actions + Route Handlers (src/app/)
- Sisi client: React components (di luar scope issue ini)
- Sudah menggunakan axios untuk HTTP calls ke API Gateway

## Task List
- [ ] Install package: npm install pino
- [ ] Buat shared logger instance di src/lib/logger.ts dengan base field: { service: 'ss-app', env: process.env.NODE_ENV }
- [ ] Tambahkan error logging di setiap Route Handler (route.ts) menggunakan logger
- [ ] Tambahkan global error logger di src/app/global-error.tsx untuk menangkap error SSR
- [ ] Tambahkan log untuk error response pada Server Actions yang memanggil API Gateway (status 4xx/5xx)
- [ ] Tambahkan LOG_LEVEL=info ke .env.example

## Format JSON Log yang Diharapkan
{ level: 'error', service: 'ss-app', env: 'production', path: '/api/...', msg: 'Route handler error' }

## Referensi
Infrastruktur logging: https://github.com/jhony-samosir/SS-Logging"

Write-Host "Issue 4 created for SS-App" -ForegroundColor Green

Write-Host ""
Write-Host "All 4 issues created successfully!" -ForegroundColor Cyan
