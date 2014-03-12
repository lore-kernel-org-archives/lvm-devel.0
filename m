From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Mar 2014 18:47:32 +0000 (UTC)
Subject: master - dev_manager: check prohibited devices earlier
Message-ID: <20140312184732.9A7DB61295@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0f1eb5f0f8f0a790d1d9e6d9d3e1323c85e4144
Commit:        c0f1eb5f0f8f0a790d1d9e6d9d3e1323c85e4144
Parent:        b50b4471bd863304a78b194d1ef10b85cc9666f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 12 19:38:34 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 19:38:34 2014 +0100

dev_manager: check prohibited devices earlier

Reorder detection for internal device - since this test
is much simpler then target analysis, check it sooner.

Replace test for '68' with sizeof & ID_LEN

Add FIXME about device alias problem with is_reserved_lvname,
since this test fails on devices like /dev/dm-X
so we need to convert tests to UUID.
---
 lib/activate/dev_manager.c |   41 +++++++++++++++++++++--------------------
 1 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c723a61..490218c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -392,6 +392,27 @@ static int _device_is_usable(struct device *dev, int check_lv_names)
 		goto out;
 	}
 
+	/* Check internal lvm devices */
+	if (check_lv_names &&
+	    uuid && !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
+		if (strlen(uuid) > (sizeof(UUID_PREFIX) + 2 * ID_LEN)) { /* 68 */
+			log_debug_activation("%s: Reserved uuid %s on internal LV device %s not usable.",
+					     dev_name(dev), uuid, name);
+			goto out;
+		}
+
+		if (!(vgname = dm_strdup(name)) ||
+		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
+			goto_out;
+
+		/* FIXME: fails to handle dev aliases i.e. /dev/dm-5, replace with UUID suffix */
+		if (lvname && (is_reserved_lvname(lvname) || *layer)) {
+			log_debug_activation("%s: Reserved internal LV device %s/%s%s%s not usable.",
+					     dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
+			goto out;
+		}
+	}
+
 	/* FIXME Also check for mpath no paths */
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
@@ -439,26 +460,6 @@ static int _device_is_usable(struct device *dev, int check_lv_names)
 
 	/* FIXME Also check dependencies? */
 
-	/* Check internal lvm devices */
-	if (check_lv_names &&
-	    uuid && !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
-		if (!(vgname = dm_strdup(name)) ||
-		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
-			goto_out;
-
-		if (strlen(uuid) > 68) {
-			log_debug_activation("%s: Reserved uuid %s on internal LV device %s/%s%s%s not usable.",
-					     dev_name(dev), uuid, vgname, lvname, *layer ? "-" : "", layer);
-			goto out;
-		}
-
-		if (lvname && (is_reserved_lvname(lvname) || *layer)) {
-			log_debug_activation("%s: Reserved internal LV device %s/%s%s%s not usable.",
-					     dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
-			goto out;
-		}
-	}
-
 	r = 1;
 
       out:


