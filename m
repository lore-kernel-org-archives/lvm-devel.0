From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2011 15:57:30 -0000
Subject: LVM2/daemons/dmeventd/plugins/thin dmeventd_thin.c
Message-ID: <20111222155730.12162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-22 15:57:29

Modified files:
	daemons/dmeventd/plugins/thin: dmeventd_thin.c 

Log message:
	Thin use helper function
	
	Fix some minor outstading issue from thin plugin introduction -
	Call dmeventd_lvm2_exit() in failpath for registration.
	Add some missing '\n' in syslog messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c	2011/12/21 13:08:13	1.1
+++ LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c	2011/12/22 15:57:29	1.2
@@ -42,14 +42,13 @@
 	int data_percent_check;
 	uint64_t known_meta_size;
 	uint64_t known_data_size;
-	char *vg, *lv, *layer;
 	char cmd_str[1024];
 };
 
 static int _extend(struct dso_state *state)
 {
 #if THIN_DEBUG
-	syslog(LOG_INFO, "dmeventd executes: %s.", state->cmd_str);
+	syslog(LOG_INFO, "dmeventd executes: %s.\n", state->cmd_str);
 #endif
 	return (dmeventd_lvm2_run(state->cmd_str) == ECMD_PROCESSED);
 }
@@ -159,7 +158,7 @@
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 
 	if (!target_type || (strcmp(target_type, "thin-pool") != 0)) {
-		syslog(LOG_ERR, "Invalid targe type.\n");
+		syslog(LOG_ERR, "Invalid target type.\n");
 		goto out;
 	}
 
@@ -244,18 +243,19 @@
 	struct dm_pool *statemem = NULL;
 	struct dso_state *state;
 
-	if (!dmeventd_lvm2_init() ||
-	    !(statemem = dm_pool_create("thin_pool_state", 2048)) ||
+	if (!dmeventd_lvm2_init())
+		goto bad;
+
+	if (!(statemem = dm_pool_create("thin_pool_state", 2048)) ||
 	    !(state = dm_pool_zalloc(statemem, sizeof(*state))) ||
-	    !dm_split_lvm_name(statemem, device, &state->vg, &state->lv,
-			       &state->layer) ||
-	    (dm_snprintf(state->cmd_str, sizeof(state->cmd_str),
-			 "lvextend --use-policies %s/%s", state->vg, state->lv) < 0)) {
-		syslog(LOG_ERR, "Failed to monitor thin %s.\n", device);
+	    !dmeventd_lvm2_command(statemem, state->cmd_str,
+				   sizeof(state->cmd_str),
+				   "lvextend --use-policies",
+				   device)) {
 		if (statemem)
 			dm_pool_destroy(statemem);
-
-		return 0;
+		dmeventd_lvm2_exit();
+		goto bad;
 	}
 
 	state->mem = statemem;
@@ -266,6 +266,10 @@
 	syslog(LOG_INFO, "Monitoring thin %s.\n", device);
 
 	return 1;
+bad:
+	syslog(LOG_ERR, "Failed to monitor thin %s.\n", device);
+
+	return 0;
 }
 
 int unregister_device(const char *device,
@@ -276,10 +280,9 @@
 {
 	struct dso_state *state = *private;
 
+	syslog(LOG_INFO, "No longer monitoring thin %s.\n", device);
 	dm_pool_destroy(state->mem);
 	dmeventd_lvm2_exit();
 
-	syslog(LOG_INFO, "No longer monitoring thin %s.\n", device);
-
 	return 1;
 }


