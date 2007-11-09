From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 09 Nov 2007 11:40:52 -0500
Subject: [PATCH] Remove uninitialized cow if snapshot creation fails
Message-ID: <47348D94.3090603@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Similar to the mirror log cleanup, snapshot cow also should be
removed if the snapshot creation fails.

# dmsetup create --notable testvg-lvol1-cow
# lvcreate -s -l1 -n lvol1 testvg/lvol0
  /dev/testvg/lvol1: not found: device not cleared
  Aborting. Failed to wipe snapshot exception store. Remove new LV and retry.
# lvs
  LV    VG     Attr   LSize Origin Snap%  Move Log Copy% 
  lvol0 testvg -wi-a- 4.00M
  lvol1 testvg -wi--- 4.00M

Attached patch removes the incomplete COW LV if the snapshot
creation fails.

A test script is also attached.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-cleanup-cow-on-init-failure.patch
Type: text/x-patch
Size: 2476 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071109/a2fa5ee8/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: cleanup-lvcreate-snapshot.sh
Type: application/x-sh
Size: 1477 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071109/a2fa5ee8/attachment.sh>
