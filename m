From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 17:13:57 -0400
Subject: [PATCH LVM2] (9/12) lvconvert to use build_parallel_areas_from_lv()
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <45300195.3020801@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch uncomments the use of build_parallel_areas_from_lv() by lvconvert.
Based on other patches, it works now.


$ diffstat -p1 09.lvconvert.patch
 tools/lvconvert.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 09.lvconvert.patch
Type: text/x-patch
Size: 991 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/132a36de/attachment.bin>
