From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:49:14 -0500
Subject: [PATCH 10/11] Fix _remove_mirror_images() to cope with stacked mirror
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <4788007A.2020108@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

remove_mirror_images() has a feature to select mimage LV(s) to be
removed (with 'removable_pvs' param).
e.g. 'lvconvert -m-1 vg/lvol1 /dev/sdc /dev/sdd' removes a mirror image
     that doesn't use PVs other than /dev/sdc and /dev/sdd.

But it doesn't work properly if the LV is stacked.
  - Even if no LVs were removed, remove_mirror_images() should walk down
    the stack and retry because it may have LVs matching 'removable_pvs'.
    To allow that, _remove_mirror_images() should return how many LVs are
    removed and distinguish failure vs. 0-removal.
  - If the mimage is a temporary one ("*_mimagetmp_<n>"), don't remove.
  - If a temporary LV becomes single area as a result of removal,
    it should still be a "mirror" to keep log_lv and region_size.
    collapse_mirrored_lv() will take care of reconfiguration.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-remove_mirror_images-for-removable_pvs.patch
Type: text/x-patch
Size: 6599 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/b8215336/attachment.bin>
