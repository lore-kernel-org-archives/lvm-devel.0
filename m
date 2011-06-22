From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 22 Jun 2011 16:47:40 -0500
Subject: [PATCH] Fix to preserve exclusive activation of mirror while up-converting.
Message-ID: <1308779260.13683.2.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix to preserve exclusive activation of mirror while up-converting.

When an LVM mirror is up-converted (an additional image added), it creates
a temporary mirror stack.  The lower-level mirror in the stack that is
created was not being activated exclusively - violating the exclusive nature
of the original mirror.  We now check for exclusive activation of a mirror
before converting it, and if found, we ensure that the temporary mirror
is also exclusively activated.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -3096,11 +3096,13 @@ struct logical_volume *insert_layer_for_
 					   uint64_t status,
 					   const char *layer_suffix)
 {
+	int r;
 	struct logical_volume *layer_lv;
 	char *name;
 	size_t len;
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
+	unsigned exclusive = 0;
 
 	/* create an empty layer LV */
 	len = strlen(lv_where->name) + 32;
@@ -3122,6 +3124,9 @@ struct logical_volume *insert_layer_for_
 		return NULL;
 	}
 
+	if (lv_is_active_exclusive_locally(lv_where))
+		exclusive = 1;
+
 	if (lv_is_active(lv_where) && strstr(name, "_mimagetmp")) {
 		log_very_verbose("Creating transient LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
 
@@ -3143,8 +3148,15 @@ struct logical_volume *insert_layer_for_
 			return NULL;
 		}
 
-		if (!activate_lv(cmd, layer_lv)) {
-			log_error("Failed to resume transient error LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
+		if (exclusive)
+			r = activate_lv_excl(cmd, layer_lv);
+		else
+			r = activate_lv(cmd, layer_lv);
+
+		if (!r) {
+			log_error("Failed to resume transient LV"
+				  " %s for mirror conversion in VG %s.",
+				  name, lv_where->vg->name);
 			return NULL;
 		}
 	}
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -419,8 +419,13 @@ static int _delete_lv(struct logical_vol
 		}
 	}
 
-	if (!activate_lv(cmd, lv))
-		return_0;
+	if (lv_is_active_exclusive_locally(lv)) {
+		if (!activate_lv_excl(cmd, lv))
+			return_0;
+	} else {
+		if (!activate_lv(cmd, lv))
+			return_0;
+	}
 
 	if (!deactivate_lv(cmd, lv))
 		return_0;



