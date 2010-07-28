From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:46 +0200
Subject: [PATCH 00/14] Miscellaneous fixes
Message-ID: <cover.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Miscellaneous fixes:

One fix for non-srcdir builds.
Fxes for testsuit.
Cleanups for compiler warnings.
Updates to dmsetup code.

Last patch is proposal for 3 solution how to fix udev patch
checking - I think the check should be a separate function
in lib dm used by dmsetup and liblvm. This patch is not supposed
to be applied in this form.


Zdenek Kabelac (14):
  Skip VPATH usage
  Testsuit: Shell &&||
  Testsuit: create empty files
  Testsuit: test variables with quotes
  Testsuit: speedup
  Testsuit: add missing prepare_dmeventd
  Fix constness warning
  Fix C function definition
  Fix constness warning
  Fix void* arithmetic - use char*
  Fix void* arithmetic and more readable char[]
  log_debug event_nr
  Reorder read_ahead check
  Proposal of different check for udev dir

 daemons/clvmd/clvmd-singlenode.c        |    6 ++--
 daemons/clvmd/lvm-functions.c           |    4 +-
 include/Makefile.in                     |    1 -
 lib/activate/dev_manager.c              |    8 +++---
 lib/format_text/archive.c               |    4 +-
 lib/format_text/import.c                |    2 +-
 lib/locking/file_locking.c              |    2 +-
 libdm/ioctl/libdm-iface.c               |   13 ++++++-----
 libdm/mm/dbg_malloc.c                   |    6 ++--
 test/lvm-utils.sh                       |   30 +++++++++++++++++----------
 test/t-000-basic.sh                     |    4 +-
 test/t-activate-missing.sh              |    1 +
 test/t-activate-partial.sh              |    1 +
 test/t-inconsistent-metadata.sh         |    1 +
 test/t-listings.sh                      |    1 +
 test/t-lock-blocking.sh                 |    2 +-
 test/t-lvchange-mirror.sh               |    1 +
 test/t-lvconvert-mirror-basic.sh        |    1 +
 test/t-lvconvert-mirror.sh              |    1 +
 test/t-lvconvert-repair-dmeventd.sh     |    2 +-
 test/t-lvconvert-repair-policy.sh       |    1 +
 test/t-lvconvert-repair-replace.sh      |    1 +
 test/t-lvconvert-repair-transient.sh    |    1 +
 test/t-lvconvert-repair.sh              |    2 +-
 test/t-lvcreate-mirror.sh               |    1 +
 test/t-lvcreate-operation.sh            |    1 +
 test/t-lvcreate-pvtags.sh               |    1 +
 test/t-lvcreate-usage.sh                |    1 +
 test/t-lvresize-mirror.sh               |    1 +
 test/t-metadata.sh                      |    1 +
 test/t-mirror-names.sh                  |    1 +
 test/t-mirror-vgreduce-removemissing.sh |    1 +
 test/t-nomda-missing.sh                 |    1 +
 test/t-pvchange-usage.sh                |    2 +-
 test/t-pvmove-basic.sh                  |    7 ++---
 test/t-snapshots-of-mirrors.sh          |    1 +
 test/t-unknown-segment.sh               |    1 +
 test/t-unlost-pv.sh                     |    1 +
 test/test-utils.sh                      |    2 +-
 tools/dmsetup.c                         |   33 ++++++++++++++++++++++++++++--
 tools/lvmcmdline.c                      |    4 ++-
 41 files changed, 107 insertions(+), 49 deletions(-)

-- 
1.7.2


