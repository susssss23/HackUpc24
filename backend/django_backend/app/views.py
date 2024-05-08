from django.shortcuts import render
from . models import *
from rest_framework.response import Response
from . serializer import *
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from .src import utils


@api_view(['GET'])
def getTest(request, format=None):
    return Response({"GET" : "WORKS"}, status=status.HTTP_200_OK)
1
1

@api_view(['POST'])
def postTest(request, format=None): 
    user_input = request.data.get("question")

    print(user_input)

    result = utils.user_query(user_input)

    return Response({"response": result}, content_type='application/json;charset=UTF-8', status=status.HTTP_200_OK)