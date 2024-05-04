from django.urls import path, re_path
from . import views
from rest_framework.urlpatterns import format_suffix_patterns


app_name = "app"
urlpatterns = [
    path("api/get", views.getTest, name="get_test"),
    path("api/post", views.postTest, name="get_post"),
]

#urlpatterns = format_suffix_patterns(urlpatterns)