From: Petr Rockai <prockai@redhat.com>
Date: Tue, 08 Jul 2008 15:21:44 +0200
Subject: [PATCH] (3/5) vgreduce --consolidate
Message-ID: <87vdzgik9j.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch adds a new (sub-)command, vgreduce --consolidate, that is a safer
(and now preferred) variant of vgreduce --removemissing, that will only bring
volume group back from partial mode if that does not compromise any logical
volumes residing there (ie. those having extents on missing PVs).

Users should probably use lvremove and lvconvert --repair to get rid of logical
volumes residing on missing PVs (or let dmeventd sort out the latter). The
possibility to use --removemissing is of course still there as well.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgreduce-consolidate.diff
Type: text/x-diff
Size: 6205 bytes
Desc: vgreduce-consolidate.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080708/d5650de4/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
