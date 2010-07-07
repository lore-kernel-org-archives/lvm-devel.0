From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:29:30 +0200
Subject: [PATCH 0/6] Misc code updates
Message-ID: <cover.1278505444.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Small patchset contains various bits of code I keep in front of my tree.

First strict-aliasing is a bit contraversional and needs bigger review.

Configure patch basicaly cleanups help strings with the use of
AC_HELP_STRING.

Nextbit patch is tiny code optimization.

Backtrace patch skips printing of backtrace in the log if the situation
is not an error case.

Memlock slightly modifies memory map printing.

Last patch for dmsetup returns '0' exist status when showing option help.


Zdenek Kabelac (6):
  Fix compiler warning about strict-aliasing break
  configure changes - AC_HELP_STRING, AH_TEMPLATE
  nextbit
  Do not show backtrace
  Better alligned debug message - memlock
  Exit status 0 for 'dmsetup -c -o help'

 configure                 |  100 +++++++++++++++++++++------------------------
 configure.in              |   76 +++++++++++++++++++---------------
 lib/activate/activate.c   |    6 ++-
 lib/device/device.c       |   18 ++++----
 lib/mm/memlock.c          |    7 ++-
 libdm/datastruct/bitset.c |    4 +-
 tools/dmsetup.c           |    1 +
 7 files changed, 109 insertions(+), 103 deletions(-)


