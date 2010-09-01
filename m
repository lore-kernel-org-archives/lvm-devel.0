From: Diego Elio Pettenò <flameeyes@gmail.com>
Date: Wed, 01 Sep 2010 15:35:00 -0000
Subject: [PATCH] Fix liblvm2cmd.so linking order for --as-needed builds
Message-ID: <1283355456.30896.286.camel@yamato.local>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

I'm attaching a patch that fix the linking of liblvm2cmd.so so that it
actually links to the libraries it needs... with the original Makefile,
the linking order is such that ld drops all the libraries, linking only
libc at the end... this in turn will cause undefined references to floor
when the library is loaded in (see http://bugs.gentoo.org/335205 for
reference).

HTH!

-- 
Diego Elio Petten? ? ?Flameeyes?
http://blog.flameeyes.eu/

If you found a .asc file in this mail and know not what it is,
it's a GnuPG digital signature: http://www.gnupg.org/

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-2.02.73-asneeded.patch
Type: text/x-patch
Size: 640 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100901/d3186f81/attachment.bin>
