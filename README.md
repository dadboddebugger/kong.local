## Setup
```
docker-compose up
```

## Open in browser
```
http://localhost:1337/#!/dashboard
```

## Service A
```
curl -i -X POST http://localhost:8001/services --data name=service-a  --data url=http://host.docker.internal:8090
curl -i -X POST http://localhost:8001/services/service-a/routes --data "paths[]=/svca"
curl -i -X POST http://localhost:8001/services/service-a/plugins --data name=key-auth
curl -i -X POST http://localhost:8001/services/service-a/plugins --data name=rate-limiting --data config.second=5 --data config.hour=100 --data config.limit_by=consumer
```
```
curl -i -X POST http://localhost:8001/services/service-a/plugins \
    --header "accept: application/json" \
    --header "Content-Type: application/json" \
    --data '
    {
  "name": "opentelemetry",
  "config": {
    "traces_endpoint": "http://otel-collector:4318/v1/traces",
    "logs_endpoint": "http://otel-collector:4318/v1/logs",
    "resource_attributes": {
      "service.name": "service-a"
    }
  }
}
    '
```

## Service B
```
curl -i -X POST http://localhost:8001/services --data name=service-b  --data url=http://host.docker.internal:8091
curl -i -X POST http://localhost:8001/services/service-b/routes --data "paths[]=/svcb"
curl -i -X POST http://localhost:8001/services/service-b/plugins --data name=key-auth
curl -i -X POST http://localhost:8001/services/service-b/plugins --data name=rate-limiting --data config.second=5 --data config.hour=100 --data config.limit_by=consumer
```
```
curl -i -X POST http://localhost:8001/services/service-b/plugins \
    --header "accept: application/json" \
    --header "Content-Type: application/json" \
    --data '
    {
  "name": "opentelemetry",
  "config": {
    "traces_endpoint": "http://otel-collector:4318/v1/traces",
    "logs_endpoint": "http://otel-collector:4318/v1/logs",
    "resource_attributes": {
      "service.name": "service-b"
    }
  }
}
    '
```

## Service Bank-AI-API
```
curl -i -X POST http://localhost:8001/services --data name=bank-ai-api  --data url=http://host.docker.internal:3200
```
```
curl -X POST http://localhost:8001/services/bank-ai-api/routes \ 
  --data "name=openai-chat" \                                            
  --data "paths[]=~/openai-chat$"
  
```
```
curl -X POST http://localhost:8001/services/bank-ai-api/plugins \
   --header "accept: application/json" \                                 
   --header "Content-Type: application/json" \                                                                                                              
   --data '
   {
 "name": "ai-proxy",
 "config": {
   "route_type": "llm/v1/chat",
   "auth": {
     "header_name": "Authorization",
     "header_value": "Bearer <OPEN_AI_KEY>"
   },
   "model": {
     "provider": "openai",
     "name": "gpt-4",
     "options": {
       "max_tokens": 512,
       "temperature": 1.0
     }
   }
}

' 
```
```
curl -i -X POST http://localhost:8001/services/bank-ai-api/plugins \
    --header "accept: application/json" \
    --header "Content-Type: application/json" \
    --data '
    {
  "name": "opentelemetry",
  "config": {
    "traces_endpoint": "http://otel-collector:4318/v1/traces",
    "logs_endpoint": "http://otel-collector:4318/v1/logs",
    "resource_attributes": {
      "service.name": "banki-ai-proxy"
    }
  }
}
    '
 
```
```
curl -i -X POST http://localhost:8001/services/bank-ai-api/plugins \
   -F "name=pre-function" \
   -F "config.access[1]=@custom-span.lua"
```

## Consumers (Free, Premium)
```
curl -i -X POST http://localhost:8001/consumers --data username=free-user
curl -i -X POST http://localhost:8001/consumers/free-user/key-auth --data key=free-key
```
```
curl -i -X POST http://localhost:8001/consumers --data username=premium-user
curl -i -X POST http://localhost:8001/consumers/premium-user/key-auth --data key=premium-key  
```

## Test
```
curl -i -X POST http://localhost:8000/svca/svcb/openai-chat -H 'apikey: premium-key' -H 'Content-Type: application/json'  --data-raw '{ "messages": [ { "role": "system", "content": "You are a mathematician" }, { "role": "user", "content": "What is the capital of India?"} ] }'

curl -i -X POST http://localhost:8000/svca/svcb/openai-chat -H 'apikey: premium-key' -H 'Content-Type: application/json'  --data-raw '{ "messages": [ { "role": "system", "content": "You are a mathematician" }, { "role": "user", "content": "Calculate the area of a circle with a radius of 7 units (use π = 3.14)."} ] }'
```