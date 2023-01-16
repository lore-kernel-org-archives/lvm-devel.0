From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:16 +0000 (GMT)
Subject: main - vdo: resize requires active vdopool volume
Message-ID: <20230116113916.58DE83858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c20f01a0cbb24e8276734a00f26a510cf6daaf21
Commit:        c20f01a0cbb24e8276734a00f26a510cf6daaf21
Parent:        2451bc568feb9b3d0cb4d7c15e3c723f4d0c8cc9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 15 21:27:57 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:37:40 2023 +0100

vdo: resize requires active vdopool volume

ATM kernel VDO target does not handle resize of inactive VDO LVs
so prevent users corrupting such LVs and require active such LVs.
---
 lib/metadata/lv_manip.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 305be8578..cb7f26069 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5954,6 +5954,16 @@ static int _lv_resize_check_used(struct logical_volume *lv)
 		return 0;
 	}
 
+	if (lv_is_vdo(lv) && !lv_is_active(lv)) {
+		log_error("Cannot resize inactive VDO logical volume %s.", display_lvname(lv));
+		return 0;
+	}
+
+	if (lv_is_vdo_pool(lv) && !lv_is_active(lv_lock_holder(lv))) {
+		log_error("Cannot resize inactive VDO POOL volume %s.", display_lvname(lv));
+		return 0;
+	}
+
 	if (lv_is_external_origin(lv)) {
 		/*
 		 * Since external-origin can be activated read-only,

