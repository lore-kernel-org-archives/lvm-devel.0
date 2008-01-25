From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 25 Jan 2008 15:58:21 -0500
Subject: [PATCH 1/3] Fix 'lvchange --resync'
Message-ID: <479A4D6D.10506@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix 'lvchange --resync' breakage (since 2.02.30)

# lvchange --resync vg/lv
  LV lv_mlog is used by LV lv:0, but missing ptr from lv to lv_mlog
  Internal error: LV segments corrupted in lv_mlog.
  Failed to write intermediate VG metadata.

When changing seg->log_lv, it needs to do corresponding
add_seg_to_segs_using_this_lv/remove_seg_from_segs_using_this_lv.
Without them, the metadata validator will detect inconsistency
and report like the above.

Attached patch fixes the issue.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-lvchange-resync.patch
Type: text/x-patch
Size: 1515 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080125/ee9d7fe7/attachment.bin>
