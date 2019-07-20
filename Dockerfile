FROM mcr.microsoft.com/dotnet/core/runtime:2.2-bionic AS javaBase
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends default-jre
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
RUN dotnet publish "EventConsumer.Console.csproj" -c Release --self-contained -r linux-x64 -o /app

FROM javaBase as final
WORKDIR /app
COPY "EventConsumer/kcl.properties" .
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "EventConsumer.Console.dll", "--properties", "kcl.properties", "--execute"]
