From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 06 Dec 2007 11:49:53 -0500
Subject: [PATCH pvmove 3/6] Add split_parent_segments()
In-Reply-To: <475825EF.6000803@ce.jp.nec.com>
References: <475825EF.6000803@ce.jp.nec.com>
Message-ID: <47582831.3020607@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add split_parent_segments().

The function walks through LVs in the VG.
For each lv segment, check if it's on multiple layer segments.
If so, split the lv segment so that only 1 layer segment is under
the lv segment.

For example, a segment on pvmove layer is a source segment of the move.
If there are multiple underlying pvmove segments, it means the
destination is splitted and the source segment should be splitted
when the move completes.
The function is a helper for cases like this.

This is a generalized version of _split_source_lv_segment()
in the previous post:
https://www.redhat.com/archives/lvm-devel/2007-November/msg00035.html

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-split-parent-segments.patch
Type: text/x-patch
Size: 2778 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071206/b4dae9e4/attachment.bin>
