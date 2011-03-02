From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Mar 2011 19:20:22 +0100
Subject: [PATCH 0/4] Alloc VG
Message-ID: <cover.1299089601.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Refactor allocation of volume group structure.

Patch is currently splitted into multiple files to make a review easier.

Things to check - why is pool_vg_read used  seqno == 1?
(To make it same for all - I'd leave to 0 ?)

Memory for import functions is always used from vg mempool.

Future updates -
It would be probably worth to switch vg name to  char[128] (max vg name len)
to simplify surrounding allocations...


Zdenek Kabelac (4):
  Refactor vg allocation code
  Use alloc_vg for _pool_vg_read
  Use allog_vg for _free_vg in _pvsegs_sub_single
  Use alloc_vg for forma1_vg_read

 lib/format1/format1.c         |   72 ++++++++++---------------------
 lib/format_pool/format_pool.c |   96 ++++++++++++++---------------------------
 lib/format_text/import_vsn1.c |   38 +++++-----------
 lib/metadata/metadata.c       |   75 ++++++-------------------------
 lib/metadata/vg.c             |   32 ++++++++++++++
 lib/metadata/vg.h             |    3 +
 tools/reporter.c              |   25 +++++------
 7 files changed, 128 insertions(+), 213 deletions(-)

-- 
1.7.4.1


