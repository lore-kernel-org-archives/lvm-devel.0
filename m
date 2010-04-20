From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Apr 2010 12:14:36 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20100420121436.3984.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-20 12:14:31

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Move function up file

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/lib/metadata/mirror.c	2010/04/09 01:00:11	1.112
+++ LVM2/lib/metadata/mirror.c	2010/04/20 12:14:28	1.113
@@ -516,6 +516,21 @@
 	return !count;
 }
 
+static int _mirrored_lv_in_sync(struct logical_volume *lv)
+{
+	float sync_percent;
+	percent_range_t percent_range;
+
+	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
+			       &percent_range, NULL)) {
+		log_error("Unable to determine mirror sync status of %s/%s.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return (percent_range == PERCENT_100) ? 1 : 0;
+}
+
 /*
  * Split off 'split_count' legs from a mirror
  *
@@ -960,21 +975,6 @@
 	return 1;
 }
 
-static int _mirrored_lv_in_sync(struct logical_volume *lv)
-{
-	float sync_percent;
-	percent_range_t percent_range;
-
-	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
-			       &percent_range, NULL)) {
-		log_error("Unable to determine mirror sync status of %s/%s.",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	return (percent_range == PERCENT_100) ? 1 : 0;
-}
-
 /*
  * Collapsing temporary mirror layers.
  *


