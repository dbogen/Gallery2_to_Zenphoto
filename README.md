Gallery2_to_Zenphoto
====================

Migration script to migrate from Gallery2 to Zenphoto.

Overview
--------

This script will help you migrate from Gallery2 to Zenphoto.  It is crude
but effective.

To arrive at the following script I mashed together some bits and pieces
that others had published online, added some of my own perl glue, and came
up with a Frankenstein script that did 85-90% of the work for me.  

You'll need perl and the following perl modules to use the script:

 * DBI
 * DBD::mysql

When I ran the script, it was against Gallery2 version 2.3.X of Gallery2 and
Zenphoto version 1.4.3.

**IMPORTANT NOTICE:** *I take no responsibility for any data loss you experience as a result of running this script.  Caveat emptor.  You get what you pay for.*

Running the script
------------------

1. Start by reading this entire document, especially the Gotchas section below and the IMPORTANT NOTICE above.

2. Now back up your Gallery2 data, both the albums and the database. Remember the IMPORTANT NOTICE above.

3. You should then back up your Zenphoto database and any associated albums.

4. Modify the variables at the top of the script to be appropriate for your environment.

5. Run the script.  Watch the output to ensure that it's doing what you think it should.

6. Send me any feedback you have at djb@bogen.org.

Gotchas
-------

There are a couple of gotchas involved with the script.  Reading through the
code is definitely worth your time if you're at all worried about the results
or if your installation is in any way non-standard.

The biggest gotcha you might encounter will be if you have multiple albums
in Gallery2 that all have the same name.  In that case, you'll find that the
contents of the albums will all end up concatenated into one album.  To
avoid that problem I recommend that you temporarily rename one of the
conflicting albums to a unique name until the conversion is complete.  Once
the conversion is complete you can rename the album again back to its
original name.

This script will only import JPEGs and albums.  If you're trying to import
GIFs, PNGs, Flash, or anything else you'll need to modify the appropriate
regex to recognize the file extension.

The biggest problem I had with the script is that I didn't build in the
requisite logic for the script to intelligently choose between the summary
and description fields as the source for the photo caption.  At some point
during my use of Gallery2 I had switched from putting information in the
summary field to the description field.  As such, I had to choose which of
the two fields I wanted the script to import for me and then hand-import the
remainder.  It is likely that you won't have the same problem.

In addition, if you’ve used any of Gallery2′s tags (to add a link to a field
or bold some text or something) this script won’t recognize the tags and fix
them.  You can probably pretty easily fix all those problems with a few
regexes in strategic places, but I only had a few of those tags in my own
data so it wasn’t worth the time to build that into the script.

