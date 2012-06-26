#!/usr/bin/perl
use strict;

##############################################################################
# Define variables

#
# $host is the hostname of your database, probably localhost.
#
my $host = 'ZEN_PHOTO_DB_HOST';
my $user = 'ZEN_PHOTO_USER';
my $password = 'ZEN_PHOTO_USER_PASSWORD';

#
# $gallery2_db is the name of your Gallery2 database. Change as needed.
#
my $gallery2_db = 'gallery2';

#
# This is the prefix in front of your gallery2 database tables. Change as
# needed.
# If this prefix is unnecessary, leave the quotes with nothing in them, like:
# my $gallery2_db_prefix = '';
#
my $gallery2_db_prefix = 'g2_';

#
# $zenphoto_db is the name of your zenphoto dataabase. Change as needed.
#
my $zenphoto_db = 'zenphoto';

#
# This is the prefix in front of your zenphoto database tables. Change as needed.
# If this prefix is unnecessary, leave the quotes with nothing in them, like:
# my $zenphoto_db_prefix = '';
#
my $zenphoto_db_prefix = 'zp_';

#
# $phototitle determines what the zenphoto title will be based upon
# "title" will use the Gallery2 title of a photo
# "summary" will use the Gallery2 summary of a photo
#
my $phototitle = 'title';
##############################################################################

#
# You shouldn't need to change anything below this line, but knowing how
# this world works, your setup might be just different enough that this script
# won't work for you out of the box. If that's the case, you'll definitely
# have to change something below this line, but what, exactly, needs to be changed
# is an exercise for the user.
#

use DBI();

#
# I had two different databases for my data, so I needed two different database
# handles. However, I created one user that had priveleges on both databases,
# so I only needed one username/password combination. Your setup might be
# simpler or more complex and, hence, you might need to adjust these to
# fit your needs.
#
my $dbh_gallery2 = DBI->connect("DBI:mysql:database=$gallery2_db;host=$host",
  $user, $password, {'RaiseError' => 1}) || 
  die("Could not connect to Gallery2 database $gallery2_db:  $!\n");
my $dbh_zp = DBI->connect("DBI:mysql:database=$zenphoto_db;host=$host",
  $user, $password, { RaiseError => 1, AutoCommit => 1 }) ||
  die("Could not connect to Zenphoto database $zenphoto_db: $!\n");

my $cursor = $dbh_gallery2->prepare("select
  ${gallery2_db_prefix}FileSystemEntity.g_id,
  ${gallery2_db_prefix}FileSystemEntity.g_pathComponent,
  ${gallery2_db_prefix}Item.g_${phototitle},
  ${gallery2_db_prefix}Item.g_description,
  ${gallery2_db_prefix}Item.g_keywords from
  ${gallery2_db_prefix}FileSystemEntity,
  ${gallery2_db_prefix}Item where
  ${gallery2_db_prefix}FileSystemEntity.g_id = ${gallery2_db_prefix}Item.g_id;") ||
  die "Gallery2 prepare error ($DBI::errstr)\n";

$cursor->execute() || die "Query error ($DBI::errstr)";

#
# Use backticks here becuase some of these are MySQL reserved words. Use
# backticks on everything because it can't hurt.
#
my $sql1 =
  "UPDATE ${zenphoto_db_prefix}images SET `title` = ?, `desc` = ? WHERE
  `filename` = ?";
my $sql2 =
  "UPDATE ${zenphoto_db_prefix}albums SET `title` = ? , `desc`= ? WHERE
  `folder` like ?";
my $sth1 = $dbh_zp->prepare($sql1);
my $sth2 = $dbh_zp->prepare($sql2);

my $counter = 0;
my $rows_affected = 0;

while(defined(my $row = $cursor->fetch)) {
  my $id = $row->[0];
  my $filenm = $row->[1];
  my $summary = $row->[2];
  my $description = $row->[3];
  $rows_affected = 0;

  #
  # If you're importing anything other than JPEGs, you'll need to modify the
  # the regex below.
  #
  if ($filenm =~ /\.jpg/io)
  {
    $rows_affected = $sth1->execute($summary, $description, $filenm)
      or die $sth1->errstr;
    print "IMAGE $counter: gallery2 ID $id: $filenm --- $summary --- $description\n";
    unless($rows_affected)
    {
      print("ERROR: Data for $filenm not saved in database.\n");
    }
  }
  elsif($filenm)
  {
    #
    # You need the wildcard here because the album that you're updating
    # is (potentially) at the end of a long string of albums and you
    # don't necessarily care about what comes before. Of course,
    # if you have multiple nested albums with the same name this logic
    # won't work for you. But I didn't have that problem, so it worked
    # for me. Your options include renaming some albums in Gallery2
    # before running this script or writing your own solution to
    # the problem.
    #
    $filenm = '%'.$filenm;
    $rows_affected = $sth2->execute($summary, $description, $filenm)
      or die $sth2->errstr;
    print "ALBUM $counter: gallery2 ID $id: $filenm --- $summary --- $description\n";
    unless($rows_affected)
    {
      print("ERROR: Data for $filenm not saved in database.\n");
    }
  }
  else
  {
    print "$counter: filename is NULL --- NOT INCLUDED!\n";
    next;
  }
  $counter++;
}

$dbh_gallery2->disconnect();
$dbh_zp->disconnect();
