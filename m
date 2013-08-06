From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Aug 2013 09:42:13 +0000 (UTC)
Subject: master - WHATS_NEW: move line to WHATS_NEW_DM
Message-ID: <20130806094213.02B6F6116A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1cdd563b6cb238d63f3f9a7f2448ef3c4d1368ae
Commit:        1cdd563b6cb238d63f3f9a7f2448ef3c4d1368ae
Parent:        19baf84290186a550b212260144523266350252b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 6 11:42:01 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 6 11:42:01 2013 +0200

WHATS_NEW: move line to WHATS_NEW_DM

---
 WHATS_NEW    |    1 -
 WHATS_NEW_DM |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c76dc68..69a8275 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.02.100 -
 ================================
-  Create dmeventd timeout threads as "detached" so exit status is freed.
   Add initial support thin pool lvconvert --repair.
   Add --with-thin-repair and --with-thin-dump configure options.
   Add lvm.conf thin_repair/dump_executable and thin_repair_options.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ffee9a3..43eb4d8 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.79 -
 ================================
+  Create dmeventd timeout threads as "detached" so exit status is freed.
   Add DM_ABORT_ON_INTERNAL_ERRORS env var support to abort on internal errors.
 
 Version 1.02.78 - 24th July 2013


