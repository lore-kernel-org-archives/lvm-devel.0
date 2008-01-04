From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 09:55:20 -0500
Subject: [PATCH lvconvert 0/11] Additional fixes and changes to lvconvert restructure
Message-ID: <477E48D8.4050404@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These patchset includes bugfixes and feature updates to
the recently committed lvconvert changes.

Bug fixes
[ 1/11] Correct 'const' for _lv_mimage_in_sync()
[ 2/11] Don't start polldaemon if conversion failed in early stage
[ 3/11] Multiple fixes about to-corelog conversion
[ 4/11] Fix possible mirror image corruption 
[ 5/11] Don't insert temporary layer for corelog mirror
[ 6/11] init_mirror_in_sync(0) for corelog mirror addition
[ 7/11] Fix semantic consistency of mirrorlog option

Feature updates
[ 8/11] Add internal 'CONVERTING' flag for LVs under conversion
[ 9/11] Add a new attr field char for the CONVERTING LV
[10/11] Warn if lvconvert needs activation to complete conversion
[11/11] Start lvconvert polldaemon on activation (like pvmove)

Other things I would like to work on next are:
  - Generalization of seg->mirrored_seg as upward link
    from LV to seg(s) which use the LV.
  - Review and fix remove_mirror_images() so that 'removable_pvs'
    filtering works on stacked mirror.
  - Review the suspend code path. I think 'noflush' should be
    avoided for lower-level mirrors. Otherwise the upper-level mirror
    can't suspend.
  - Remaining patches from the last post:
    https://www.redhat.com/archives/lvm-devel/2007-December/msg00045.html
     [11/13] Add 'lv_mirrors' field to reporting functions
     [12/13] Remove hardcoded "_mlog" name from deptree construction
     [13/13] Allow disk logs for temporary resync mirror
  - Creating a script for 'make check'

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


