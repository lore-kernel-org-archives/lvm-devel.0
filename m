From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 16:55:51 -0400
Subject: [PATCH LVM2] (2/12) rewrite with struct allocation request
In-Reply-To: <452FFCFB.6090805@ce.jp.nec.com>
References: <452FFCFB.6090805@ce.jp.nec.com>
Message-ID: <452FFD57.6040407@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch introduces 'struct allocaction_request' to generalize
the allocation request currently embedded in struct alloc_handle.

o The struct is in this form:
   struct allocation_request {
        uint32_t len; /* requested length of single area */
        uint32_t area_count; /* number of areas with same length */
        uint32_t multiple;      /* LV size is extended with (len * multiple) */
        uint32_t allocated; /* allocated length of single area */
        int flags;
        int index;      /* index to alloced_areas[] */
   };

  For example, if you do 'lvcreate -l3 -m1', the first allocation
  request would be:
     { len = 3, area_count = 2, multiple = 1, index = 0 }
  and for the 2nd allocation (i.e. log) would be:
     { len = 1, area_count = 1, multiple = 1, index = 2 }

  _handle_allocation_requests() will call _find_parallel_space() for
  each struct allocation_request.

  The flags is used to describe preference and also be used later
  to find out for what purpose the request was.

o _find_parallel_space() is simplified since we don't need to carry
  around the attempt-wide "*allocated" or "max_parallel" and a lot of
  division and multiplication.

o lv_add_log_segment() is changed to search alloced_areas for log.
  It should be easily extended to cope with multiple log allocation.

o Set up of struct allocation_request is done in _alloc_init().
  It seems better to do it out side of allocate_extents()
  and allocate_extents() to take the array of struct allocation_request.


$ diffstat -p1 02.alloc_requests.patch
 lib/metadata/lv_manip.c |  459 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 310 insertions(+), 149 deletions(-)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


-------------- next part --------------
A non-text attachment was scrubbed...
Name: 02.alloc_requests.patch
Type: text/x-patch
Size: 24365 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061013/6d5a1bc7/attachment.bin>
