From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:05:08 -0500
Subject: [PATCH lvconvert 0/6] Refactoring lvconvert mirror
Message-ID: <47619E84.2060905@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patchset refactors lvconvert mirror.
The patches are applicable on top of the pvmove refactoring patches.
https://www.redhat.com/archives/lvm-devel/2007-December/msg00020.html

I would like to know whether this changes are acceptable.
I guess there might be other needs for layer insertion/removal
APIs. Comments are welcome.
If they looks ok, I'll convert add-mirror-to-mirror patches based
on this.

The patches add following APIs:
  - lv_add_mirrors(), lv_remove_mirrors()
      Generic APIs for lvconvert mirror.
      Having 2 modes of conversion: MIRROR_BY_SEG and MIRROR_BY_LV.
      MIRROR_BY_LV is for the current version of lvconvert,
      i.e. mirroring by mimage LVs.
      MIRROR_BY_SEG is for the current version of pvmove,
      i.e. mirroring segment by segment.
  - add_mirror_images()
      Add mirrors (mimage LVs) to LV.
      The counter part of existing remove_mirror_images().
      Wrapped by lv_add_mirrors().
  - add_mirror_log(), remove_mirror_log()
      Simplified version of the APIs specific to add/remove disk log.
  - lv_mirror_count()
      Returns the number of mirrors
  - insert_layer_for_lv(), remove_layer_from_lv()
      Insert a layer on top of the LV and remove it.

Then, lvconvert, lvcreate and pvmove are converted to use them.

The patchset also includes an experimental patch to allow
  - lvcreate/lvconvert to create segment-by-segment mirrored LV
  - pvmove to use disk log

[1/6] add insert_layer_for_lv() / remove_layer_from_lv()
[2/6] add add_mirror_images(), {add,remove}_mirror_log()
[3/6] change lvconvert to use the new APIs
[4/6] change lvcreate to use the new APIs
[5/6] remove unused mirror functions
[6/6] add and convert tools to use lv_{add,remove}_mirrors()
[Appendix] experimental: pvmove with disk log and seg-by-seg mirror LV

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


