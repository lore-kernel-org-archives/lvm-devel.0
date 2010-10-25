From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:07 +0200
Subject: [PATCH 00/30] Fixes from clang
Message-ID: <cover.1287994529.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patchset combines code cleanups for compiler warnings
and code fixes found by static analyzer scan-build.

Potentional NULL pointer dereferencies are mostly
in very unusual code execution paths. I've tried to
order them on their importance - the later ones are not
event trigerable as surrounding code should not be to
pass problematic values - but checks seems to be simple
enough to keep static analysis happy.

Last patches in this set add some instrumentation to
function calls that might allow better code optimization
or better static analysis.

Zdenek Kabelac (30):
  Fix clang warning for ntohl(*((uint32_t *)buf))
  Use dm_pool_grow_object embeded strlen for 0 delta
  Check (type) is not NULL before access
  Fix NULL pointer dereference
  Print vg_name and do not to access vg->name
  Ensure we always have origin defined
  Ensure seg is nonnull
  Ensure  first is not NULL
  Reuse result of previous strchr.
  Fix potential NULL pointer dereference
  Fix theoretical usage of NULL pointer dereference
  Check for NULL pointer
  Eliminate uninitialized_var
  Fix missing initilisation to 0
  Function pull_state cannot work with NULL buffer
  Fix  void* pointer arithmetic
  Use const pvid for device_from_pvid()
  Use const pointer for return value of dm_basename
  Fix constness warning
  Fix constness warning
  Fix constness warning
  Fix constness warning
  Using const config node
  bufused is assigned 0 in preceding source line
  Proper C declaration
  Use static
  Instrument compiler about code unreachability
  Skip uninitialized macro for scan-build
  Add some __attribute__ instrumentation
  __attribute__((nonnull(1)))

 daemons/clvmd/clvmd.c                 |    7 +++++--
 daemons/cmirrord/cluster.c            |    2 +-
 daemons/cmirrord/functions.c          |    4 +++-
 daemons/dmeventd/dmeventd.c           |   21 +++++++++++----------
 daemons/dmeventd/libdevmapper-event.c |   20 ++++++++++----------
 lib/activate/dev_manager.c            |    2 +-
 lib/cache/lvmcache.c                  |   10 +++++-----
 lib/cache/lvmcache.h                  |    2 +-
 lib/config/config.c                   |    2 +-
 lib/device/dev-cache.h                |    2 +-
 lib/device/dev-md.c                   |    3 ++-
 lib/format1/format1.c                 |    2 +-
 lib/format_text/archive.c             |    4 ++--
 lib/format_text/format-text.c         |    2 +-
 lib/log/log.c                         |    2 +-
 lib/metadata/lv_manip.c               |    2 +-
 lib/metadata/metadata.c               |    6 +++---
 lib/misc/crc.c                        |    6 +++---
 lib/misc/util.h                       |    4 ++++
 lib/mm/memlock.c                      |    4 ++--
 lib/report/report.c                   |    6 +++---
 lib/striped/striped.c                 |    2 +-
 libdm/libdevmapper.h                  |   28 ++++++++++++++--------------
 libdm/libdm-report.c                  |    7 ++++---
 libdm/libdm-string.c                  |    6 +++---
 libdm/mm/pool-fast.c                  |    8 ++++----
 libdm/regex/ttree.c                   |    7 +++++--
 tools/dmsetup.c                       |    2 +-
 tools/lvcreate.c                      |    4 ++++
 tools/lvm.c                           |    6 +++---
 tools/lvmcmdline.c                    |    2 +-
 tools/pvresize.c                      |    2 +-
 tools/reporter.c                      |    2 +-
 tools/toollib.c                       |    2 +-
 34 files changed, 105 insertions(+), 86 deletions(-)

--
1.7.3.1


