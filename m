From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:00 +0000 (UTC)
Subject: master - archiver: drop unneeded backup check
Message-ID: <20140319000200.09FEE61095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08018a5345c98b91ce43eb55f4110485df9eb3aa
Commit:        08018a5345c98b91ce43eb55f4110485df9eb3aa
Parent:        25f5e2da8d6b447d26395e610e55192d2d8a16b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:20:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:45:41 2014 +0100

archiver: drop unneeded backup check

When the backup is disabled, avoid testing backup presence.
This only leads to errors being logged in debug trace and the missing
backup can't be fixed, since it's disabled.
---
 WHATS_NEW                  |    1 +
 lib/format_text/archiver.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index de96f8a..e2c196a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Do not check for backups when when its creation is disabled.
   Don't allow --mergedconfig without --type current in dumpconfig. Fix memleak.
   Make global/lvdisplay_shows_full_device_path lvm.conf setting profilable.
   Make global/{units|si_unit_consistency|suffix} lvm.conf setting profilable.
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 31d17ef..2667bdb 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -487,6 +487,11 @@ void check_current_backup(struct volume_group *vg)
 	struct volume_group *vg_backup;
 	int old_suppress;
 
+	if (!vg->cmd->backup_params->enabled || !vg->cmd->backup_params->dir) {
+		log_debug("Skipping check for current backup, since backup is disabled.");
+		return;
+	}
+
 	if (vg_is_exported(vg))
 		return;
 


