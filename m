From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:03:30 -0500
Subject: [PATCH pvmove 1/9] Add insert_layer_for_segments_on_pv()
In-Reply-To: <476198D3.1080003@ce.jp.nec.com>
References: <476198D3.1080003@ce.jp.nec.com>
Message-ID: <47619E22.9020808@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add insert_layer_for_segments_on_pv().

The function can be used to insert a layer below the LV,
only for the segments on a specified PV.

Part of the code is derived from pvmove.

Changes since rev2:
  * Use move_lv_segment_area() for layer insertion
  * Add error message for insert_layer_for_segments_on_pv()
  * Use PRIu32 instead of "%u"
  * Replace 'stack; return 0;' with 'return_0;'
  * Changed internal function names to more specific ones
      - _extend_layer_lv() -> _extend_layer_lv_for_segment()
      - _seg_pv_match() -> _match_seg_area_to_pe_range()
      - _align_segment_boundary() -> _align_segment_boundary_to_pe_ranges()

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-insert-layer-for-segments.patch
Type: text/x-patch
Size: 7033 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/2f17f147/attachment.bin>
