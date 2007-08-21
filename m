From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 21 Aug 2007 17:25:01 -0400
Subject: [LVM2 PATCH] (2/5) Fix lvconvert to pass correct parameter to allocate_extents()
Message-ID: <46CB582D.9070302@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch fixes lvconvert_mirrors() to pass correct set of
parameters to allocate_extents().

It used to pass (length of LV * number of mirrors) as 'extents'
parameter of allocate_extents().

Though the parameter was wrong, the allocation function somehow
worked because it also passed segtype "striped" instead of "mirror".

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvconvert-fix-wrong-parameter-to-allocator.patch
Type: text/x-patch
Size: 3115 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070821/66811d8b/attachment.bin>
