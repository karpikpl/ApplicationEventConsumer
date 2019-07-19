FROM microsoft/dotnet:2.2-aspnetcore-runtime-alpine3.8 AS base
RUN apk --update add openjdk8-jre
WORKDIR /app

FROM microsoft/dotnet:2.2-sdk-alpine3.8 AS build
WORKDIR /src
COPY ["./EventConsumer.Console/*.*", "EventConsumer.Console/"]
COPY ["./ClientLibrary/*.*", "ClientLibrary/"]
COPY ["./ClientLibrary/**/*.*", "ClientLibrary/"]
COPY ["./EventConsumer/*.*", "EventConsumer/"]

WORKDIR "/src/EventConsumer"
RUN dotnet publish "EventConsumer.csproj" -c Release -o /app  


WORKDIR "/src/EventConsumer.Console"

RUN dotnet publish "EventConsumer.Console.csproj" -c Release -o /app  

FROM base as final
WORKDIR /app
COPY --from=build /app .

ENTRYPOINT ["dotnet", "EventConsumer.Console.dll", "--properties", "kcl.properties", "--execute"]
