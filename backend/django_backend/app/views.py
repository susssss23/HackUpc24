from django.shortcuts import render
from rest_framework.views import APIView
from . models import *
from rest_framework.response import Response
from . serializer import *
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import json

# Create your views here.


@api_view(['GET'])
def getTest(request, format=None):
    return Response({"GET" : "WORKS"}, status=status.HTTP_200_OK)


@api_view(['POST'])
def postTest(request, format=None): 
    question = request.data.get("question")
    language = request.data.get("language")

    # your code goes here

    return Response({"POST" : { "language": language, "question": question}}, status=status.HTTP_200_OK)