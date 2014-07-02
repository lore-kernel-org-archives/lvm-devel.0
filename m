From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:37 +0000 (UTC)
Subject: master - lvremove: remove thin volumes on damaged pools
Message-ID: <20140702084837.E212561054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93a80018ae8e2f3f56e56b42237779661c9040b3
Commit:        93a80018ae8e2f3f56e56b42237779661c9040b3
Parent:        0b872ce870b753d034da919814c13703606af188
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 2 00:13:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:37:52 2014 +0200

lvremove: remove thin volumes on damaged pools

Support remove of thin volumes With --force --force
when thin pools is damaged.

This way it's possible to remove thin pool with
unrepairable metadata without requiring to
manually edit lvm2 metadata.

lvremove -ff vg/pool

removes all thin volumes and pool even when
thin pool cannot be activated (to accept
removal of thin volumes in kernel metadata)
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 846983f..230bdf0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Support lvremove -ff to remove thin volumes from broken thin pools.
   Require --yes to skip raid repair prompt.
   Change makefile %.d generation to handle filename changes without make clean.
   Fix use of buildir in make pofile.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d35a244..537ec30 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4923,8 +4923,13 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* Clear thin pool stacked messages */
 	if (pool_lv && !pool_has_message(first_seg(pool_lv), lv, 0) &&
 	    !update_pool_lv(pool_lv, 1)) {
-		log_error("Failed to update thin pool %s.", pool_lv->name);
-		return 0;
+		if (force < DONT_PROMPT_OVERRIDE) {
+			log_error("Failed to update thin pool %s.", pool_lv->name);
+			return 0;
+		}
+		log_warn("WARNING: Forced to ignoring failure of pool metadata update %s.",
+			 pool_lv->name);
+		pool_lv = NULL; /* Do not retry */
 	}
 
 	visible = lv_is_visible(lv);


