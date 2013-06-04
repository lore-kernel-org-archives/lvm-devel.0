From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:28 +0000 (UTC)
Subject: dev-mornfall-activate - lvmetad: fix error paths
Message-ID: <20130604192428.1A56560E7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f787b575b52fcbfa8327d083eae4f2baf296b1cf
Commit:        f787b575b52fcbfa8327d083eae4f2baf296b1cf
Parent:        377e06b0f8ea10c222a0d38472dbbb05fde1f2d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 21:19:54 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:04:53 2013 +0200

lvmetad: fix error paths

Also add missing goto out on error.
Error path missed return NULL leading to double free of enc_value.
---
 WHATS_NEW           |    1 +
 lib/cache/lvmetad.c |    4 +++-
 lib/config/config.c |    1 +
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 95b6e13..819fea4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix lvmetad error path in lvmetad_vg_lookup() for null vgname.
   Fix clvmd _cluster_request() return code in memory fail path.
   Add writemostly/writebehind support for RAID1
   Add lv_change_activate() for common activation code in vg/lvchange.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 4ea3dbd..348827d 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -343,8 +343,10 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		reply = _lvmetad_send("vg_lookup", "uuid = %s", uuid, NULL);
 		diag_name = uuid;
 	} else {
-		if (!vgname)
+		if (!vgname) {
 			log_error(INTERNAL_ERROR "VG name required (VGID not available)");
+			goto out;
+		}
 		log_debug_lvmetad("Asking lvmetad for VG %s", vgname);
 		reply = _lvmetad_send("vg_lookup", "name = %s", vgname, NULL);
 		diag_name = vgname;
diff --git a/lib/config/config.c b/lib/config/config.c
index d1cf590..d420d83 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -967,6 +967,7 @@ static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
 		if (!(v = dm_config_create_value(cft))) {
 			log_error("Failed to create default config array value for %s.", def->name);
 			dm_free(enc_value);
+			return NULL;
 		}
 		if (oldv)
 			oldv->next = v;


