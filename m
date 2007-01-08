From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 08 Jan 2007 12:12:08 -0500
Subject: [LVM2 PATCH] (5/5) Remove ix_offset
In-Reply-To: <45A2751E.5010707@ce.jp.nec.com>
References: <45A2751E.5010707@ce.jp.nec.com>
Message-ID: <45A27B68.4030409@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In _find_parallel_space(), ix_offset is used as a separator of
the areas[] array:
  - 0--ix_offset : used for contiguous/cling allocation
  - ix_offset--areas_size : used for other allocation

Since the both uses are exclusive, there is no need to use ix_offset.
ix can be used to count the number of areas found suitable for
the allocation.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 05-remove-ix_offset.patch
Type: text/x-patch
Size: 3520 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/fceb7a35/attachment.bin>
