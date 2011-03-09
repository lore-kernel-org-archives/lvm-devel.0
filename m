From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  9 Mar 2011 13:18:31 +0100
Subject: [PATCH 0/4] VG Validation updates
Message-ID: <cover.1299670163.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset should address some algorithmic problems
which will become noticable with thousans of LVs.

Using hash tables.
Simplify postorder for all LVs in VG.
Skip some duplicate tests.

The last patch just add pool name to fast pools.
It's IMHO very cheap and adds useful debug info for 
non-debug builds.


Zdenek Kabelac (4):
  Use hash tables for validating names
  Refactor code for _lv_postoder
  Do not check already checked part
  Add pool name to pool-fast as well

 lib/metadata/merge.c    |    3 +
 lib/metadata/metadata.c |  177 +++++++++++++++++++++++++++-------------------
 libdm/mm/pool-fast.c    |    2 +
 libdm/mm/pool.c         |    2 +-
 4 files changed, 110 insertions(+), 74 deletions(-)

-- 
1.7.4.1


