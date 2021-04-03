:- module(api).

:- use_module(library(http/http_client)).
:- use_module(library(http/json)).
:- use_module(library(uri)).

:- use_module(key). % You need to create your own key.pl file with client_key("your google client key").

% Google Place API
% https://developers.google.com/maps/documentation/places/web-service/search

% parameters
% required: key, location, radius

% type=pharmacy
% location=49.26870829991198,-123.1706689178154
% key=AIzaSyAzOVpbdK4rYbZ96mCu7kFiefabstghudk
% radius=2000

% e.g.
% https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAzOVpbdK4rYbZ96mCu7kFiefabstghudk&location=49.26870829991198,-123.1706689178154&radius=2000&type=pharmacy

% refered to https://github.com/cormacjmollitor/CPSC-312-Movie-Recommendations/blob/master/recommendation.pl


nearby_search_url("https://maps.googleapis.com/maps/api/place/nearbysearch/json").

params([("location", "49.26870829991198,-123.1706689178154"), ("type", "pharmacy"), ("radius", "2000")]).


call_nearby_search(Response) :- 
    nearby_search_url(BaseUrl),
    params(Params), 
    generate_url(BaseUrl, Params, Url),
    request(Url, Response).

generate_url(BaseUrl, Params, Url) :-
    add_api_key(BaseUrl, UrlWithApiKey),
    add_query_params(UrlWithApiKey, Params, Url).

add_api_key(Url, UrlWithApiKey) :- 
    client_key(key), 
    string_concat("?key=", key, ApiKeyParam),
    string_concat(Url, ApiKeyParam, UrlWithApiKey).

add_query_params(Url, [], Url).
add_query_params(Url, [(Key, Val)|T], UrlWithParams) :-
    add_query_param(Url, (Key, Val), UrlWithParam),
    add_query_params(UrlWithParam, T, UrlWithParams).


add_query_param(Url, (Key, Val), NewUrl) :- 
    make_query_param(Key, Val, Param), 
    string_concat("&", Param, AndParam), 
    string_concat(Url, AndParam, NewUrl).

make_query_param(Key, Val, Param) :- 
    string_concat(Key, "=", KeyEq), 
    string_concat(KeyEq, Val, Param).

request(Url, Response) :-
    http_get(Url, Data, []),
    atom_json_dict(Data, Response, []).
