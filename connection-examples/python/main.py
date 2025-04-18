import redis
import os
from redis.exceptions import ConnectionError
from azure.identity import DefaultAzureCredential
from redis_entraid.cred_provider import *


def get_env():
    redis_host = os.getenv("REDIS_HOST")
    redis_port = os.getenv("REDIS_PORT")

    # If using Service Principal authentication, you need 
    return redis_host, redis_port

# Authenticate using Azure Entra ID
def ping_redis_with_azure_entraid():
    try:

        redis_host, redis_port = get_env()
        # When testing from your local machine, remember to add the user, managed identity or service principal to the Redis Cluster

        # Use DefaultAzureCredential to authenticate with Azure Entra ID
        DefaultAzureCredential()

        # Example using DefaultAzureCredential 
        credential_provider = create_from_default_azure_credential(
            ("https://redis.azure.com/.default",),)

        # Create a Redis client with Azure Entra ID authentication
        redis_client = redis.Redis(host=redis_host, port=redis_port, ssl=True, credential_provider=credential_provider)

        # Ping the Redis server
        response = redis_client.ping()
        if response:
            print("Successfully connected to Redis server using Azure Entra ID!")
        else:
            print("Failed to connect to Redis server.")
    except ConnectionError as e:
        print(f"Redis connection error: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    ping_redis_with_azure_entraid()