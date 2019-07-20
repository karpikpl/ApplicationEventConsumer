FROM mcr.microsoft.com/dotnet/core/runtime:2.2-bionic AS javaBase
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends default-jre

FROM mcr.microsoft.com/dotnet/core/runtime:2.2-stretch-slim AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-stretch AS build
WORKDIR /src
COPY ["EventConsumer.Console/EventConsumer.Console.csproj", "EventConsumer.Console/"]
COPY ["ClientLibrary/ClientLibrary.csproj", "ClientLibrary/"]
COPY ["EventConsumer/EventConsumer.csproj", "EventConsumer/"]
RUN dotnet restore "EventConsumer.Console/EventConsumer.Console.csproj"
RUN dotnet restore "ClientLibrary/ClientLibrary.csproj"
RUN dotnet restore "EventConsumer/EventConsumer.csproj"
COPY . .
WORKDIR "/src/EventConsumer.Console"
RUN dotnet build "EventConsumer.Console.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "EventConsumer.Console.csproj" -c Release -o /app

FROM base AS core
WORKDIR /app
COPY --from=publish /app .

FROM javaBase as final
WORKDIR /app
COPY --from=core . .
ENTRYPOINT ["dotnet", "app/EventConsumer.Console.dll"]
