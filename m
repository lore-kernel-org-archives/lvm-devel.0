From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 08 Jan 2007 12:09:53 -0500
Subject: [LVM2 PATCH] (0/5) Fix mirror log allocation
Message-ID: <45A27AE1.7030508@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair, Jonathan,

This series of patches fix the following mirror log allocation
problem:
  1. lvconvert from linear to mirror can allocate log device
     from the same PV as mirror images
  2. lvconvert from corelog to disklog can allocate log device
     from the same PV as mirror images
  3. "--alloc anywhere" doesn't help mirror log allocation
     when the number of available PVs are equal to the number of
     mirror images, though lvcreate/lvconvert suggest to try it.

Patches are applicable to and tested on LVM2 2.02.17.
Please consider to apply.


The first 2 problems happen because of the wrong application
of parallel area constraint. The constraint should be:
  - mirror image should avoid PVs used by the parallel areas of
    the matching range of LE
  - mirror log should avoid PVs used by the parallel areas of
    the whole range of the LV
However, current code applies the first constraint for both
mirror log and mirror images.
So the log allocation avoids only the areas parallel to LE:0:1.

To apply the different constraints effectively, this patch set
makes the allocation done in 2 steps.
  1. do log allocation
  2. do mirror image allocation

As a result of this, the 3rd problem is fixed as well.

The patches are:
  1. Rearrange _alloc_parallel_areas() and moves out log allocation
     part as a separate function.
  2. Fix handling of log-only allocation failure.
  3. Changes _find_parallel_space() to do log allocation first.
  4. Removing unnecessary prev_lvseg checks.
  5. Removing ix_offset variable.

3 is the core part of this fix.
1 and 2 are preparation for it.
4 and 5 are cleaning up of the related codes.


Reproducible test scripts and corresponding metadatas are attached.

The test scripts automatically set up loop-back device and test
PVs and VG on it. You might want to change vgname defined in
the top of the script.
Then, you can just run it as:
  # sh testcase-lvconvert-linear-mirror-multiseg.sh
  ...
    LV             Devices                         SSize
    lv0            lv0_mimage_0(0),lv0_mimage_1(0) 196.00M
    [lv0_mimage_0] /dev/mapper/d1(24)              100.00M
    [lv0_mimage_0] /dev/mapper/d2(24)               96.00M
    [lv0_mimage_1] /dev/mapper/d3(0)               100.00M
    [lv0_mimage_1] /dev/mapper/d4(0)                96.00M
    [lv0_mlog]     /dev/mapper/d2(0)                 4.00M
  ...
  ERROR: /dev/mapper/d2 is used in both testvg/lv0_mlog and testvg/lv0_mimage_0
  ERROR: /dev/mapper/d2 is used in both testvg/lv0_mimage_0 and testvg/lv0_mlog
  Number of failures: 2
  FAIL

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: testcase-lvconvert-addlog-multiseg.sh
Type: application/x-sh
Size: 2746 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/8e2a98e9/attachment.sh>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: testcase-lvconvert-linear-mirror-multiseg.sh
Type: application/x-sh
Size: 3061 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/8e2a98e9/attachment-0001.sh>
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: testcase-lvconvert-addlog-multiseg.vg
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/8e2a98e9/attachment.ksh>
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: testcase-lvconvert-linear-mirror-multiseg.vg
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/8e2a98e9/attachment-0001.ksh>
