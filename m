From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 13:41:42 +0000 (UTC)
Subject: master - pvremove: add warn when removing PV in use
Message-ID: <20160223134142.C4F6560E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e717ce555bffc9e8ea2dd981f733e55a2cde26ba
Commit:        e717ce555bffc9e8ea2dd981f733e55a2cde26ba
Parent:        7d8a67714f3f35bef066f4c550b16193d8bc2cd8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 14:10:45 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:40:30 2016 +0100

pvremove: add warn when removing PV in use

Reshuffle messages during pvremove.

Always print WARNING: when PV is in use so using options
--force --force doesn't make this important user
notification go away.

Simplify variable 'used' usage (so older gcc doesn't warn
about the use of unitilizied variable).

Add some '.' into messages.
---
 WHATS_NEW               |    1 +
 lib/metadata/pv_manip.c |   68 ++++++++++++++++++++++-------------------------
 2 files changed, 33 insertions(+), 36 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8c11277..378150c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Always warn user about PV in use even when pvremove uses --force --force.
   Use uninitilized pool header detection in all cases.
   Fir read error detection when checking for uninitialized thin-pool header.
   Fix error path for internal error in lvmetad vg lookup code.
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 8c3a5dd..4a0992b 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -695,8 +695,6 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 			  unsigned force_count, unsigned prompt, struct dm_list *pvslist)
 {
 	static const char really_wipe_msg[] = "Really WIPE LABELS from physical volume";
-	static const char not_removed_msg[] = "physical volume label not removed";
-	static const char pvremove_force_hint_msg[] = "(If you are certain you need pvremove, then confirm by using --force twice.)";
 	struct device *dev;
 	struct label *label;
 	struct pv_list *pvl;
@@ -707,7 +705,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	if (!(dev = dev_cache_get(name, cmd->filter))) {
-		log_error("Device %s not found", name);
+		log_error("Device %s not found.", name);
 		return 0;
 	}
 
@@ -725,8 +723,8 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 			pv = pvl->pv;
 
 	if (!pv) {
-		log_error(INTERNAL_ERROR "Physical Volume %s has a label,"
-			  " but is neither in a VG nor orphan.", name);
+		log_error(INTERNAL_ERROR "Physical Volume %s has a label, "
+			  "but is neither in a VG nor orphan.", name);
 		goto out; /* better safe than sorry */
 	}
 
@@ -734,49 +732,47 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 		if ((used = is_used_pv(pv)) < 0)
 			goto_out;
 
-		if (used && force_count < 2) {
-			log_error("PV '%s' is marked as belonging to a VG "
-				  "but its metadata is missing.", name);
-			log_error("%s", pvremove_force_hint_msg);
-			goto out;
+		if (used) {
+			log_warn("WARNING: PV '%s' is marked as belonging to a VG "
+				 "but its metadata is missing.", name);
+
+			if (force_count < 2)
+				goto_bad;
+
+			if (!prompt &&
+			    yes_no_prompt("%s \"%s\" that is marked as belonging to a VG [y/n]? ",
+					  really_wipe_msg, name) == 'n')
+				goto_bad;
 		}
 	} else {
-		/* we must have -ff to overwrite a non orphan */
-		if (force_count < 2) {
-			log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
-			log_error("%s", pvremove_force_hint_msg);
-			goto out;
-		}
-	}
+		log_warn("WARNING: PV %s belongs to Volume Group %s "
+			 "(consider using vgreduce).", name, pv_vg_name(pv));
 
-	/* prompt */
-	if (!prompt) {
-		if (is_orphan(pv)) {
-			if (used) {
-				if (yes_no_prompt("%s \"%s\" that is marked as belonging to a VG [y/n]? ",
-						   really_wipe_msg, name) == 'n') {
-					log_error("%s: %s", name, not_removed_msg);
-					goto out;
-				}
-			}
-		} else {
-			if (yes_no_prompt("%s \"%s\" of volume group \"%s\" [y/n]? ",
-					  really_wipe_msg, name, pv_vg_name(pv)) == 'n') {
-				log_error("%s: %s", name, not_removed_msg);
-				goto out;
-			}
-		}
+		if (force_count < 2)
+			goto_bad;
+
+		if (!prompt &&
+		    yes_no_prompt("%s \"%s\" of volume group \"%s\" [y/n]? ",
+				  really_wipe_msg, name, pv_vg_name(pv)) == 'n')
+			goto_bad;
 	}
 
-	if (force_count) {
+	if (force_count)
 		log_warn("WARNING: Wiping physical volume label from "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
 			  pv_vg_name(pv),
 			  !is_orphan(pv) ? "\"" : "");
-	}
 
 	r = 1;
+bad:
+	if (!r) {
+		log_error("%s: physical volume label not removed.", name);
+
+		if (force_count < 2) /* Show hint as log_error() */
+			log_error("(If you are certain you need pvremove, "
+				  "then confirm by using --force twice.)");
+	}
 out:
 	return r;
 }


