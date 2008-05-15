From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 15 May 2008 14:46:41 -0500
Subject: LVM2 Patch to avoid excessive monitoring flips during --resync
Message-ID: <1210880801.12317.5.camel@hydrogen>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Avoid unnecessary monitoring when simply wiping the log.

Index: LVM2-cvs/tools/lvchange.c
===================================================================
--- LVM2-cvs.orig/tools/lvchange.c
+++ LVM2-cvs/tools/lvchange.c
@@ -178,6 +178,7 @@ static int lvchange_resync(struct cmd_co
 			      struct logical_volume *lv)
 {
 	int active = 0;
+	int monitored;
 	struct lvinfo info;
 	struct logical_volume *log_lv;
 
@@ -226,6 +227,10 @@ static int lvchange_resync(struct cmd_co
 		return 0;
 	}
 
+	/* Try to avoid unnecessary dmeventd activity */
+	monitored = dmeventd_monitor_mode();
+	init_dmeventd_monitor(0);
+
 	if (vg_is_clustered(lv->vg) && !activate_lv_excl(cmd, lv)) {
 		log_error("Can't get exclusive access to clustered volume %s",
 			  lv->name);
@@ -316,6 +321,8 @@ static int lvchange_resync(struct cmd_co
 		return 0;
 	}
 
+	init_dmeventd_monitor(monitored);
+
 	if (active && !activate_lv(cmd, lv)) {
 		log_error("Failed to reactivate %s after resync", lv->name);
 		return 0;



