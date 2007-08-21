From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 21 Aug 2007 17:25:08 -0400
Subject: [LVM2 PATCH] (3/5) Remove unused parameters from _allocate()
Message-ID: <46CB5834.2030307@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch removes unused 'stripes', 'mirrors', 'status' and
'segtype' parameters from _allocate() in lib/metadata/lv_manip.c.

'stripes' and 'mirrors' can be found in struct alloc_handle.
'status' and 'segtype' aren't there but if future code requires them,
they can be embedded in struct alloc_handle, too.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-allocate-remove-unused.patch
Type: text/x-patch
Size: 1387 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070821/71780ef3/attachment.bin>
