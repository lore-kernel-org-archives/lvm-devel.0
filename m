From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 21 Aug 2007 17:24:55 -0400
Subject: [LVM2 PATCH] (1/5) Fix existing mirrors calculation in lvconvert
Message-ID: <46CB5827.9070300@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch fixes lvconvert_mirrors() to calculate the existing_mirrors
even if the LV is striped.

The bug isn't visible because currently lvconvert restricts the
conversion of striped LV.
However, with this patch, the restriction can be removed.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvconvert-correct-existing-mirror-count.patch
Type: text/x-patch
Size: 1374 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070821/e8f30432/attachment.bin>
