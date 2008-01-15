From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 15 Jan 2008 17:42:02 -0500
Subject: [PATCH 2/11] Add upward link from underlying LV to stacked seg
In-Reply-To: <478D0F80.6080207@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>	<4787FF72.9000400@ce.jp.nec.com>	<20080114225345.GG8075@agk.fab.redhat.com>	<478CE1B1.4070004@ce.jp.nec.com>	<20080115165624.GO8075@agk.fab.redhat.com>
	<478D0F80.6080207@ce.jp.nec.com>
Message-ID: <478D36BA.1020904@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Attached is a revised version of the patch in the subject,
including a fix posted as "12/14" fix-upward-link.patch.
Other patches in the patchset won't be affected.

Changes since the last post:
  * Modified the picture in the patch header
  * Add reference count to 'struct seg_list'
  * Add validation checks in check_lv_segments()
  * Don't add link from mimage to mirror LV in mirror fixup code
  * Add _remove_mirror_log() to properly unlink mirror seg
    from log_lv->segs_using_this_lv, instead of just setting
    seg->log_lv = NULL
  * Change _lv_split_segment() to use set_lv_segment_area_lv()
    instead of directly modifying seg_lv(seg, s)
  * Add error messages in find_mirror_seg()
  * Add error messages in seg_using_lv()
  * Rename lv_{add,remove}_user_seg() and seg_using_lv()

Following issues may need more discussion:

  - Namings of functions to add/remove seg to/from
    lv->segs_using_this_lv.
    For now, I just changed them to descriptive names
      - add_seg_to_segs_using_this_lv()
      - remove_seg_from_segs_using_this_lv()

  - About seg_using_lv().
    Maybe adding is_top_of_the_stack(lv) is better if we would
    like to check it in future.
    For now, seg_using_lv() is really a specialized function
    to check if it has one and only segment and to get it.
    So I didn't change it except for additional error message
    and renaming to a descriptive name to characterize its
    specialty.

  - Duplication check of lv->segs_using_this_lv.
    In theory, it's possible that a LV has multiple references
    from a single segment. (e.g. multiple areas refer the same LV)
    So I added reference count to 'struct seg_list' and the
    validator matches it with actual references as well as checking
    duplications of entries.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: stacked-lv-generalized-upward-link.patch
Type: text/x-patch
Size: 23460 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080115/8b3d8ab9/attachment.bin>
