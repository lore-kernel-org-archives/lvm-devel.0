From: David Teigland <teigland@sourceware.org>
Date: Mon, 15 May 2017 12:00:14 -0400
Subject: master - lvchange: allow changing properties on thin pool data lv
Message-ID: <201705151600.v4FG0EDB010094@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5406191cb9112dea6d8a618ae1da815f816291f6
Commit:        5406191cb9112dea6d8a618ae1da815f816291f6
Parent:        dfc58c637b4e7fe48c28c73cd53eb62611b9309a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 15 10:57:49 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 15 10:59:48 2017 -0500

lvchange: allow changing properties on thin pool data lv

Add an exception to not allowing lvchange to change properties
on hidden LVs.  When a thin pool data LV is a cache LV, we
need to allow changing cache properties on the tdata sublv of
the thin pool.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index abe4641..5097c1b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Allow lvchange to change properties on a thin pool data sub LV.
   Fix lvcreate extent percentage calculation for mirrors.
   Don't reinstate still-missing devices when correcting inconsistent metadata.
   Properly handle subshell return codes in fsadm.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 660570a..92161e2 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1238,6 +1238,16 @@ static int _lvchange_properties_check(struct cmd_context *cmd,
 				     int lv_is_named_arg)
 {
 	if (!lv_is_visible(lv)) {
+		/*
+		 * Exceptions where we allow lvchange properties on
+		 * a hidden sub lv.
+		 *
+		 * lv_is_thin_pool_data: e.g. needed when the data sublv
+		 * is a cache lv and we need to change cache properties.
+		 */
+		if (lv_is_thin_pool_data(lv))
+			return 1;
+
 		if (lv_is_named_arg)
 			log_error("Operation not permitted on hidden LV %s.", display_lvname(lv));
 		return 0;


