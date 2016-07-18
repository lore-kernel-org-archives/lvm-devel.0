From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jul 2016 16:32:17 +0000 (UTC)
Subject: master - lvmetad: free memory on exit
Message-ID: <20160718163217.A3F9160575@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b4d4670042db3edb1270097f4d6046a6a827bac
Commit:        4b4d4670042db3edb1270097f4d6046a6a827bac
Parent:        9c6a26f50ac6be27b6e8d8405fc980c8515e9e8c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 18 11:31:00 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 18 11:31:00 2016 -0500

lvmetad: free memory on exit

This is unnecessary but it quiets complaints (valgrind).
---
 daemons/lvmetad/lvmetad-core.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index c4c1d68..ebaca78 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -808,6 +808,7 @@ static int _update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 
 		if (!dm_hash_insert(s->pvid_to_vgid, pvid, vgid_dup)) {
 			ERROR(s, "update_pvid_to_vgid out of memory for hash insert vgid %s", vgid_dup);
+			dm_free(vgid_dup);
 			goto abort_daemon;
 		}
 
@@ -829,6 +830,8 @@ static int _update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 
 abort_daemon:
 	ERROR(s, "lvmetad could not be updated and is aborting.");
+	if (to_check)
+		dm_hash_destroy(to_check);
 	exit(EXIT_FAILURE);
 }
 
@@ -1201,6 +1204,10 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 out:
 out_free:
 	if (!new_name_dup || !new_vgid_dup || abort_daemon) {
+		if (new_name_dup)
+			dm_free(new_name_dup);
+		if (new_vgid_dup)
+			dm_free(new_vgid_dup);
 		ERROR(s, "lvmetad could not be updated and is aborting.");
 		exit(EXIT_FAILURE);
 	}
@@ -2051,7 +2058,7 @@ static response pv_found(lvmetad_state *s, request r)
 			changed |= 1;
 
 		if (!dm_hash_insert(s->pvid_to_pvmeta, arg_pvid, new_pvmeta))
-			goto nomem;
+			goto nomem_free1;
 
 	} else if (new_pvid && new_device) {
 		/*
@@ -2065,13 +2072,13 @@ static response pv_found(lvmetad_state *s, request r)
 			 new_device, new_pvid);
 
 		if (!(new_pvid_dup = dm_strdup(new_pvid)))
-			goto nomem;
+			goto nomem_free1;
 
 		if (!dm_hash_insert_binary(s->device_to_pvid, &new_device, sizeof(new_device), (char *)new_pvid_dup))
-			goto nomem;
+			goto nomem_free2;
 
 		if (!dm_hash_insert(s->pvid_to_pvmeta, new_pvid, new_pvmeta))
-			goto nomem;
+			goto nomem_free1;
 
 	} else if (new_pvid && !new_device) {
 		/*
@@ -2111,13 +2118,13 @@ static response pv_found(lvmetad_state *s, request r)
 
 
 		if (!(new_pvid_dup = dm_strdup(new_pvid)))
-			goto nomem;
+			goto nomem_free1;
 
 		if (!dm_hash_insert_binary(s->device_to_pvid, &arg_device, sizeof(arg_device), (char *)new_pvid_dup))
-			goto nomem;
+			goto nomem_free2;
 
 		if (!dm_hash_insert(s->pvid_to_pvmeta, new_pvid, new_pvmeta))
-			goto nomem;
+			goto nomem_free1;
 
 	} else if (new_device && !new_pvid) {
 		/*
@@ -2225,6 +2232,10 @@ static response pv_found(lvmetad_state *s, request r)
 				   "seqno_after = " FMTd64, (int64_t) vg_status_seqno,
 				   NULL);
 
+ nomem_free2:
+	dm_free((char *)new_pvid_dup);
+ nomem_free1:
+	dm_config_destroy(new_pvmeta);
  nomem:
 	ERROR(s, "pv_found %s is out of memory.", arg_pvid);
 	ERROR(s, "lvmetad could not be updated is aborting.");


