From: Petr Rockai <prockai@redhat.com>
Date: Tue, 09 Dec 2008 17:47:20 +0100
Subject: [PATCH] (2/2) Patch tools to use the new vg_read APIs
Message-ID: <87tz9dcn3b.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

this should change over uses of now-deprecated vg_read_internal and
vg_lock_and_read to the new vg_read and vg_read_for_update. It is a biggish
patch, but should be well chunk-able, as various parts are mostly independent
of each other.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-vg_read-tools.diff
Type: text/x-diff
Size: 40906 bytes
Desc: lvm2-vg_read-tools.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081209/e3bf4167/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
