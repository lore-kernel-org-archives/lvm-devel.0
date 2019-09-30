From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Sep 2019 07:38:39 -0400
Subject: master - vdo: properly check percentage for resize
Message-ID: <201909301138.x8UBcd00002521@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a98b77c16455ee97f5bd4b89536a3ae4efd8e009
Commit:        a98b77c16455ee97f5bd4b89536a3ae4efd8e009
Parent:        c813db8fc2ec15a8370bb291f662e15ba26682e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 30 13:25:42 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 30 13:34:34 2019 +0200

vdo: properly check percentage for resize

Avoid checking 'lv_is_active()' since special LV types does this
validation anyway what calling  _percent() function  and call it
ONLY when none of special types is queried.

This restores support for VDO resize (as with support for
separate VDO pool activation, plain query for lv_is_active()
is not working in this case).
---
 lib/metadata/lv_manip.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 21d21ca..47ff167 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4850,12 +4850,6 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!lv_is_active(lv)) {
-		log_error("Can't read state of locally inactive LV %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, 1, &percent))
 			return_0;
@@ -4870,9 +4864,12 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 	} else if (lv_is_vdo_pool(lv)) {
 		if (!lv_vdo_pool_percent(lv, &percent))
 			return_0;
-	} else {
-		if (!lv_snapshot_percent(lv, &percent))
+	} else if (!lv_snapshot_percent(lv, &percent))
 			return_0;
+	else if (!lv_is_active(lv)) {
+		log_error("Can't read state of locally inactive LV %s.",
+			  display_lvname(lv));
+		return 0;
 	}
 
 	*amount = _adjust_amount(percent, policy_threshold, policy_amount);


