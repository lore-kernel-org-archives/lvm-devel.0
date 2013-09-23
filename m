From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Sep 2013 14:51:13 +0000 (UTC)
Subject: master - release 2.02.102
Message-ID: <20130923145113.98B6861281@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8057aec36a3d00789b59e06a9ed9eeee7151ded
Commit:        c8057aec36a3d00789b59e06a9ed9eeee7151ded
Parent:        431eda63cc0ebff7c62dacb313cabcffbda6573a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 23 15:43:37 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 23 15:43:37 2013 +0100

release 2.02.102

18 files changed, 137 insertions(+), 203 deletions(-)
---
 VERSION                    |    2 +-
 VERSION_DM                 |    2 +-
 WHATS_NEW                  |    2 +-
 WHATS_NEW_DM               |    4 ++++
 lib/format_text/archiver.c |    4 +++-
 5 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 8c1db53..7f751a2 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.101(2)-git (2013-09-20)
+2.02.102(2)-git (2013-09-23)
diff --git a/VERSION_DM b/VERSION_DM
index 10b2320..461c775 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.80-git (2013-09-20)
+1.02.81-git (2013-09-23)
diff --git a/WHATS_NEW b/WHATS_NEW
index a3744dc..2263fac 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.102
+Version 2.02.102 - 23rd September 2013
 ======================================
   Fix missing build dependency for scripts subdir in Makefile.
   Extend lv_info() for more efficient lv_is_active_locally() check.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 176234c..f209c09 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,7 @@
+Version 1.02.81 - 23rd September 2013
+=====================================
+  Tidy dmeventd fifo initialisation.
+
 Version 1.02.80 - 20th September 2013
 =====================================
   Detect invalid sector supplied to 'dmsetup message'.
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index e3e7777..f41bffc 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -354,7 +354,9 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop
 	if (drop_lvmetad && lvmetad_active()) {
 		struct volume_group *vg_lvmetad = lvmetad_vg_lookup(cmd, vg->name, NULL);
 		if (vg_lvmetad) {
-			lvmetad_vg_remove(vg_lvmetad);
+			/* FIXME Cope with failure to update lvmetad */
+			if (!lvmetad_vg_remove(vg_lvmetad))
+				stack;
 			release_vg(vg_lvmetad);
 		}
 	}


