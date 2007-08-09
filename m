From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 09 Aug 2007 13:54:41 -0400
Subject: [LVM2 PATCH] (2/3) Check cow != origin in vg_add_snapshot() library call
Message-ID: <46BB54E1.7060105@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is a similar check to the previous patches
in library function: vg_add_snapshot().

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-snapshot-check-cow-origin-not-same.patch
Type: text/x-patch
Size: 617 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/46bcd0de/attachment.bin>
