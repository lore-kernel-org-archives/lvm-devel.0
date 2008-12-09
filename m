From: Petr Rockai <prockai@redhat.com>
Date: Tue, 09 Dec 2008 17:44:46 +0100
Subject: [PATCH] (1/2) new library interface for vg_read
Message-ID: <87y6ypcn7l.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is history-collapsed version of the previous vg_read patches. This portion
just adds new APIs (it also contains the fixes proposed in the ongoing review
process). Applying this patch should obtain you a compilable and workable
version of LVM. The tools are patched to use vg_read_internal, which is just
rename of previous vg_read. The followup patch will change those
vg_read_internal's to use the new API instead.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-vg_read-lib.diff
Type: text/x-diff
Size: 22578 bytes
Desc: lvm2-vg_read-lib.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081209/30e8d514/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
