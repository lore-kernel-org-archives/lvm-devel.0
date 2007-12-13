From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 15:40:51 -0500
Subject: [PATCH pvmove 0/9] Refactoring pvmove with generic APIs (rev. 3)
Message-ID: <476198D3.1080003@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patchset is a follow up to the previous posts:
https://www.redhat.com/archives/lvm-devel/2007-November/msg00034.html
https://www.redhat.com/archives/lvm-devel/2007-December/msg00010.html

I found that I didn't generalize the removal-side of pvmove code.
This version adds generic APIs for removing mirrors and layers
for segment-by-segment mirroring.

So we have:
  - insert_layer_for_segments_on_pv()
      Insert a layer (a linear lv segment) below each lv segment
      of the LV, only when the segment is on a specified PV.
  - remove_layer_for_segments_all()
      Remove the layer from all LVs

  - split_parent_segments_for_layer()
      For a given layer LV, walk through LVs in the VG and split
      any LV segment whose underlying layer segment is splitted.

  - add_mirrors_to_segments()
  - remove_mirrors_from_segments()
      Add mirrors to each segment of the LV

I'll follow up this patchset with generic APIs for lvconvert-type
mirroring, i.e. mirroring as a whole LV.

The 7th to 9th patches are newly added.
Other patches are slightly modified to cope with the name changes
and also for better comments, error messages and generalization.
It might be better to move new ones to earlier part and change
pvmove at once. But I kept the ordering for ease of the reviews.
Changes are mentioned in the header of each patch.

[1/9] add insert_layer_for_segments_on_pv()
[2/9] add add_mirrors_to_segments()
[3/9] add split_parent_segments_for_layer()
[4/9] change pvmove to use the generalized APIs
[5/9] remove unused mirrored_pv/mirrored_pe params from internal code
[6/9] remove unused can_split param from allocate_extents()
[7/9] add remove_mirrors_from_segments() and remove_layer_from_segments()
[8/9] change pvmove to use the generalized removal APIs
[9/9] remove unused remove_pvmove_mirrors() function
[Appendix] pvmove test script for 'make check'

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


