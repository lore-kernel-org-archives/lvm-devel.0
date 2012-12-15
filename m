From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:33 +0000 (UTC)
Subject: master - lvmetad: fix memleak on pv_found error path
Message-ID: <20121215162533.D7C49AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba3f37c9e4971ba4538cb74e9e7b60e3772da793
Commit:        ba3f37c9e4971ba4538cb74e9e7b60e3772da793
Parent:        399fc1bb33119d281f57108dba4bd9cd479ed8a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 16:43:42 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:27 2012 +0100

lvmetad: fix memleak on pv_found error path

Free resources allocated in pv_found when going out
through error path.
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dd8ae68..d535d10 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix memleak on error path for lvmetad's pv_found.
   Unlock vg mutex in error path when lvmetad tries to lock_vg.
   Add check for key string duplication in config_make_nodes_v.
   Add check for created fid in _scan_file.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index cbeaae1..ef3f8fe 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -827,7 +827,7 @@ static response pv_found(lvmetad_state *s, request r)
 	uint64_t device;
 	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
 	char *old;
-	const char *pvid_dup;
+	char *pvid_dup;
 	int complete = 0, orphan = 0;
 	int64_t seqno = -1, seqno_old = -1;
 
@@ -854,13 +854,23 @@ static response pv_found(lvmetad_state *s, request r)
 	if (!(cft = dm_config_create()) ||
 	    !(cft->root = dm_config_clone_node(cft, pvmeta, 0))) {
 		unlock_pvid_to_pvmeta(s);
+		if (cft)
+			dm_config_destroy(cft);
+		return reply_fail("out of memory");
+	}
+
+	if (!(pvid_dup = dm_strdup(pvid))) {
+		unlock_pvid_to_pvmeta(s);
+		dm_config_destroy(cft);
 		return reply_fail("out of memory");
 	}
 
-	pvid_dup = dm_strdup(pvid);
 	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
 	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup)) {
 		unlock_pvid_to_pvmeta(s);
+		dm_hash_remove(s->pvid_to_pvmeta, pvid);
+		dm_config_destroy(cft);
+		dm_free(pvid_dup);
 		return reply_fail("out of memory");
 	}
 	if (pvmeta_old_pvid)


