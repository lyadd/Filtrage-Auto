use strict;
use warnings;
use IO::File;
use XMLTV;

my $out = shift @ARGV or die "Aucun fichier de sortie spécifié.";

my $in = 'filter/tv_grep.in';

die "Le dossier 'filter' existe déjà." if -d 'filter';

print "Je commence à créer le dossier 'filter'...\n";
mkdir 'filter' or die "Impossible de créer le dossier 'filter' : $!";
print "Le dossier 'filter' a été créé.\n";

unless (-e $in) {
    print "Le fichier 'tv_grep.in' n'existe pas. Création du fichier...\n";
    open my $new_in_fh, '>', $in or die "Impossible de créer le fichier $in : $!";
    close $new_in_fh;
    print "Le fichier 'tv_grep.in' a été créé.\n";
}

require './filter/Grep.pm';

open(my $in_fh, '<', $in) or die "Impossible de lire le fichier $in : $!";
open(my $out_fh, '>', $out) or die "Impossible d'écrire dans le fichier $out : $!";

while (my $line = <$in_fh>) {
    if ($line =~ /^\s*\@PROGRAMME_CONTENT_TESTS\s*$/) {
        my %key_type = %{XMLTV::list_programme_keys()};
        
        for my $key (sort keys %key_type) {
            my ($arg, $matcher) = @{XMLTV::Grep::get_matcher($key)};
            
            my $output = "B<--$key> ";
            if (not defined $arg) {
                $output .= "\n\n";
            }
            elsif ($arg eq 'regexp') {
                $output .= "REGEXP\n\n";
            }
            elsif ($arg eq 'empty') {
                $output .= "''\n\n";
            }
            else {
                die "Type d'argument invalide retourné par get_matcher() : $arg";
            }
            
            print $out_fh $output;
        }
    }
    else {
        print $out_fh $line;
    }
}

close $out_fh or die "Impossible de fermer le fichier $out : $!";
close $in_fh or die "Impossible de fermer le fichier $in : $!";