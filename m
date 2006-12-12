From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 12 Dec 2006 17:53:58 -0500
Subject: [PATCH LVM2] Guarantee ah->area_multiple non-zero
Message-ID: <457F3306.1070608@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch guarantees ah->area_multiple being non-zero.

Since ah->area_multiple is used everywhere to calculate the length
of allocation, it's safer to set 1 if ah->area_count is zero.
Otherwise, zero division could occur.
For example, ah->area_count can be zero when the allocation request
is only for log device.

It should be reproducible by converting corelog mirror to disklog
mirror. But fortunately or unfortunately, this bug is hidden by
other bug.
(See "[PATCH LVM2] set stripes = 0 for the log device only allocation")

Patch applicable to LVM2 2.02.16.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: guarantee-area_multiple-non-zero.patch
Type: text/x-patch
Size: 1143 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/3d8158be/attachment.bin>
