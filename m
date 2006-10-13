From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 16:57:42 -0400
Subject: [PATCH LVM2] (3/12) remove ix_offset from _find_parallel_space()
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <452FFDC6.4030403@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch removes ix_offset and related variables.

o Current code splits areas[] array in 2 parts.
  The first part is for contiguous areas and the 2nd part is for
  sorted-by-length areas.
  However, these 2 use are exclusive.
  If you are trying contiguous allocation, the 2nd part isn't used.
  Vice versa.


$ diffstat -p1 03.remove_ix_offset.patch
 lib/metadata/lv_manip.c |   66 ++++++++++++++++++++-------------------------
 1 file changed, 28 insertions(+), 38 deletions(-)


-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: 03.remove_ix_offset.patch
Type: text/x-patch
Size: 4248 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/c74a859b/attachment.bin>
