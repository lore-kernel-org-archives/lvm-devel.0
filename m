From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 16:58:23 -0400
Subject: [PATCH LVM2] (4/12) separate constraints checker from _find_parallel_space()
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <452FFDEF.8070101@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch moves the parts checking constraints out from
_find_parallel_space().

o is_pv_parallel() checks all parallel_areas if the allocation request
  is ALLOC_AVOID_ALL_PARALLEL. (e.g. for log device)

o Others are just moving location.


$ diffstat -p1 04.separate_constraints.patch
 lib/metadata/lv_manip.c |  147 ++++++++++++++++++++++++++++++++++++--------
 1 file changed, 112 insertions(+), 35 deletions(-)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 04.separate_constraints.patch
Type: text/x-patch
Size: 5039 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/6e879ae9/attachment.bin>
