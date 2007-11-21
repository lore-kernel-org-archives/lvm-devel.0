From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 16:24:46 -0500
Subject: [PATCH pvmove 1/3] remove pvmove-specific params from allocation code
Message-ID: <4744A21E.7090601@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This set of patches changes pvmove to use more generalized
allocation code and logic.
The approach might be adaptible to other intermediate layer
manipulation.
Please let me know if this approach is acceptable or not.

[1/3] remove pvmove-specific params from allocation code
[2/3] support splitted destinations of pvmove
[3/3] use generic mirror allocation for pvmove

This 1st patch is basically a repost of the patch posted August:
https://www.redhat.com/archives/lvm-devel/2007-August/msg00068.html
with a few edits to comments, variable names, etc.

The patch is a preparation for other pathes in this series.
This patch removes most of pvmove specific codes from extent allocation
code without affecting the functionality.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-pvmove-cleanup-lv_extend.patch
Type: text/x-patch
Size: 12398 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/1e42b778/attachment.bin>
