From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:44 +0000 (UTC)
Subject: master - lvmetad: set disabled flag when duplicate PVs are seen
Message-ID: <20160506140044.0EF2060D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d2fbfe243550b7801165f393d27e35044c1a56d
Commit:        3d2fbfe243550b7801165f393d27e35044c1a56d
Parent:        9539ee809827a870c88d02cfb2d0dc1e3eaac0d0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 29 13:31:54 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 08:59:59 2016 -0500

lvmetad: set disabled flag when duplicate PVs are seen

When duplicate PVs are detected, set the disabled
flag so that commands will disable use of lvmetad.

This duplicate detection is done by lvmetad itself
when it's told about a single new PV with a PVID
that matches an existing PV on another device.
(This is different from the case where the command
is scanning all devices and detects the duplicate.)

Remove the "altdev" logic that attempted to keep
track of multiple devices for a single PV.  It
is no longer used since lvmetad is disabled in
this case.
---
 daemons/lvmetad/lvmetad-core.c |  183 +++++++---------------------------------
 1 files changed, 31 insertions(+), 152 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 45641a6..188c9b9 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1869,46 +1869,12 @@ out:
 	return retval;
 }
 
-static dev_t device_remove(lvmetad_state *s, struct dm_config_tree *pvmeta, dev_t device)
-{
-	struct dm_config_node *pvmeta_tmp;
-	struct dm_config_value *v = NULL;
-	dev_t alt_device = 0, prim_device = 0;
-
-	if ((pvmeta_tmp = dm_config_find_node(pvmeta->root, "pvmeta/devices_alternate")))
-		v = pvmeta_tmp->v;
-
-	prim_device = dm_config_find_int64(pvmeta->root, "pvmeta/device", 0);
-
-	/* it is the primary device */
-	if (device > 0 && device == prim_device && pvmeta_tmp && pvmeta_tmp->v)
-	{
-		alt_device = pvmeta_tmp->v->v.i;
-		pvmeta_tmp->v = pvmeta_tmp->v->next;
-		pvmeta_tmp = dm_config_find_node(pvmeta->root, "pvmeta/device");
-		pvmeta_tmp->v->v.i = alt_device;
-	} else if (device != prim_device)
-		alt_device = prim_device;
-
-	/* it is an alternate device */
-	if (device > 0 && v && v->v.i == device)
-		pvmeta_tmp->v = v->next;
-	else while (device > 0 && pvmeta_tmp && v) {
-		if (v->next && v->next->v.i == device)
-			v->next = v->next->next;
-		v = v->next;
-	}
-
-	return alt_device;
-}
-
 static response pv_gone(lvmetad_state *s, request r)
 {
 	const char *arg_pvid = NULL;
 	char *old_pvid = NULL;
 	const char *pvid;
 	int64_t device;
-	int64_t alt_device = 0;
 	struct dm_config_tree *pvmeta;
 	char *vgid;
 
@@ -1938,17 +1904,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
-
-	alt_device = device_remove(s, pvmeta, device);
-
-	if (!alt_device) {
-		/* The PV was not a duplicate, so remove it. */
-		dm_hash_remove(s->pvid_to_pvmeta, pvid);
-	} else {
-		/* The PV remains on another device. */
-		DEBUGLOG(s, "pv_gone %s device %" PRIu64 " has alt_device %" PRIu64,
-			 pvid, device, alt_device);
-	}
+	dm_hash_remove(s->pvid_to_pvmeta, pvid);
 
 	unlock_pvid_to_pvmeta(s);
 
@@ -1970,18 +1926,11 @@ static response pv_gone(lvmetad_state *s, request r)
 		vgid = NULL;
 	}
 
-	if (!alt_device) {
-		dm_config_destroy(pvmeta);
-		if (old_pvid)
-			dm_free(old_pvid);
-	}
+	dm_config_destroy(pvmeta);
+	if (old_pvid)
+		dm_free(old_pvid);
 
-	if (alt_device) {
-		return daemon_reply_simple("OK",
-					   "device = %"PRId64, alt_device,
-					   NULL);
-	} else
-		return daemon_reply_simple("OK", NULL );
+	return daemon_reply_simple("OK", NULL );
 }
 
 static response pv_clear_all(lvmetad_state *s, request r)
@@ -2100,10 +2049,7 @@ static response pv_found(lvmetad_state *s, request r)
 	struct dm_config_tree *new_pvmeta = NULL;
 	struct dm_config_tree *prev_pvmeta_on_dev = NULL;
 	struct dm_config_tree *vgmeta = NULL;
-	struct dm_config_node *altdev = NULL;
-	struct dm_config_value *altdev_v = NULL;
 	const char *arg_pvid = NULL;
-	const char *arg_pvid_dup = NULL;
 	const char *arg_pvid_lookup = NULL;
 	const char *new_pvid = NULL;
 	const char *new_pvid_dup = NULL;
@@ -2281,40 +2227,14 @@ static response pv_found(lvmetad_state *s, request r)
 	} else if (new_pvid && !new_device) {
 		/*
 		 * New PV on old device (existing device reused for new PV).
-		 * The previous PV on arg_device may or may not still exist,
-		 * this is determined by device_remove() which checks the
-		 * pvmeta for the previous PV (prev_pvid_on_dev and
-		 * prev_pvmeta_on_dev) to see if arg_device was the only
-		 * device for the PV, or if arg_device was a duplicate for
-		 * the PV.  If arg_device was previously a duplicate, then
-		 * the prev PV should be kept, but with arg_device removed.
-		 * If arg_device was the only device for the prev PV, then
-		 * the prev PV should be removed entirely.
+		 * The previous PV on arg_device is replaced by the new one.
 		 *
-		 * In either case, don't free prev_pvid or prev_vgid
-		 * strings because they are used at the end to check
-		 * the VG metadata.
+		 * Don't free prev_pvid or prev_vgid strings because they are
+		 * used at the end to check the VG metadata.
 		 */
 		changed |= 1;
 
-		if (prev_pvmeta_on_dev &&
-		    !device_remove(s, prev_pvmeta_on_dev, arg_device)) {
-			/*
-			 * The prev PV has no remaining device after
-			 * removing arg_device, so arg_device was not a
-			 * duplicate; remove the prev PV entirely.
-			 *
-			 * (hash_remove in pvid_to_vgid is done at the
-			 * end after the VG metadata is checked)
-			 *
-			 * FIXME: we could check if the new pvid is a new
-			 * duplicate of another existing PV.  This can happen:
-			 * start with two different pvs A and B,
-			 * dd if=A of=B, pvscan --cache B.  This detects that
-			 * B is removed, but doesn't detect that A is now a
-			 * duplicate.  ('pvscan --cache' does detect the
-			 * dup because all pvs are scanned.)
-			 */
+		if (prev_pvmeta_on_dev) {
 			DEBUGLOG(s, "pv_found new pvid device_to_pvid %" PRIu64 " to %s removes prev pvid %s",
 				 arg_device, new_pvid, prev_pvid_on_dev);
 
@@ -2324,23 +2244,24 @@ static response pv_found(lvmetad_state *s, request r)
 
 			/* removes arg_device/prev_pvid_on_dev mapping */
 			dm_hash_remove_binary(s->device_to_pvid, &arg_device, sizeof(arg_device));
-		} else {
+
 			/*
-			 * The prev PV existing on a remaining alternate
-			 * device after removing arg_device, so arg_device
-			 * was a duplicate; keep the prev PV.
-			 *
-			 * FIXME: if the duplicate devices were path aliases
-			 * to the same underlying device, then keeping the
-			 * prev PV for the remaining alt device isn't nice.
+			 * The new PV replacing the prev PV was copied from
+			 * another existing PV, creating a duplicate PV which
+			 * we ignore.
 			 */
-			DEBUGLOG(s, "pv_found new pvid device_to_pvid %" PRIu64 " to %s keeping prev pvid %s",
-				 arg_device, new_pvid, prev_pvid_on_dev);
-
-			/* removes arg_device/prev_pvid_on_dev mapping */
-			dm_hash_remove_binary(s->device_to_pvid, &arg_device, sizeof(arg_device));
+			if (dm_hash_lookup(s->pvid_to_pvmeta, new_pvid)) {
+				DEBUGLOG(s, "pv_found ignore duplicate device %" PRIu64 " of existing PV for pvid %s",
+				         arg_device, arg_pvid);
+				unlock_pvid_to_pvmeta(s);
+				dm_config_destroy(new_pvmeta);
+				s->flags |= GLFL_DISABLE;
+				s->flags |= GLFL_DISABLE_REASON_DUPLICATES;
+				return reply_fail("Ignore duplicate PV");
+			}
 		}
 
+
 		if (!(new_pvid_dup = dm_strdup(new_pvid)))
 			goto nomem;
 
@@ -2353,57 +2274,15 @@ static response pv_found(lvmetad_state *s, request r)
 	} else if (new_device && !new_pvid) {
 		/*
 		 * Old PV on new device (duplicate)
-		 * . add new_device/arg_pvid mapping
-		 * . leave existing old_device/arg_pvid mapping
-		 * . add new_pvmeta, replacing old_pvmeta
-		 * . modify new_pvmeta, adding an alternate device entry for old_device
+		 * Ignore it.
 		 */
-		changed |= 1;
-
-		DEBUGLOG(s, "pv_found new device device_to_pvid %" PRIu64 " to %s also %" PRIu64 " to %s",
-			 new_device, arg_pvid, old_device, arg_pvid);
-
-		if (!(arg_pvid_dup = dm_strdup(arg_pvid)))
-			goto nomem;
-
-		if (!dm_hash_insert_binary(s->device_to_pvid, &new_device, sizeof(new_device), (char *)arg_pvid_dup))
-			goto nomem;
-
-		if (!dm_hash_insert(s->pvid_to_pvmeta, arg_pvid, new_pvmeta))
-			goto nomem;
-
-		/* Copy existing altdev info, or create new, and add it to new pvmeta. */
-		if ((altdev = dm_config_find_node(old_pvmeta->root, "pvmeta/devices_alternate"))) {
-			if (!(altdev = dm_config_clone_node(new_pvmeta, altdev, 0)))
-				goto nomem;
-			chain_node(altdev, new_pvmeta->root, 0);
-		} else {
-			if (!(altdev = make_config_node(new_pvmeta, "devices_alternate", new_pvmeta->root, 0)))
-				goto nomem;
-		}
-
-		/* Add an altdev entry for old_device. */
-		altdev_v = altdev->v;
-		while (1) {
-			if (altdev_v && altdev_v->v.i == old_device)
-				break;
-			if (altdev_v)
-				altdev_v = altdev_v->next;
-			if (!altdev_v) {
-				if (!(altdev_v = dm_config_create_value(new_pvmeta)))
-					goto nomem;
-				altdev_v->next = altdev->v;
-				altdev->v = altdev_v;
-				altdev->v->v.i = old_device;
-				break;
-			}
-		};
-		altdev_v = altdev->v;
-		while (altdev_v) {
-			if (altdev_v->next && altdev_v->next->v.i == new_device)
-				altdev_v->next = altdev_v->next->next;
-			altdev_v = altdev_v->next;
-		}
+		DEBUGLOG(s, "pv_found ignore duplicate device %" PRIu64 " of existing device %" PRIu64 " for pvid %s",
+			 new_device, old_device, arg_pvid);
+		unlock_pvid_to_pvmeta(s);
+		dm_config_destroy(new_pvmeta);
+		s->flags |= GLFL_DISABLE;
+		s->flags |= GLFL_DISABLE_REASON_DUPLICATES;
+		return reply_fail("Ignore duplicate PV");
 	}
 
 	unlock_pvid_to_pvmeta(s);


