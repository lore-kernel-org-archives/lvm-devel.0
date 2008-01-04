From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:12:25 -0500
Subject: [PATCH lvconvert 4/11] Fix possible mirror image corruption
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4CD9.10202@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

collapse_mirrored_lv() is a function to move mimage LVs from
temporary sync layer to the original LV after sync completion.
However, the code did resume_lv between the removal of mimage LVs
and addition of them. As a result, it's possible to make the
mimage LVs out-of-sync while mirror log says in-sync.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-atomic-remove-and-merge.patch
Type: text/x-patch
Size: 5279 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/e6a4d298/attachment.bin>
