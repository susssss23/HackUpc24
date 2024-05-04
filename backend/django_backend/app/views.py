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
    data = request.data.get("question")
    return Response({"POST" : data}, status=status.HTTP_200_OK)