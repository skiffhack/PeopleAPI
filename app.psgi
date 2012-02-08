#!/usr/bin/env perl

use lib './lib';
use PeopleAPI::App::Web;
use Plack::Builder;

builder {
  enable 'CrossOrigin', origins => 'http://skiffprofile.herokuapp.com', headers => ['*'];
  enable "JSONP", callback_key => 'callback';
  PeopleAPI::App::Web->new->to_psgi_app;
};