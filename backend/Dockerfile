# Build context is the repository root (see docker-compose.build.yml).
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
# Restore first, from just the project files, so this layer is cached until a package changes.
COPY backend/src/IDManager.Api/IDManager.Api.csproj backend/src/IDManager.Api/
COPY backend/src/IDManager.Domain/IDManager.Domain.csproj backend/src/IDManager.Domain/
COPY backend/src/IDManager.Infrastructure/IDManager.Infrastructure.csproj backend/src/IDManager.Infrastructure/
RUN dotnet restore backend/src/IDManager.Api/IDManager.Api.csproj
COPY backend/src/ backend/src/
WORKDIR /src/backend/src/IDManager.Api
RUN dotnet publish IDManager.Api.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
# The card PDFs are drawn with SkiaSharp + HarfBuzz (native libraries come with the NuGet packages)
# and the Noto Sans / Noto Sans Tamil fonts are embedded in the assembly, so nothing else has to be
# installed for them. libfontconfig1 is only a courtesy for SkiaSharp's own font lookups.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "IDManager.Api.dll"]
