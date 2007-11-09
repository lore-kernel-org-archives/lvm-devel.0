From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 09 Nov 2007 11:40:18 -0500
Subject: [PATCH] Remove leftover mirror log on creation failure
Message-ID: <47348D72.2050902@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When a creation of mirrored LV fails during its course,
mirror log LV is left unremoved.
The patch removes the log LV if error occurs after commiting it.

# dmsetup create --notable testvg-lv0_mlog
# lvcreate -l1 -m1 -nlv0 testvg
  device-mapper: create ioctl failed: Device or resource busy
  Aborting. Failed to activate mirror log. Remove new LVs and retry.
  Failed to create mirror log.
# lvs -a
  LV       VG     Attr   LSize Origin Snap%  Move Log Copy% 
  lv0_mlog testvg -wi-d- 4.00M

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-cleanup-mlog-on-failure.patch
Type: text/x-patch
Size: 2283 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071109/6cb2456a/attachment.bin>
