From: Petr Rockai <prockai@redhat.com>
Date: Tue, 14 Dec 2010 18:32:46 +0100
Subject: [PATCH] Check LV/PV reference consistency in vg_validate
Message-ID: <877hfc6z0h.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch adds further consistency checking to vg_validate
(this time, it ensures that all segment areas point to LVs or PVs that
are listed in the respective VG).

It also fixes pointer bugs in vgsplit and vgmerge that were detected by
these new checks.

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vg_validate-references.diff
Type: text/x-diff
Size: 2774 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101214/e4a37057/attachment.bin>
