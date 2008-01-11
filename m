From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:22:15 -0500
Subject: [PATCH 0/11] updates to stacking and lvconvert
Message-ID: <4787FA27.8050300@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

These patches do followings:

  - Change default behavior of lvconvert
    [ 1/11] lvconvert takes '--wait' instead of '--background'

  - Add generalized upward link from LV to seg
    [ 2/11] Add upward link from underlying LV to stacked seg

  - Cosmetic changes for later bugfixes
    [ 3/11] Move mirror log initialization functions
    [ 4/11] Move _find_tmp_mirror()
    [ 5/11] Move removable_pvs checking

  - Fix mirror log addition/removal for LV under conversion
    [ 6/11] Export find_tmp_mirror()
    [ 7/11] lvconvert adds/removes mirror log to/from the original LV

  - Fix remove_mirror_images()
    [ 8/11] Allow "mirror" segment with only 1 area
    [ 9/11] _init_mirror_log() to cope with activation status
    [10/11] Fix _remove_mirror_images() to cope with stacked mirror
    [11/11] Fix _remove_mirror_images() to skip AREA_LV

  - Appendix: 2 test scripts for mirroring

Since the last week's patchset,

> Other things I would like to work on next are:
>   - Generalization of seg->mirrored_seg as upward link
>     from LV to seg(s) which use the LV.

Done with the patch "2/11" of this series.

>   - Review and fix remove_mirror_images() so that 'removable_pvs'
>     filtering works on stacked mirror.

remove_mirror_images() didn't work nicely with non-empty
removable_pvs.
Fixed by patches "8/11" - "11/11".

>   - Review the suspend code path. I think 'noflush' should be
>     avoided for lower-level mirrors. Otherwise the upper-level mirror
>     can't suspend.

This was not a problem.

>   - Remaining patches from the last post:
>     https://www.redhat.com/archives/lvm-devel/2007-December/msg00045.html
>      [11/13] Add 'lv_mirrors' field to reporting functions
>      [12/13] Remove hardcoded "_mlog" name from deptree construction
>      [13/13] Allow disk logs for temporary resync mirror
>   - Creating a script for 'make check'

-- 
Jun'ichi Nomura, NEC Corporation of America


