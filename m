From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 23 Jun 2008 11:05:26 -0500
Subject: Allow mirror log conversion while inactive
Message-ID: <1214237126.3224.1.camel@hydrogen>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 brassow

Allow mirror log conversion (disk -> core) while mirror is inactive.

Addresses bug 192865.


Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1140,6 +1140,7 @@ int remove_mirror_log(struct cmd_context
 		      struct list *removable_pvs)
 {
 	float sync_percent;
+	struct lvinfo info;
 
 	/* Unimplemented features */
 	if (list_size(&lv->segments) != 1) {
@@ -1148,10 +1149,17 @@ int remove_mirror_log(struct cmd_context
 	}
 
 	/* Had disk log, switch to core. */
-	if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
-		log_error("Unable to determine mirror sync status.");
+	if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
+		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
+			log_error("Unable to determine mirror sync status.");
+			return 0;
+		}
+	} else if (yes_no_prompt("Converting to core log while inactive will"
+			       " require a complete resync of the mirror.\n"
+			       "Proceed? [y/n]: "))
+		sync_percent = 0;
+	else
 		return 0;
-	}
 
 	if (sync_percent >= 100.0)
 		init_mirror_in_sync(1);



