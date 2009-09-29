From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 11:22:57 -0400
Subject: [PATCH 4/4] Move activation of background polling processes to a common function.
In-Reply-To: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
References: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
Message-ID: <1254237777-30501-5-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move activation of background polling processes to a common function.

Avoids code duplication and fixes an associated where vgchange would
only restart pvmove and _not_ lvconvert (lvchange would restart
both).

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Mike Snitzer <snitzer@redhat.com>

---
 tools/lvchange.c |   33 ++++++++++++++++++++-------------
 tools/tools.h    |    1 +
 tools/vgchange.c |   10 ++--------
 3 files changed, 23 insertions(+), 21 deletions(-)

Index: lvm2/tools/lvchange.c
===================================================================
--- lvm2.orig/tools/lvchange.c
+++ lvm2/tools/lvchange.c
@@ -101,11 +101,29 @@ static int lvchange_monitoring(struct cm
 	return 1;
 }
 
+void lvchange_activate_background_polling(struct cmd_context *cmd,
+					  struct logical_volume *lv)
+{
+	const char *pvname;
+
+	if ((lv->status & LOCKED) &&
+	    (pvname = get_pvmove_pvname_from_lv(lv))) {
+		log_verbose("Spawning background pvmove process for %s",
+			    pvname);
+		pvmove_poll(cmd, pvname, 1);
+	}
+
+	if (lv->status & CONVERTING) {
+		log_verbose("Spawning background lvconvert process for %s",
+			    lv->name);
+		lvconvert_poll(cmd, lv, 1);
+	}
+}
+
 static int lvchange_availability(struct cmd_context *cmd,
 				 struct logical_volume *lv)
 {
 	int activate;
-	const char *pvname;
 
 	activate = arg_uint_value(cmd, available_ARG, 0);
 
@@ -136,18 +154,7 @@ static int lvchange_availability(struct 
 				return_0;
 		}
 
-		if ((lv->status & LOCKED) &&
-		    (pvname = get_pvmove_pvname_from_lv(lv))) {
-			log_verbose("Spawning background pvmove process for %s",
-				    pvname);
-			pvmove_poll(cmd, pvname, 1);
-		}
-
-		if (lv->status & CONVERTING) {
-			log_verbose("Spawning background lvconvert process for %s",
-				    lv->name);
-			lvconvert_poll(cmd, lv, 1);
-		}
+		lvchange_activate_background_polling(cmd, lv);
 	}
 
 	return 1;
Index: lvm2/tools/tools.h
===================================================================
--- lvm2.orig/tools/tools.h
+++ lvm2/tools/tools.h
@@ -169,5 +169,6 @@ const char *command_name(struct cmd_cont
 
 int pvmove_poll(struct cmd_context *cmd, const char *pv, unsigned background);
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned background);
+void lvchange_activate_background_polling(struct cmd_context *cmd, struct logical_volume *lv);
 
 #endif
Index: lvm2/tools/vgchange.c
===================================================================
--- lvm2.orig/tools/vgchange.c
+++ lvm2/tools/vgchange.c
@@ -56,7 +56,6 @@ static int _activate_lvs_in_vg(struct cm
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
-	const char *pvname;
 	int count = 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -91,13 +90,8 @@ static int _activate_lvs_in_vg(struct cm
 		} else if (!activate_lv(cmd, lv))
 			continue;
 
-		if ((lv->status & PVMOVE) &&
-		    (pvname = get_pvmove_pvname_from_lv_mirr(lv))) {
-			log_verbose("Spawning background process for %s %s",
-				    lv->name, pvname);
-			pvmove_poll(cmd, pvname, 1);
-			continue;
-		}
+		if (activate != CHANGE_AN && activate != CHANGE_ALN)
+			lvchange_activate_background_polling(cmd, lv);
 
 		count++;
 	}


