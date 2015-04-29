From: okozina <okozina@fedoraproject.org>
Date: Wed, 29 Apr 2015 15:12:30 +0000 (UTC)
Subject: master - toollib: code cleanup in lv_spawn_background_polling
Message-ID: <20150429151230.8E125611BF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b120454b505f88719735fd1b653dec48816d6036
Commit:        b120454b505f88719735fd1b653dec48816d6036
Parent:        f0ff3e9982f1812435bf294d18f743762c944eb1
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Apr 29 16:25:50 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Apr 29 17:10:37 2015 +0200

toollib: code cleanup in lv_spawn_background_polling

we're going to extract parameters from lv_mirr later
with code refactoring of polldaemon
---
 tools/toollib.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 2268b7e..d29bebf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -910,14 +910,15 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 				 struct logical_volume *lv)
 {
 	const char *pvname;
+	const struct logical_volume *lv_mirr = NULL;
 
-	if (lv_is_pvmove(lv) &&
-	    (pvname = get_pvmove_pvname_from_lv_mirr(lv))) {
-		log_verbose("Spawning background pvmove process for %s.",
-			    pvname);
-		pvmove_poll(cmd, pvname, 1);
-	} else if (lv_is_locked(lv) &&
-		   (pvname = get_pvmove_pvname_from_lv(lv))) {
+	if (lv_is_pvmove(lv))
+		lv_mirr = lv;
+	else if (lv_is_locked(lv))
+		lv_mirr = find_pvmove_lv_in_lv(lv);
+
+	if (lv_mirr &&
+	    (pvname = get_pvmove_pvname_from_lv_mirr(lv_mirr))) {
 		log_verbose("Spawning background pvmove process for %s.",
 			    pvname);
 		pvmove_poll(cmd, pvname, 1);
@@ -925,7 +926,7 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 
 	if (lv_is_converting(lv) || lv_is_merging(lv)) {
 		log_verbose("Spawning background lvconvert process for %s.",
-			lv->name);
+			    lv->name);
 		lvconvert_poll(cmd, lv, 1);
 	}
 }


