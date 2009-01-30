From: Petr Rockai <prockai@redhat.com>
Date: Fri, 30 Jan 2009 11:10:03 +0100
Subject: [PATCH] lvconvert --repair
Message-ID: <87skn1p0jo.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this has fallen through the cracks again. I have dusted the patch and fixed
some bugs in it. Since it is prerequisite to automatic hotspare migration of
LVM mirrors (bz 186437), Tom has asked me to give priority to this.

The first patch is just a few minor bits in the testing infrastructure, not
overly important (but it is needed for the new t-lvconvent-repair.sh testcase
to pass, due to vgreduce --removemissing return code).

The second patch does the actual implementation. It should be up to date with
CVS as of today. It should be relatively straightforward, although it did
require adding MISSING_PV checks to some places that were missing them (it's
been harmless till now, since no allocation was ever done on VGs with PVs
missing, but it's crucial for lvconvert --repair).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-minor-fixes.diff
Type: text/x-diff
Size: 3353 bytes
Desc: lvm2-minor-tests-fixes.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090130/a9737603/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvconvert-repair.diff
Type: text/x-diff
Size: 15543 bytes
Desc: lvm2-lvconvert-repair.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090130/a9737603/attachment-0001.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
