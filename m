From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 28 Aug 2007 14:57:01 -0400
Subject: [LVM2 PATCH] Fix "--log" in lvcreate/lvconvert man pages
Message-ID: <46D46FFD.1070502@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This is a minor bug fix in lvcreate/lvconvert man pages.

"--log" was changed to "--mirrorlog".
But it still remains in man pages.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-fix-man-mirrorlog.patch
Type: text/x-patch
Size: 2046 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070828/7903283e/attachment.bin>
