From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 29 Mar 2010 17:27:18 +0200
Subject: [PATCH 0/7] dmevent mlockall() fixes
Message-ID: <cover.1269876115.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set tries to fix dmeventd.

Dmeventd got actually broken with our new mlock() code.
There is no big chance to make current architecture with threads usable
with mlock() code - so mlockall() is used for daemon case.

Snapshot plugin current doesn't use cmd_context and doesn't need memory
locking.

Mirror plugin uses memlock_inc_daemon() and locks while binary to memory.

C locales are enforced to avoid loading of 100MB locale-archive file.

Few minor fixes for syslog message and resource leaks in error path.

Statistic for mlock() could be based on readable sizes.

Zdenek Kabelac (7):
  Remove mlockall() form dmeventd
  Fix resouces leak in error path
  Release pool in the same reversed order
  Updated syslog messages
  Force C locale
  Update memlock
  Count only readable size for memlock stats.

 daemons/dmeventd/dmeventd.c                       |   14 ++---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c      |    4 +-
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |   28 +++++-----
 lib/mm/memlock.c                                  |   64 ++++++++++-----------
 4 files changed, 51 insertions(+), 59 deletions(-)


