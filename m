From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 16:42:54 -0400
Subject: 2018-06-01-stable - WHATS_NEW for recent changes
Message-ID: <201806132042.w5DKgsj7025056@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9c0a64fb5ab384d5e0b599a8654fd11bcaed17c
Commit:        e9c0a64fb5ab384d5e0b599a8654fd11bcaed17c
Parent:        7ac8e21f3ce5d8e4595e5122d491e5ac31bc991f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 13 15:42:15 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 15:42:15 2018 -0500

WHATS_NEW for recent changes

---
 WHATS_NEW |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 883c33b..ce03fdd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,13 @@
 Version 2.02.179 -
 ====================================
+  Add the report field "shared".
+  Enable automatic metadata consistency repair on a shared VG.
+  Fix pvremove force on a PV with a shared VG.
+  Fixed vgimportclone of a PV with a shared VG.
+  Enable previously disallowed thin/cache commands in shared VGs.
+  Enable metadata-related changes on LVs active with shared lock.
+  Do not continue trying to use a device that cannot be opened.
+  Fix problems opening a device that fails and returns.
   Use versionsort to fix archive file expiry beyond 100000 files.
 
 Version 2.02.178 - 13th June 2018


