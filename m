From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Oct 2017 09:48:46 -0400
Subject: master - thin: monitor also external origin
Message-ID: <201710161348.v9GDmkJj003245@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=186a3da998b13505990809466f0e5708cfdd6c2a
Commit:        186a3da998b13505990809466f0e5708cfdd6c2a
Parent:        12aff591834a634fe536104736be1a863bddea12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 16 15:05:57 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 16 15:47:46 2017 +0200

thin: monitor also external origin

Add missing monitoring for external origin LVs and add -real suffix
for UUID used for monitoring of external origin.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ebdc036..4ad6b1f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Monitor external origin LVs.
   Remove the replicator code, including configure --with-replicators.
   Allow lvcreate --type mirror to work with 100%FREE.
   Improve selection of resource name for complex volume activation lock.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index edbb451..5542f84 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1707,7 +1707,7 @@ static char *_build_target_uuid(struct cmd_context *cmd, const struct logical_vo
 
 	if (lv_is_thin_pool(lv))
 		layer = "tpool"; /* Monitor "tpool" for the "thin pool". */
-	else if (lv_is_origin(lv))
+	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		layer = "real"; /* Monitor "real" for "snapshot-origin". */
 	else
 		layer = NULL;
@@ -1949,6 +1949,13 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			r = 0;
 		}
 
+		if (seg->external_lv &&
+		    !monitor_dev_for_events(cmd, seg->external_lv,
+					    (!monitor) ? laopts : NULL, monitor)) {
+			stack;
+			r = 0;
+		}
+
 		if (seg->metadata_lv &&
 		    !monitor_dev_for_events(cmd, seg->metadata_lv, NULL, monitor)) {
 			stack;


