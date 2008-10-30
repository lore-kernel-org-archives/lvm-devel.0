From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 18:56:09 +0100
Subject: [PATCH] (3/11) introduce vg_read_for_update
Message-ID: <87r65y3r2e.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is mostly the initial implementation of vg_read_for_update, that will
later be used for most cases where vg_read is called with the intention of
updating the VG and writing it out again. Implies various requirements that
updates usually have.

Yours,
   Petr.

PS: I have noticed a slight forward-dependence of this patch -- ORPHAN_LOCK is
defined I believe in one of the later patches.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-vg_read_for_update.diff
Type: text/x-diff
Size: 6701 bytes
Desc: lvmlib-vg_read_for_update.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/4ff05954/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
