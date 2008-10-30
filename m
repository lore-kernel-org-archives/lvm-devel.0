From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 19:20:59 +0100
Subject: [PATCH] (8/11) conversion of toollib
Message-ID: <87wsfq2bck.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this here patch converts substantial parts of toollib infrastructure to remove
use of vg_read_internal: the process_each_* functions and friends. It is fairly
boring and laborious. Also, please ignore the little bit of conflict markup in
the metadata.c bit of the patch, it so happens that the conflict resolution
ended up there -- a later patch will give the "right" change instead.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-toollib.diff
Type: text/x-diff
Size: 25744 bytes
Desc: lvmlib-toollib.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/9ee0a4dc/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
