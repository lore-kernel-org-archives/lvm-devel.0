From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 12:34:52 -0500
Subject: [PATCH mirror 0/13] Stacking and collapsing mirror (rev. 2)
Message-ID: <476AA7BC.9080708@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This set of patches allows mirror addition to mirrored LV.

The patchset is an updated version of this one:
[PATCH mirror 0/13] Add/collapse temporary mirror
https://www.redhat.com/archives/lvm-devel/2007-November/msg00040.html

Changes:
  - rebased to the CVS head, which contains most of the latest
    pvmove/lvconvert patchset

[ 1/13] Add 'const' for mirror-related functions
[ 2/13] Misc fixes to the 'lvconvert' generalization
[ 3/13] Enable layer specification in remove_layer_from_lv()
[ 4/13] lv_rename() to walk down the stacked LV
[ 5/13] lv_mirror_count() to cope with stacked mirror
[ 6/13] remove_mirror_images() to cope with stacked mirror
[ 7/13] lv_extend() to cope with stacked mirror
[ 8/13] lvconvert to stack a temporary resync mirror  on addition
[ 9/13] Add collapsing feature for stacked mirror
[10/13] Add '--collapse' option to lvconvert
[11/13] Add 'lv_mirrors' field to reporting functions
[12/13] Remove hardcoded "_mlog" name from deptree construction
[13/13] Allow disk logs for temporary resync mirror

Comments are welcome.


Overview of the patches
--------------------------

Current LVM2 mirror doesn't allow mirror addition to already
mirrored LV.
It's not possible to simply add mirror image to the existing LV
because it will result in full resync even if existing images are
already in sync.

With this patchset, a temporary mirror layer is inserted.

For example, if we have the mirrored LV below:
  testvg-lvol0
   |-testvg-lvol0_mimage_1
   |-testvg-lvol0_mimage_0
   `-testvg-lvol0_mlog0

'lvconvert -m+1' will result in this:
  testvg-lvol0
   |-testvg-lvol0_mimage_2
   |-testvg-lvol0_resync0
   |  |-testvg-lvol0_mimage_1
   |  |-testvg-lvol0_mimage_0
   |  `-testvg-lvol0_mlog0
   `-testvg-lvol0_mlog1

"resync0" is a temporary layer to resync "mimage_2".

'lvs -o mirrors testvg/lvol0' will show "3" as a number of mirror images.

After the resync completes, 'lvconvert --collapse testvg/lvol0' will
change the LV to this form:
  testvg-lvol0
   |-testvg-lvol0_mimage_2
   |-testvg-lvol0_mimage_1
   |-testvg-lvol0_mimage_0
   `-testvg-lvol0_mlog0

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


