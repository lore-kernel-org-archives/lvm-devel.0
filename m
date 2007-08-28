From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 28 Aug 2007 14:51:51 -0400
Subject: [LVM2 PATCH] Broken "--corelog" option in lvcreate/lvconvert
Message-ID: <46D46EC7.5020907@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

In 2.02.28, "--corelog" option is just broken.

# lvcreate -m1 -l1 --corelog testvg
  --mirrorlog disk and --corelog are incompatible

# lvcreate -l1 -n lv0 testvg; lvconvert -m1 --corelog testvg/lv0
  Logical volume "lv0" created
  --mirrorlog disk and --corelog are incompatible

I guess this is not an intended behavior.

Attached patch will fix it.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-fix-lvcreate-corelog.patch
Type: text/x-patch
Size: 3385 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070828/02c9a8d4/attachment.bin>
