package PeopleAPI::App::CLI;

use App::Cmd::Setup -app => {
  plugins => [ qw(Prompt) ],
};
1;
