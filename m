From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:17 +0000 (GMT)
Subject: main - tests: check for lvmdbusd running in the system
Message-ID: <20230506204617.AE0F23858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2fde4b6baa09f33890d4a5b951dc51b81828ef63
Commit:        2fde4b6baa09f33890d4a5b951dc51b81828ef63
Parent:        aa19f2aa3d93b48c5e58a897f26de38b8080d483
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 6 20:35:42 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 22:43:22 2023 +0200

tests: check for lvmdbusd running in the system

Check for running (possibly leftover) lvmdbusd running in the
system - as this daemon may interfere with this test as in this
case both be operating on same  'live' data in /run/lvm.
---
 test/shell/hints.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 7fe0e33f5..6c1711643 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -17,6 +17,11 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
+# Since this test is currenly using 'system's' hints,
+# it cannot be running, while lvmdbusd operates in the system.
+# FIXME: sometimes test suite itself 'leaks' lvmdbusd process.
+pgrep lvmdbusd && skip "Can't run this test, while lvmdbusd is running"
+
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
 HINTS="$RUNDIR/lvm/hints"

