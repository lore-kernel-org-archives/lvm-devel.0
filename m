From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 17:01:40 -0400
Subject: [PATCH LVM2] (8/12) 'anywhere' policy implementation
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <452FFEB4.9010302@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch implements 'anywhere' policy.

o relax_allocation_requests() is added to split the allocation requests
  into smallest possible pieces so that they can fit into any number of PVs.

o _setup_alloced_segment() needed to be changed because it assumed
  the list items in ah->alloced_areas[0] can be used as array.
  It's no longer true.

o dm_pool_free() in relax_allocation_requests() seems to free whole
  alloc_handle and not usable. I might be using it in wrong way.


$ diffstat -p1 08.anywhere.patch
 lib/metadata/lv_manip.c |  108 +++++++++++++++++++++++++++++++++++++++------
 1 file changed, 89 insertions(+), 19 deletions(-)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America



-------------- next part --------------
A non-text attachment was scrubbed...
Name: 08.anywhere.patch
Type: text/x-patch
Size: 5178 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/91bcc3a3/attachment.bin>
