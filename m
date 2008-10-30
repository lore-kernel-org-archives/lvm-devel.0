From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 19:08:20 +0100
Subject: [PATCH] (6/11) re-introduce vg_read
Message-ID: <87abcm3qi3.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch gets us back a function called vg_read, but this time it also does
locking -- by default it grabs a read lock, as vg_read_for_update should be
used when write lock is desired.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-new-vg_read.diff
Type: text/x-diff
Size: 3807 bytes
Desc: lvmlib-vg_read.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/e9b15a03/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
