from django.shortcuts import render
from rest_framework.views import APIView
from . models import *
from rest_framework.response import Response
from . serializer import *
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import json

from llama_index import SimpleDirectoryReader, StorageContext, ServiceContext
from llama_index.indices.vector_store import VectorStoreIndex
from llama_iris import IRISVectorStore

import getpass
import os
from dotenv import load_dotenv

load_dotenv(override=True)

if not os.environ.get("OPENAI_API_KEY"):
    os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
# Create your views here.


@api_view(['GET'])
def getTest(request, format=None):
    return Response({"GET" : "WORKS"}, status=status.HTTP_200_OK)
1

@api_view(['POST'])
def postTest(request, format=None): 
    user_input = request.data.get("question")
    language = request.data.get("language")

    username = 'demo'
    password = 'demo' 
    hostname = os.getenv('IRIS_HOSTNAME', 'localhost')
    port = '1972' 
    namespace = 'USER'
    CONNECTION_STRING = f"iris://{username}:{password}@{hostname}:{port}/{namespace}"

    vector_store = IRISVectorStore.from_params(
        connection_string=CONNECTION_STRING,
        table_name="documentation",
        embed_dim=1536,  # openai embedding dimension
    )
    storage_context = StorageContext.from_defaults(vector_store=vector_store)
    
    index = VectorStoreIndex.from_vector_store(vector_store=vector_store)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)
    query_engine = index.as_query_engine()

    prompt = """
    Ets un bot ajudant d'estudiants expert en la normativa de la FIB. 


    PREGUNTA:
    {user_input}

    INSTRUCCIONS:
    Respon la PREGUNTA. Si no en saps la resposta, digues "Ho sento, però no sé la resposta.".

    """

    prompt = prompt.format(prompt, user_input=user_input)


    response = query_engine.query(prompt)

    import textwrap
    result = textwrap.fill(str(response), 100)

    return Response({"POST" : { "language": language, "question": result}}, status=status.HTTP_200_OK)