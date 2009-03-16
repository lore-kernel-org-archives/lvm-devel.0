From: Petr Rockai <prockai@redhat.com>
Date: Mon, 16 Mar 2009 19:56:40 +0100
Subject: [PATCH] pvcreate: conditionally wipe swap signatures
Message-ID: <87tz5tl2jb.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this should address https://bugzilla.redhat.com/show_bug.cgi?id=443062 -- the
first patch implements the actual check, in the spirit of dev_is_md (it also
gets a check in the testsuite). The code is based on swap signature detection
in swapon implementation of util-linux-ng:
http://git.kernel.org/?p=utils/util-linux-ng/util-linux-ng.git;a=blob_plain;f=mount/swapon.c

The latter patch just throws in some checks that the old code misses. They
might as well be redundant (or not, depends on how you look at it). Personally,
I am ambivalent -- advice about (non-)inclusion sought.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm-pvcreate-wipe-swap.diff
Type: text/x-diff
Size: 4790 bytes
Desc: pvcreate-wipe-swap.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090316/8f5d0a79/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm-pvcreate-paranoia.diff
Type: text/x-diff
Size: 1662 bytes
Desc: lvm-pvcreate-paranoia.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090316/8f5d0a79/attachment-0001.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
