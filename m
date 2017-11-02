From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Thu, 2 Nov 2017 09:58:04 -0400
Subject: master - testsuite: Add and document a 'should' for "idle" -> "recover" RAID test
Message-ID: <201711021358.vA2Dw4iA007605@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50130328450d1f624d30438ca835d40e0d4f942d
Commit:        50130328450d1f624d30438ca835d40e0d4f942d
Parent:        58b763c99cb7620b1cc2313a9f0dccd98def53db
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Nov 2 08:53:48 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Nov 2 08:53:48 2017 -0500

testsuite: Add and document a 'should' for "idle" -> "recover" RAID test

When a "recover" is just starting for a RAID LV, it is possible to get
"idle" for the sync action if the status is issued quickly enough.  This
is fine, the MD thread just hasn't gotten things going yet.  However,
the /need/ for a "recover" should be marked in md->recovery and it would
be simple enough to fix the kernel so this doesn't happen.  May eventually
want a separate bug for this, but for now it fits with RHBZ 1507719.
---
 test/shell/lvconvert-raid-status-validation.sh |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index 9ffaaf3..3e91d23 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -83,7 +83,12 @@ while true; do
 		# If the sync operation ("recover" in this case) is not
 		# finished, then it better be as follows:
 		[ "${a[5]}" = "Aa" ]
-		[ "${a[7]}" = "recover" ]
+
+		# Might be transitioning from "idle" to "recover".
+		# Kernel could check mddev->recovery for the intent to
+		# begin a "recover" and report that... probably would be
+		# better.  RHBZ 1507719
+		should [ "${a[7]}" = "recover" ]
 	else
 		# Tough to tell the INVALID case,
 		#   Before starting sync thread: "Aa X/X recover"


