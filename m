From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Jun 2015 20:46:19 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150612204619.B52E760B44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c64762a40dba77a52de8a3459d68a740a5da1c7
Commit:        2c64762a40dba77a52de8a3459d68a740a5da1c7
Parent:        9c0049b1ce027ab4befdbfbcd8194d57ce6eb2b7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 12 21:40:56 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 12 21:40:56 2015 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    9 +++++++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 6d12acd..1797821 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.121(2)-git (2015-05-15)
+2.02.121(2)-git (2015-06-12)
diff --git a/VERSION_DM b/VERSION_DM
index c80b652..8ef64ac 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.98-git (2015-05-15)
+1.02.98-git (2015-06-12)
diff --git a/WHATS_NEW b/WHATS_NEW
index bfcc094..652572f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,13 +1,18 @@
-Version 2.02.121 - 
-================================
+Version 2.02.121 - 12th June 2015
+=================================
+  Distinguish between on-disk and lvmetad versions of text metadata.
+  Remove DL_LIBS from Makefiles for daemons that don't need them.
   Zero errno in before strtoul call in dmsetup if tested after the call.
   Zero errno in before strtoul call in lvmpolld.
   Fix a segfault in pvscan --cache --background command.
   Fix test for AREA_PV when checking for failed mirrors.
   Do not use --sysinit in lvm2-activation{-early,-net}.service if lvmpolld used.
+  Maintain outdated PV info in lvmetad till all old metadata is gone from disk.
   Do not fail polling when poll LV not found (already finished or removed).
   Replace poll_get_copy_vg/lv fns with vg_read() and find_lv() in polldaemon.
   Close all device fds only in before sleep call in polldaemon.
+  Simplify Makefile targets that generate exported symbols.
+  Move various -D settings from Makefiles to configure.h.
 
 Version 2.02.120 - 15th May 2015
 ================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4dabdea..9d5a619 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.98 - 
-===============================
+Version 1.02.98 - 12th June 2015
+================================
   Add dm_task_get_errno() to return any unexpected errno from a dm ioctl call.
   Use copy of errno made after each dm ioctl call in case errno changes later.
 


