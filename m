From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 27 Jul 2007 11:32:48 -0400
Subject: [LVM2 PATCH 1/2] lvrename: factor out core routine
Message-ID: <46AA1020.8060600@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch factors out core renaming function from lvrename()
as a preparation for mirrored LV renaming.

No functional change except for the order of the validity check.
It used to be:
  - check if the new name is not yet used in the VG
  - check if the old name really exists in the VG
This order is now reversed.
As the VG is locked, it should have no problem.

Also the following cleanups are included:
  - converting "stack; return 0;" to "return_0"
  - removing duplicated mirrored LV check
    (there were 2 identical checks)

Applicable to the CVS head.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvrename-extract-core-routine.patch
Type: text/x-patch
Size: 3922 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070727/822ec4f2/attachment.bin>
