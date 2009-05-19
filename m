From: Petr Rockai <prockai@redhat.com>
Date: Tue, 19 May 2009 08:01:13 +0200
Subject: [PATCH] Use lvconvert --repair as a dmeventd mirror failure handler
Message-ID: <87r5ylbphy.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this one-liner enables the dmeventd mirror monitoring DSO to use lvconvert
--repair to fix any broken mirrors. This means two things:

1) Non-mirrored LVs will be no longer affected by mirror monitoring. (Before,
if you had a LV that went partially missing on a VG where a mirror leg failed,
this LV would be removed automatically by dmeventd... Probably not an
unrecoverable dataloss bug, but still quite unpleasant.)

2) If enough parallel PV space is available at the time of the mirror failure,
the failed devices will be automatically replaced using this spare space. Which
(and whether) free space may be used is still not configurable, but is a
planned feature. Since it is relatively easy to undo the action by converting
the mirror manually, I don't consider this to be a showstopper. In fact, I
think the compromise is much better than what we have now.

I have tested the patch and mirrors get repaired for me automatically when
things fail. This does not equate thorough testing, but lvconvert --repair is
already covered by the testsuite for a few weeks now and so far no obvious
issues appeared.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmevent-lvconvert-mirrors.diff
Type: text/x-diff
Size: 956 bytes
Desc: dmeventd-lvconvert-mirrors.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090519/dbd7f5d5/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
