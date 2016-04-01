#!/usr/bin/perl

# antropofonica album's photo graber
# by El Lifff

# lista de albums: https://graph.facebook.com/antropofonica/albums?&access_token

# leer: https://developers.facebook.com/docs/opengraph/getting-started
#       http://stackoverflow.com/questions/35999627/facebook-webhook-for-pages/36008361#36008361

use strict;
use feature 'say';

use warnings;
use LWP;
use Mozilla::CA;
use Data::Dumper;
use JSON;
# use Data::Compare;

my $folder = 'public/';

# URL Strings
my $host = 'https://graph.facebook.com/';

my $query_albums = '699227143425628/?fields=photos{created_time,name,images{source},comments}';
my $query_event = 'antropofonica/?fields=events.limit(1)';

my $access_token = '&access_token=1651798548476449|c838d5beaf40aa0d7bae4f7edc4b09af';


my $url_albums = $host.$query_albums.$access_token;
my $url_event = $host.$query_event.$access_token;

my $ua = LWP::UserAgent->new;
$ua->ssl_opts( SSL_ca_file => Mozilla::CA::SSL_ca_file());

$ua->agent("MyApp/0.1");


grabJson($url_albums,$url_event);


sub grabJson{

	foreach my $item (@_){

		print "Obteniendo: ",$item,"\n";

		# Create a Request
		my $req = HTTP::Request->new(GET => $item);
		$req->header(Accept => "text/json, */*;q=0.1");

		# Pass Request to the user agent and get a response back
		my $res = $ua->request($req);

		# Check the outcome of the response
		if ($res->is_success) {

			my $filename = '';

			foreach (split(/\n/,$item)){
			    if(/(?<before>[\w]+)?\s*=\s*(?<after>[\w]+)?/){
			        $filename = $+{after}.".json";
			    }
			}

			#load to compare
			open(my $fh, '<:encoding(UTF-8)', $folder.$filename)
				or die "Could not open file '$folder$filename' $!";

			my $fh_st;
			while (my $row = <$fh>) {
				chomp $row;
				$fh_st.=$row;
			}
			close $fh;

			# !compare then write
			unless($fh_st eq $res->content){
				open(my $fh, '>', $folder.$filename);
				print $fh $res->content;
				close $fh;
				say "-> Escribí: $folder$filename. <-\n";
			}else{
				say "<- Nada nuevo en: $folder$filename. ->\n";
			}

		}else{
			say $res->status_line, "\n";
		}

	}

}