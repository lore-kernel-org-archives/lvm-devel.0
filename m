From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 21 Aug 2007 17:25:18 -0400
Subject: [LVM2 PATCH] (5/5) Remove pvmove special casing from lv_extend/allocate_extents
Message-ID: <46CB583E.50905@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch removes pvmove special parameters from lv_extend() and
allocate_extents().

These special parameters are passed to them so that lv_extend()
can use them as the 1st area (i.e. master mirror).
However, without this parameter, pvmove can do allocate_extents()
and then call lv_add_segment() by itself.

We could further eliminate the special parameters from lv_add_segment()
by splitting the parts to something like lv_add_pvmove_segment(),
if it's preferred.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-pvmove-cleanup.patch
Type: text/x-patch
Size: 12450 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070821/e98c6979/attachment.bin>
