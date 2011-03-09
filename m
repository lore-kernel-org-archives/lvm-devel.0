From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed,  9 Mar 2011 13:22:32 +0100
Subject: [PATCH 0/7] Add memory pool for format instance and fix memory leaks
Message-ID: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset fixes memory leaks introduced with changes in format instance handling.

Now, the format instances have their own memory pool with reference counting
(since the instances could be shared). This makes the memory handling much
controllable and it uses memory in a more optimal way (long living cmd context
mempool was used before and we couldn't free the memory from unused format
instances).

Peter Rajnoha (7):
  Add memory pool and reference counting for format instances.
  Move text_context allocation inside create_instance fn.
  Use vg_set_fid and new pv_set_fid throughout.
  Add new free_pv_fid fn and use it throughout.
  Call destroy_instance for all PVs in a VG while calling free_vg.
  Various cleanups for fid mem and ref_count changes.
  Switch over to format instance mempool use where possible.

 lib/cache/lvmcache.c             |   19 ++--
 lib/format1/format1.c            |   17 +++-
 lib/format_pool/format_pool.c    |   15 ++-
 lib/format_text/archive.c        |    8 +-
 lib/format_text/archiver.c       |   19 +++-
 lib/format_text/format-text.c    |  143 +++++++++++++--------------
 lib/format_text/format-text.h    |    7 +-
 lib/format_text/import_vsn1.c    |    8 +-
 lib/metadata/metadata-exported.h |   11 ++
 lib/metadata/metadata.c          |  204 +++++++++++++++++++++++++++++---------
 lib/metadata/metadata.h          |    1 +
 lib/metadata/mirror.c            |    6 +-
 tools/lvconvert.c                |    1 +
 tools/pvcreate.c                 |    4 +-
 tools/pvmove.c                   |    9 ++-
 tools/pvremove.c                 |   18 +++-
 tools/pvresize.c                 |    2 +
 tools/pvscan.c                   |    4 +-
 tools/toollib.c                  |   13 +++
 tools/vgconvert.c                |    3 +
 tools/vgreduce.c                 |    3 +
 21 files changed, 352 insertions(+), 163 deletions(-)

-- 
1.7.4


