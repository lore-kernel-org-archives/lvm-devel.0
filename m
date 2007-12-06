From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 06 Dec 2007 11:40:15 -0500
Subject: [PATCH pvmove 0/6] Refactoring pvmove with generic APIs
Message-ID: <475825EF.6000803@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patchset is a follow up to the previous post:
https://www.redhat.com/archives/lvm-devel/2007-November/msg00034.html

This version introduces 3 APIs and let pvmove use them:
  - insert_layer_for_segments_on_pv()
      Insert a layer (a linear lv segment) below each lv segment
      of the LV, only when the segment is on a specified PV.
  - convert_segments_mirrored()
      Convert each segment in the LV to mirrored.
  - split_parent_segments()
      For a given layer LV, walk through LVs in the VG and split
      any LV segment whose underlying layer segment is splitted.

I'm trying to add functionality for lvconvert, i.e. mirroring
as a whole LV, not segment by segment.
However, it involves moving some codes from toollib to lib and
I think further discussion may be necessary.
And anyway they will be an addition to this patchset.

So I'm posting this set first as they are stable and easy to review.

[1/6] add insert_layer_for_segments_on_pv()
[2/6] add convert_segments_mirrored()
[3/6] add split_parent_segments()
[4/6] change pvmove to use the generalized APIs
[5/6] remove unused mirrored_pv/mirrored_pe params from internal code
[6/6] remove unused can_split param from allocate_extents()
[Appendix] pvmove test script for 'make check'

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


