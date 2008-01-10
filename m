From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 10 Jan 2008 15:36:55 -0500
Subject: [PATCH lvconvert 0/11] Additional fixes and changes to lvconvert restructure
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <478681E7.5040206@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> Other things I would like to work on next are:
..
>   - Review and fix remove_mirror_images() so that 'removable_pvs'
>     filtering works on stacked mirror.

For remove_mirror_images() to properly work with stacked
mirror, I'm going to allow "mirror" segment with 1 area.

'removable_pvs' is used for selectively removing mimage LVs.
Especially, it's important for mirror reconfiguration
after device failure.
However, the current code can't handle the case where
"_mimagetmp" LV turns to become single.

I've been thinking about this situation:

  1 mirror is added to 2-way mirrored LV

      lv0
        +-- lv0_mimagetmp_2
        |      +-- lv0_mimage_0
        |      +-- lv0_mimage_1
        |      +-- lv0_mlog
        +-- lv0_mimage_2

  lv0_mimage_2 is still syncing.
  lv0_mlog contains sync status between lv0_mimage_0 and
  lv0_mimage_1.

If lv0_mimage_1 is removed, what should we do?

What the current code will do is:

      lv0
        +-- lv0_mimagetmp_2
        +-- lv0_mimage_2

Of course, it's not correct.

IMO, first, the lv0_mimage_1 is removed and lv0_mlog is
set to mark in-sync,

      lv0
        +-- lv0_mimagetmp_2
        |      +-- lv0_mimage_0
        |      +-- lv0_mlog
        +-- lv0_mimage_2

then, polldaemon converts it after sync completion,

      lv0
        +-- lv0_mimage_0
        +-- lv0_mimage_2
        +-- lv0_mlog

So in the intermediate state, "mirror" segment will have
only 1 area. There's already a code related to pvmove that
uses "linear" target for "mirror" segment.
It's not enough to convert to "linear" segment because
that makes mirror parameters (log LV, region size, etc.) lost.

>   - Review the suspend code path. I think 'noflush' should be
>     avoided for lower-level mirrors. Otherwise the upper-level mirror
>     can't suspend.

Suspend is done top-down. So 'noflush' should not be a problem.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


