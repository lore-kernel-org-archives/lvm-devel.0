From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:44:50 -0500
Subject: [PATCH 2/11] Add upward link from underlying LV to stacked seg
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <4787FF72.9000400@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As a part of LV stacking support, this patch
adds a upward link from underlying LV to LV segments
using the LV.

There used to be 'seg->mirror_seg' specialized for
mimage/mlog to mirrored LV relationship.
They will be replaced with the generalized link, too.


Stacking is done like this:
   +--------------------------+
   |          LV0             |
   +--------------------------+
   |SEG01|SEG02|SEG03| ...    |
   +--------------------------+
   |          LV1             |
   +--------------------------+
   |SEG11|SEG12|SEG13| ...    |
   +--------------------------+
(This figure might be over simplified.
 The LV-LV relationship is not necessarily 1:1.
 The point is they are stacked as lv-seg-lv-seg-...)

Downward links:
  - lv-to-seg (e.g. LV0 -> SEG0x, LV1 -> SEG1x) => lv->segments 
  - seg-to-lv (e.g. SEG0x -> LV1)               => seg_lv(seg, s)
Upward links:
  - lv-to-seg (e.g. LV1 -> SEG0x)               => N/A
  - seg-to-lv (e.g. SEG0x -> LV0, SEG1x -> LV1) => seg->lv

This patch adds lv-to-seg upward link, lv->segs_using_this_lv.

The patch also replaces seg->mirror_seg with this.
mirror_seg was seg-to-seg link, i.e. with the above example, SEG1x -> SEG0x.
However, it's been used only when LV0 has 1 segment.
So the conversion is straight-forward.

For segment areas, the linking/unlinkg of the LV to the seg is
automatically done with set_lv_segment_area_lv()/release_lv_segment_area().
For other relation ships (e.g. log_lv), the linking/unlinking should done
explicitly using lv_add_user_seg()/lv_remove_user_seg().

find_parent_for_layer() is removed.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: stacked-lv-generalized-upward-link.patch
Type: text/x-patch
Size: 18230 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/fc84daea/attachment.bin>
