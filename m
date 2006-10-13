From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 13 Oct 2006 16:54:19 -0400
Subject: [PATCH LVM2] (0/12) LVM2 allocation rewrites
Message-ID: <452FFCFB.6090805@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This series of patches fix the following things:
  - allocate mirror log on the same PV with mimage (--alloc anywhere)
  - allocate from any available space (--alloc anywhere)
  - correct allocation for converting linear LV to mirror LV
    to avoid existing LV
  - correct allocation for extending mirror LV to avoid
    existing log LV
  - generalize allocation logic to cover more complex allocation requests

Patches are applicable to 2.02.11.
Patches should be applied in this order.
Compilation test is done for all patches.
Simple tests of combination of lvcreate/lvextend/lvconvert and
linear/stripe/mirror/snapshot are done for the set of the patches.


What's changed
==============

  01.for_each_pv.patch
    - _for_each_pv() is extended to maintain global index of
      flattened lv_segment
    - _for_each_pv() accepts the range of indices to which
      call back function is executed

  02.alloc_requests.patch
    - added struct allocation_requests and eliminate log device specific
      elements from struct alloc_handle
    - corresponding changes in several functions

  03.remove_ix_offset.patch
    - shrink the size of temporal array of areas

  04.separate_constraints.patch
    - move constraints checker out from _find_parallel_space()

  05.prefer_small.patch
    - allowing preference of small area (e.g. for log device)

  06.add_pvs.patch
    - move _add_pvs()

  07.update_parallel.patch
    - updating parallel_areas according to the on-going allocation
      (_update_parallel_areas and other utility functions)

  08.anywhere.patch
    - added relax_allocation_requests() to split the allocation request
      to cover anywhere policy

  09.lvconvert.patch
    - changed lvconvert to use build_parallel_areas_from_lv()

  10.calcfree.patch
    - calculate free pe count before trying allocation

  11.log_coverage.patch
    - reflect the fact that log pv constraints other areas regardless of
      its range

  12.sort_requests.patch
    - sort allocation requests to pick up log area first


Background of these changes
===========================

Allow mirror log on the same device as mirror image
---------------------------------------------------

  Current code takes the allocation request like this:
    <n> areas with size <x> which are either striped or mirrored,
    plus 1 area with size 1 for mirror log device

  Then it tries to allocate <n> + 1 areas from different PVs.

  The log device is handled as special case various places.
  If you would like to allow log on the same device with others
  but the others are on different PVs each other, you have to
  add another special case handling of the log device.
  Like the one posted here last month:
  https://www.redhat.com/archives/linux-lvm/2006-September/msg00108.html

  In 02.alloc_requests.patch, the allocation request is generalized
  by struct allocation_request. The allocator will process <x> * <n>
  request and then 1 * 1 request.

  To allocate log device first, 12.sort_requests.patch sorts the
  allocation requests.

Real 'anywhere' policy implementation
-------------------------------------

  Since the current logic picks up the best areas from each PV
  and matches them with allocation request, it doesn't work well
  if the number of PVs is smaller than the requested areas.

  This is acceptable restriction for normal case: it's not good to
  allocate mirrors or stripes from same PV.
  But for special case like 'anywhere' policy, this restriction
  should be removed.

  As the area list in the PV is sorted by size, it's easy to
  pick up largest one for each PV.
  However, it's takes cost to pick up <n> largest areas from <m>
  PVs where <m> is smaller than <n>.

  Rather than that, in 08.anywhere.patch, it splits the allocation
  request into the smaller unit where <n> is smaller than <m>.

Allocation constraints
----------------------

  The allocation code takes "parallel_areas" list as a constraint.
  It avoids (a part of) PVs in the list.

  However, the list was built only before starting the allocation.
  So it cannot avoid parallel areas just being allocated.
  For example, if you do 'lvcreate -m1', newly allocated mirror
  images should avoid mirror log, or vise versa, but it can't.
  07.update_parallel.patch updates the list after every allocation
  to cope with this situation.

  The other problem is that if you do 'lvextend' the mirror LV,
  newly allocated extents should avoid mirror log.
  But it can't because it can't distinguish mirror log in parallel_areas
  list.
  11.log_coverage.patch adds mirror log to the list to cover whole range
  so that future mirror image allocation can avoid it.

-- 
Jun'ichi Nomura, NEC Corporation of America


