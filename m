From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 09 Aug 2007 13:54:35 -0400
Subject: [LVM2 PATCH] (1/3) Check cow != origin in commands
Message-ID: <46BB54DB.5010608@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Currently we can do this strange thing:
  # lvconvert -s testvg/lvol0 testvg/lvol0
  Logical volume lvol0 converted to snapshot.

It means testvg/lvol0 is both origin and cow of the snapshot.

Once we create such a LV, we cannot remove it.

lvconvert should check its parameter and
the attached patch does it.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvconvert-snapshot-not-to-accept-origin-for-cow.patch
Type: text/x-patch
Size: 686 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/2a89f3e9/attachment.bin>
