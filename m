From: Milan Broz <mbroz@redhat.com>
Date: Mon, 29 Mar 2010 15:12:53 +0200
Subject: [PATCH 0/5] Fix some scaling problems for large VGs (many LVs)
Message-ID: <cover.1269866168.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patches fixes some problems in code when processing large VGs.

An example: VG with one PVs and 2000LVs
(I was not able to test more LVs without patches, swapped to death...)

# vgs vg_test
  VG      #PV #LV  #SN Attr   VSize  VFree
  vg_test   1 2000   0 wz--n- 18.53g 10.71g

Before (intentionally do not run any in-kernel operations -t test mode):

# time vgchange -t -a n vg_test
  Test mode: Metadata will NOT be updated.
    0 logical volume(s) in volume group "vg_test" now active

    real    9m31.463s
    user    9m29.841s
    sys     0m1.251s

After (patches applied):
# time vgchange -t -a n vg_test
  Test mode: Metadata will NOT be updated.
   0 logical volume(s) in volume group "vg_test" now active

    real    1m22.852s
    user    1m14.805s
    sys     0m7.961s


Memory use (cca, it oscillates according to vg_release) 
before:
root     24664 99.9 17.9 355588 350340 pts/0   R+   14:43   9:34 vgchange -t -a n vg_test
after:
root     31022 98.5  0.2   7736   5084 pts/0   R+   14:57   1:21 vgchange -t -a n vg_test

...

Milan Broz (5):
  Use hash table for quick lv reference when reading metadata.
  Remove vg_validate call when parsing cached metadata.
  Optimise PV segments search.
  Do not traverse PV segment list twice.
  Fix all segments memory is allocated from vg private mempool.

 lib/cache/lvmcache.c          |    3 +-
 lib/format_text/import.c      |    2 +-
 lib/format_text/import_vsn1.c |   42 +++++++++++++++++++++-------
 lib/metadata/lv_manip.c       |    2 +-
 lib/metadata/merge.c          |    4 +-
 lib/metadata/metadata.c       |   12 --------
 lib/metadata/metadata.h       |    3 --
 lib/metadata/pv_alloc.h       |    4 ++-
 lib/metadata/pv_manip.c       |   60 ++++++++++++++++++++++++++++------------
 9 files changed, 81 insertions(+), 51 deletions(-)


