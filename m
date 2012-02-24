From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 24 Feb 2012 00:24:38 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120224002438.4034.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-24 00:24:37

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Fix server-side leaks in lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/24 00:11:59	1.41
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/24 00:24:37	1.42
@@ -365,12 +365,14 @@
 	if (!pvid) {
 		debug("pv_lookup: could not find device %" PRIu64 "\n", devt);
 		unlock_pvid_to_pvmeta(s);
+		dm_config_destroy(res.cft);
 		return daemon_reply_simple("failed", "reason = %s", "device not found", NULL);
 	}
 
 	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
 	if (!pv) {
 		unlock_pvid_to_pvmeta(s);
+		dm_config_destroy(res.cft);
 		return daemon_reply_simple("failed", "reason = %s", "PV not found", NULL);
 	}
 
@@ -761,7 +763,7 @@
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
 	uint64_t device;
-	struct dm_config_tree *cft;
+	struct dm_config_tree *cft, *pvmeta_old = NULL;
 	const char *old;
 	const char *pvid_dup;
 	int complete = 0, orphan = 0;
@@ -778,14 +780,18 @@
 
 	lock_pvid_to_pvmeta(s);
 
-	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device))))
+	if ((old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device)))) {
+		pvmeta_old = dm_hash_lookup(s->pvid_to_pvmeta, old);
 		dm_hash_remove(s->pvid_to_pvmeta, old);
+	}
 
 	cft = dm_config_create();
 	cft->root = dm_config_clone_node(cft, pvmeta, 0);
 	pvid_dup = dm_config_find_str(cft->root, "pvmeta/id", NULL);
 	dm_hash_insert(s->pvid_to_pvmeta, pvid, cft);
 	dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup);
+	if (pvmeta_old)
+		dm_config_destroy(pvmeta_old);
 
 	unlock_pvid_to_pvmeta(s);
 


