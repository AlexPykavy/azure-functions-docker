FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS runtime-image

ENV PublishWithAspNetCoreTargetManifest=false
ENV HOST_VERSION=2.0.12409
ENV HOST_COMMIT=f2ff95673c4f2b73076372d8460204ec6dbdf09e

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers

FROM mcr.microsoft.com/dotnet/core/runtime-deps:2.2

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/workers", "/workers"]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]