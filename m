From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  2 Mar 2015 12:01:37 +0000 (UTC)
Subject: master - metadata: vg: alloc lvm1_system_id in alloc_vg sooner
Message-ID: <20150302120137.E4430610D2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a41e649a68b03fd6ea4769ed06e83f9d9785c45
Commit:        1a41e649a68b03fd6ea4769ed06e83f9d9785c45
Parent:        eeaf3f2e88ef2c664b5cbefb9c9a9e7ada0c752b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 2 13:00:37 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 2 13:00:45 2015 +0100

metadata: vg: alloc lvm1_system_id in alloc_vg sooner

---
 lib/metadata/vg.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 2993655..2bed1ad 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -41,6 +41,12 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 		return NULL;
 	}
 
+	if (!(vg->lvm1_system_id = dm_pool_zalloc(vgmem, NAME_LEN + 1))) {
+		log_error("Failed to allocate VG systemd id.");
+		dm_pool_destroy(vgmem);
+		return NULL;
+	}
+
 	vg->cmd = cmd;
 	vg->vgmem = vgmem;
 	vg->alloc = ALLOC_NORMAL;
@@ -57,12 +63,6 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
 
-	if (!(vg->lvm1_system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1))) {
-		log_error("Failed to allocate VG systemd id.");
-		dm_pool_destroy(vgmem);
-		return NULL;
-	}
-
 	log_debug_mem("Allocated VG %s at %p.", vg->name, vg);
 
 	return vg;


