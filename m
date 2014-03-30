From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:46:02 +0000 (UTC)
Subject: master - cleanup: vgexport drops pv pointer
Message-ID: <20140330214602.4122E602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7b63340793b32e24f9e695c29d97014339fb3ec
Commit:        d7b63340793b32e24f9e695c29d97014339fb3ec
Parent:        31d68b7124519b4ed6b9ba1960cb021962f2a3dd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 22:40:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:44:59 2014 +0200

cleanup: vgexport drops pv pointer

PV pointer is not really needed.
---
 tools/vgexport.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/tools/vgexport.c b/tools/vgexport.c
index ad658f8..d9f8efa 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -21,7 +21,6 @@ static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 			   void *handle __attribute__((unused)))
 {
 	struct pv_list *pvl;
-	struct physical_volume *pv;
 
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group \"%s\" has active logical volumes",
@@ -34,10 +33,8 @@ static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 
 	vg->status |= EXPORTED_VG;
 
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		pv = pvl->pv;
-		pv->status |= EXPORTED_VG;
-	}
+	dm_list_iterate_items(pvl, &vg->pvs)
+		pvl->pv->status |= EXPORTED_VG;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		goto_bad;


