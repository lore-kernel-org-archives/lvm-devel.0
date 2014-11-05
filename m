From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  5 Nov 2014 14:33:31 +0000 (UTC)
Subject: master - activate: check all snap segs are inactive
Message-ID: <20141105143331.CAAB760E61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e5790f2d24d798e217fc005522c07e06c97adc9
Commit:        6e5790f2d24d798e217fc005522c07e06c97adc9
Parent:        a3a2c792a87054ab78a1b8e54b99db1c24739fb8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 5 11:53:11 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 5 15:30:58 2014 +0100

activate: check all snap segs are inactive

When deactivating origin, we may have possibly left table in broken state,
where origin is not active, but snapshot volume is still present.

Let's ensure deactivation of origin detects also all associated
snapshots are inactive - otherwise do not skip deactivation.
(so i.e. 'vgchange -an' would detect errors)
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   15 ++++++++++++++-
 2 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 03baa06..06d3b9b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Deactivation of snapshot origin detects and deactivates left-over snapshots.
   Properly report error when taking snapshot of any cache type LV.
   Add basic thread debugging messages to dmeventd.
   Include threads being shutdown in dmeventd device registration responses.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c2a662f..ac6330f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2002,6 +2002,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 	const struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	static const struct lv_activate_opts laopts = { .skip_in_use = 1 };
+	struct dm_list *snh;
 	int r = 0;
 
 	if (!activation())
@@ -2023,7 +2024,19 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 
 	if (!info.exists) {
 		r = 1;
-		goto out;
+		/* Check attached snapshot segments are also inactive */
+		dm_list_iterate(snh, &lv->snapshot_segs) {
+			if (!lv_info(cmd, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow,
+				     0, &info, 0, 0))
+				goto_out;
+			if (info.exists) {
+				r = 0; /* Snapshot left in table? */
+				break;
+			}
+		}
+
+		if (r)
+			goto out;
 	}
 
 	if (lv_is_visible(lv) || lv_is_virtual_origin(lv) ||


