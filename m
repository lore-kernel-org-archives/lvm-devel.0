From: Petr Rockai <prockai@redhat.com>
Date: Wed, 10 Jun 2009 07:45:58 +0200
Subject: [PATCH] Complain when lvconvert --repair is used on non-mirror LV.
Message-ID: <87ski8myjt.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

just a trivial patch to make things clear when people mistakenly run lvconvert
--repair on a non-mirrored LV (otherwise, this would succeed silently doing
nothing).

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-nonmirror.diff
Type: text/x-diff
Size: 603 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090610/4cb4c54f/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
