From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:20 +0000 (UTC)
Subject: master - liblvm: check lvmetad cache return values
Message-ID: <20130722104220.7179760DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=baada4316dd2fcf0383ed7bcfa539c0429e17131
Commit:        baada4316dd2fcf0383ed7bcfa539c0429e17131
Parent:        dedec81d7b939650f390c0be5a23632b39d83012
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 17:31:13 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:21 2013 +0200

liblvm: check lvmetad cache return values

Missing error path.
---
 liblvm/lvm_vg.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index c128ba7..3f4968e 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -362,13 +362,17 @@ int lvm_vg_set_property(const vg_t vg, const char *name,
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
-	lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh);
+	if (!lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh))
+		return NULL;
+
 	return get_vgnames((struct cmd_context *)libh, 0);
 }
 
 struct dm_list *lvm_list_vg_uuids(lvm_t libh)
 {
-	lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh);
+	if (!lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh))
+		return NULL;
+
 	return get_vgids((struct cmd_context *)libh, 0);
 }
 


