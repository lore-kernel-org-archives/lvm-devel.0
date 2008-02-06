From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 06 Feb 2008 16:55:11 -0500
Subject: [PATCH lvconvert 0/2] Fixes suspend/resume ordering of lvconvert
Message-ID: <47AA2CBF.1060109@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvconvert has problems where 2 active mirror maps coexist
for a short while sharing the same log device.
That is critical to cluster mirror as it detects such situation
but also dangerous to non-clustered mirror.
(A lot of thanks to Jon Brassow for the reports, testings and
analysis from cluster mirror viewpoint)

The problems are:

  1. resume before suspend

      When a layer is inserted beneath a LV, the layer is
      resumed before the LV is suspended.

      I.e. if the LV is active, lvconvert calls suspend_lv() for
      the LV to suspend the LV preparing for the update:

        suspend_lv()
          _lv_suspend()
            _lv_preload()
              dev_manager_preload()
                dm_tree_preload_children()
                  Load tables for devices from bottom to top.
                  If a device has parents, resume the device, too.
            _lv_suspend_lv()
              dev_manager_suspend()

      However, before actually suspend the LV, suspend_lv() will end
      up calling dm_tree_preload_children() that involves resuming
      of the layer.

  2. off-tree device not updated

      When a layer is removed, a new table of "error" target
      is not loaded/resumed for the layer during the update
      of the LV.
      So the layer continues to have the old table.

        _remove_mirror_images()
          remove_layer_from_lv()
            Update the in-memory VG metadata.
            The layer is no longer a part of the LV in the metadata.
          vg_write()
            The metadata is pre-committed.
          suspend_lv()
          vg_commit()
            The metadata is committed.
          resume_lv()
            Load new tables based on the new metadata and resume.
            It doesn't load a new table for the layer.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-bad.log
Type: text/x-log
Size: 228564 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080206/402cb516/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-good.log
Type: text/x-log
Size: 230023 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080206/402cb516/attachment-0001.bin>
