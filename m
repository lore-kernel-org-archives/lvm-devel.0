From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Nov 2014 17:17:36 +0000 (UTC)
Subject: master - vg_read: correct warning
Message-ID: <20141114171736.EFCBD60DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f36080a05d987d359e1c09e64d1222636dcd96ad
Commit:        f36080a05d987d359e1c09e64d1222636dcd96ad
Parent:        d8923457b82456ebee3e333b3fcc26087483cd01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 14 14:58:20 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 14 18:12:35 2014 +0100

vg_read: correct warning

Use log_warn when we are effectively not creating an error -
we 'allowed' inconsistent read for a reason - so it's just warning
level we process inconsistent VG - it's upto caller later to decide
error level of command return value and in case of error it needs
to use log_error then.
---
 lib/metadata/metadata.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 601a766..0c5b0d6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3567,8 +3567,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 		/* Don't touch if vgids didn't match */
 		if (inconsistent_vgid) {
-			log_error("Inconsistent metadata UUIDs found for "
-				  "volume group %s", vgname);
+			log_warn("WARNING: Inconsistent metadata UUIDs found for "
+				 "volume group %s.", vgname);
 			*consistent = 0;
 			_free_pv_list(&all_pvs);
 			return correct_vg;
@@ -3600,8 +3600,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				release_vg(correct_vg);
 				return_NULL;
 			}
-			log_error("Removing PV %s (%s) that no longer belongs to VG %s",
-				  pv_dev_name(pvl->pv), uuid, correct_vg->name);
+			log_warn("WARNING: Removing PV %s (%s) that no longer belongs to VG %s",
+				 pv_dev_name(pvl->pv), uuid, correct_vg->name);
 			if (!pv_write_orphan(cmd, pvl->pv)) {
 				_free_pv_list(&all_pvs);
 				release_vg(correct_vg);
@@ -3624,10 +3624,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	if ((correct_vg->status & PVMOVE) && !pvmove_mode()) {
-		log_error("WARNING: Interrupted pvmove detected in "
-			  "volume group %s", correct_vg->name);
-		log_error("Please restore the metadata by running "
-			  "vgcfgrestore.");
+		log_error("Interrupted pvmove detected in volume group %s.",
+			  correct_vg->name);
+		log_print("Please restore the metadata by running vgcfgrestore.");
 		release_vg(correct_vg);
 		return NULL;
 	}


