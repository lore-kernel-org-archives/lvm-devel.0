From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 11:00:03 -0500
Subject: [PATCH] Cleanup partial failure of activation
Message-ID: <47445603.1000602@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

If activate_lv() fails, callers won't call deactivate_lv().
However, activate_lv() may succeeded activation partially.

For example, in this case: (with the latest 2.02.29-cvs)
  # dmsetup create --notable vg-lv0_mimage_0
  # lvcreate -l1 -m1 -nlv0 vg

lvcreate fails. "lv0", "lv0_mimage_0", "lv0_mimage_1" and "lv0_mlog"
are once created but removed from the VG metadata. That's ok.
However, maps of vg-lv0 and vg-lv0_mlog remain in kernel.

Attached patch deactivates a partially activated LV so that
callers of activate_lv() don't need to care about partial failure.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: cleanup-partial-activation-failure.patch
Type: text/x-patch
Size: 506 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/5f942175/attachment.bin>
