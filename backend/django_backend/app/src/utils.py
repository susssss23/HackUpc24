import textwrap

from llama_index import StorageContext
from llama_index.indices.vector_store import VectorStoreIndex
from llama_iris import IRISVectorStore

import getpass
import os
from dotenv import load_dotenv

import time

load_dotenv(override=True)

if not os.environ.get("OPENAI_API_KEY"):
    os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")



def try_query(user_input, max_attempts):
    """ Tries max_attempts times to resolve a user query"""
    
    attempts = 0
    
    username = 'demo'
    password = 'demo' 
    hostname = os.getenv('IRIS_HOSTNAME', 'localhost')
    port = '1972' 
    namespace = 'USER'
    CONNECTION_STRING = f"iris://{username}:{password}@{hostname}:{port}/{namespace}"
    
    while attempts < max_attempts:
        try:   
            vector_store = IRISVectorStore.from_params(
                connection_string=CONNECTION_STRING,
                table_name="documentation",
                embed_dim=1536,  
            )
            
            index = VectorStoreIndex.from_vector_store(vector_store=vector_store)
            query_engine = index.as_query_engine()

            prompt = """
            Ets un bot ajudant d'estudiants expert en la normativa de la FIB. 


            PREGUNTA:
            {user_input}

            INSTRUCCIONS:
            Respon la PREGUNTA de l'usuari. Si no en saps la resposta, digues que ho sents, però que no saps la resposta.
            Respon en l'idioma de l'usuari. 

            """

            prompt = prompt.format(prompt, user_input=user_input)

            response = query_engine.query(prompt)

            result = textwrap.fill(str(response), 100)

            return result  
        except Exception as e:
            print(f"Attempt {attempts + 1} failed:", e)
            attempts += 1
            time.sleep(1) 
    print("Max attempts reached, exiting.")

def user_query(user_input):
    """ Processes a user query """
    try:
        result = try_query(user_input, 5)
    except:
        print("Failed after max attempts.")

    return result