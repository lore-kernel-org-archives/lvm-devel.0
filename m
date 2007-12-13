From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:03:37 -0500
Subject: [PATCH pvmove 3/9] Add split_parent_segments_for_layer()
In-Reply-To: <476198D3.1080003@ce.jp.nec.com>
References: <476198D3.1080003@ce.jp.nec.com>
Message-ID: <47619E29.2050407@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add split_parent_segments_for_layer().

The function walks through LVs in the VG.
For each lv segment, check if it's on multiple layer segments.
If so, split the lv segment so that only 1 layer segment is under
the lv segment.

For example, a segment on pvmove layer is a source segment of the move.
If there are multiple underlying pvmove segments, it means the
destination is splitted and the source segment should be splitted
when the move completes.
The function is a helper for cases like this.

Changes since rev2:
  * Changed function names to more specific ones
      - split_parent_segments() -> split_parent_segments_for_layer()
      - _split_parent_segment() -> _split_parent_area()
  * Added cmd_context argument to split_parent_segments_for_layer.
  * Use build_parallel_areas() to find the lowest-level segment boundaries
    for layer LV.
  * Introduced _find_seg_pvs_by_le().
  * Add incompatible boundary check in _split_parent_area()
    (e.g. the layer segments are mistakenly merged.)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-split-parent-segments.patch
Type: text/x-patch
Size: 4427 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/a88849a6/attachment.bin>
