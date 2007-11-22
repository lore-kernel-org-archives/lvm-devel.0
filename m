From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 20:45:24 -0500
Subject: [PATCH mirror 0/13] Add/collapse temporary mirror
Message-ID: <4744DF34.7090701@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This set of patches allows mirror addition to mirrored LV.

[ 1/13] Enable mirror-addition to lvconvert
[ 2/13] Move idiomatic vg write/lv suspend/vg commit/lv resume
         to a function
[ 3/13] Move idiomatic add-lv-to-list operation to a function
[ 4/13] Add 'const' for some mirror related functions
[ 5/13] Add collapsing feature of stacked mirror
[ 6/13] Count the correct number of mirror images
[ 7/13] Fix lvconvert to use collapsing and mirror counting
[ 8/13] Allow removal of mirror images from not-collapsed mirror LV
[ 9/13] Add 'lv_mirrors' field to report commands
[10/13] Generalize "mlog" handling of dtree
[11/13] Allow multiple mirror logs in the mirror LV tree
[12/13] Allow renaming of mirrored LV with temporary layer
[13/13] Allow resizing of mirrored LV with temporary layer

Comments are welcome.

Especially, patches 1, 5, 8 and 10 are important and reviews
are appreciated.
Patches 2, 3 and 4 are cosmetic.
Patches 6, 9, 11, 12 and 13 are trivial.

Also, I'm using "lv_mimage_<n>" name for temporary layers
because I vaguely remember that naming suffixes like "_mimage_<n>"
are important for clusters.
I would like to use other names for temporary layer,
for example "lv_mtmp_<n>". Is it ok?


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
   `-testvg-lvol0_mlog

'lvconvert -m+1' will result in this:
  testvg-lvol0
   |-testvg-lvol0_mimage_3
   |-testvg-lvol0_mimage_2
   |  |-testvg-lvol0_mimage_1
   |  |-testvg-lvol0_mimage_0
   |  `-testvg-lvol0_mlog
   `-testvg-lvol0_mlog_0

"mimage_2" is a temporary layer to resync "mimage_3".

'lvs -o mirrors testvg/lvol0' will show "3" as a number of mirror images.

After the resync completes, 'lvconvert --collapse testvg/lvol0' will
change the LV to this form:
  testvg-lvol0
   |-testvg-lvol0_mimage_3
   |-testvg-lvol0_mimage_1
   |-testvg-lvol0_mimage_0
   `-testvg-lvol0_mlog

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


