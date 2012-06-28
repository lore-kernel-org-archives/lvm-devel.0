From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Jun 2012 13:49:09 +0000 (UTC)
Subject: master - lvchange: add --activate ay (autoactivate)
Message-ID: <20120628134909.9DE991734@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9b9077b44119db0bfd926730cb79ebf0990c980
Commit:        c9b9077b44119db0bfd926730cb79ebf0990c980
Parent:        d2df8dddc8c04973a3e23b7a19e9bfbf8c45f79e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 27 10:43:20 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 28 09:44:07 2012 -0400

lvchange: add --activate ay (autoactivate)

The same as for vgchange...
---
 WHATS_NEW        |    1 +
 tools/commands.h |    2 +-
 tools/lvchange.c |    6 ++++++
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 481e8e3..ec554bf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add --activate ay to lvchange.
   Add --activate ay to pvscan.
   Add --activate ay to vgchange.
   Add support for volume autoactivation using lvmetad.
diff --git a/tools/commands.h b/tools/commands.h
index 21791f7..b863c66 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -61,7 +61,7 @@ xx(lvchange,
    CACHE_VGMETADATA | PERMITTED_READ_ONLY,
    "lvchange\n"
    "\t[-A|--autobackup y|n]\n"
-   "\t[-a|--activate [e|l]y|n]\n"
+   "\t[-a|--activate [a|e|l]{y|n}]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous y|n]\n"
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4d040be..9876847 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -136,6 +136,12 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
 		lv = origin_from_cow(lv);
 
+	if (activate == CHANGE_AAY) {
+		if (!lv_passes_auto_activation_filter(cmd, lv))
+			return 1;
+		activate = CHANGE_ALY;
+	}
+
 	if (activate == CHANGE_ALN) {
 		log_verbose("Deactivating logical volume \"%s\" locally",
 			    lv->name);


