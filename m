From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  2 Mar 2015 11:18:40 +0000 (UTC)
Subject: master - metadata: vg: add missing vg->lvm1_system_id initialization
Message-ID: <20150302111840.E1D63606D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eeaf3f2e88ef2c664b5cbefb9c9a9e7ada0c752b
Commit:        eeaf3f2e88ef2c664b5cbefb9c9a9e7ada0c752b
Parent:        047fe6c59fe2cf3a52208b219caebed469ed6bdc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 2 12:16:55 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 2 12:17:27 2015 +0100

metadata: vg: add missing vg->lvm1_system_id initialization

The vg->lvm1_systemd_id needs to be initialized as all the code around
counts with that. Just like we initialize lvm1_system_id in vg_create
(no matter if it's actually LVM1 or LVM2 format), this patch adds this
init in alloc_vg as well so the rest of the code does not segfaul
 when trying to access vg->lvm1_system_id.
---
 lib/metadata/vg.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 446aa7c..2993655 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -57,6 +57,12 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
 
+	if (!(vg->lvm1_system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1))) {
+		log_error("Failed to allocate VG systemd id.");
+		dm_pool_destroy(vgmem);
+		return NULL;
+	}
+
 	log_debug_mem("Allocated VG %s at %p.", vg->name, vg);
 
 	return vg;


