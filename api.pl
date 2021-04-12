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


find_place_url("https://maps.googleapis.com/maps/api/place/findplacefromtext/json").

find_place_params([("inputtype", "textquery"),("fields", "name,geometry")]).

nearby_search_url("https://maps.googleapis.com/maps/api/place/nearbysearch/json").

nearby_search_params([("type", "pharmacy"), ("radius", "2000")]).




nearby_pharmacy(Input, Pharmacy) :-
    get_location_value(Input, LocationValue),
    call_nearby_search(LocationValue, Response),
    take_first(Response.results, Pharmacy).


get_location_value(TextInput, LocationValue) :-
    call_location_search(TextInput, Response),
    get_lat_lng_from_response(Response,Lat,Lng),
    string_concat(Lat, ",", S),
    string_concat(S, Lng, LocationValue).


get_lat_lng_from_response(Response, Lat, Lng) :-
    take_first(Response.candidates, A),
    Lat is (A.geometry.location.lat),
    Lng is (A.geometry.location.lng).


    

call_location_search(Input, Response) :- 
    find_place_url(BaseUrl),
    find_place_params(Params),
    generate_url(BaseUrl, Params, Url),
    add_query_param_to_url(Url, ("input", Input), NewUrl),
    request(NewUrl, Response).


call_nearby_search(LocationValue, Response) :- 
    nearby_search_url(BaseUrl),
    nearby_search_params(Params), 
    generate_url(BaseUrl, Params, Url),
    add_query_param_to_url(Url, ("location", LocationValue), NewUrl),
    request(NewUrl, Response).

generate_url(BaseUrl, Params, Url) :-
    add_api_key(BaseUrl, UrlWithApiKey),
    add_query_params_to_url(UrlWithApiKey, Params, Url).

add_api_key(Url, UrlWithApiKey) :- 
    client_key(Key), 
    string_concat("?key=", Key, ApiKeyParam),
    string_concat(Url, ApiKeyParam, UrlWithApiKey).


add_query_params_to_url(Url, [], Url).
add_query_params_to_url(Url, [(Key, Val)|T], UrlWithParams) :-
    add_query_param_to_url(Url, (Key, Val), UrlWithParam),
    add_query_params_to_url(UrlWithParam, T, UrlWithParams).


add_query_param_to_url(Url, (Key, Val), NewUrl) :- 
    make_query_param(Key, Val, Param), 
    string_concat("&", Param, AndParam), 
    string_concat(Url, AndParam, NewUrl).

make_query_param(Key, Val, Param) :- 
    string_concat(Key, "=", KeyEq), 
    string_concat(KeyEq, Val, Param).

request(Url, Response) :-
    http_get(Url, Data, []),
    atom_json_dict(Data, Response, []).

take_first([], []).
take_first([H|_], H).