From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 21 Aug 2007 17:31:39 -0400
Subject: [LVM2 PATCH] (4/5) Remove unused parameters from allocate_extents() [resending with the patch]
Message-ID: <46CB59BB.7070103@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

[Resending with the patch.]

This patch removes unused 'status' parameter from allocate_extents().

Guessing from the lv_extend(), 'status' is related to lv->status.
However, allocate_extents() only allocates extents.
Mapping extents to LV segment is done in other functions.
So the parameter seems no use in future, too.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-allocate-remove-unused-status-arg.patch
Type: text/x-patch
Size: 2931 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070821/b569e3b5/attachment.bin>
