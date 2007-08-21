From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 21 Aug 2007 18:59:19 -0400
Subject: [LVM2 RFC PATCH] Tidy extent-related variables in allocation code
Message-ID: <46CB6E47.7040403@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch is rfc, not very well tested yet.

Current allocation code is very hard to read and I think
part of the reason is the ambiguity of 'extents' variables.
Some are length of LV, others are the number of extents.
It makes the code prone to introduce errors.

For example, in _find_parallel_space(), this code:
       if (needed - *allocated > free_pes) {
                log_error("Insufficient free space: %" PRIu32
                            " extents needed,"
                            " but only %" PRIu32 " available",
                            needed - *allocated, free_pes);
checks the free physical extents.
But since 'needed' and 'allocated' are the length of LV,
the comparison doesn't work as expected if the LV is mirrored
because 1-extent of n-way mirrored LV requires n-extents.

I would like to know if the idea of renaming makes sense
and if there are better names of variables and conversion functions.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-allocate-rename-extents-variables.patch
Type: text/x-patch
Size: 13552 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070821/3ec4c7c3/attachment.bin>
