From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 17:00:48 -0400
Subject: [PATCH LVM2] (7/12) update parallel_areas for on-going allocation
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <452FFE80.8010005@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds _update_parallel_areas() to update parallel_areas list
based on the current allocation.

o For some cases (e.g. lvcreate), ah->parallel_areas weren't initialized.
  So now, _alloc_init() initialize it if there is none.
  build_parallel_areas() is allowed to return empty list.

o _update_parallel_areas() and other sub functions are added.
  It takes the range and PV then reflects them into existing parallel_areas.


$ diffstat -p1 07.update_parallel.patch
 lib/metadata/lv_manip.c |  150 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 150 insertions(+)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 07.update_parallel.patch
Type: text/x-patch
Size: 4901 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/9561e3ed/attachment.bin>
