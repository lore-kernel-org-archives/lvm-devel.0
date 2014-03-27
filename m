From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:15:17 +0000 (UTC)
Subject: master - lv_rename: validate renamed sublv
Message-ID: <20140327121517.9737C6196E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22579b4451b00b50ad7e6acacf9265fa41620449
Commit:        22579b4451b00b50ad7e6acacf9265fa41620449
Parent:        28e4bf0b6dae2cad6bb996c0c87d41b256f59517
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 27 10:35:51 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:06:23 2014 +0100

lv_rename: validate renamed sublv

Use proper vgmem memory pool for allocation of LV name in the vg
and check if new renamed LV is a valid name.

TODO: validation should really use also VG name, othewise we are not
able to tell "vgname-lvname" will be valid.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 007fb75..71b074a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Validate name for renamed sub LVs.
   When lvrename fails on argument parsing return invalid cmd line error (5->3).
   Fix exit code regression in failing pvchange command (2.02.66).
   Include 'lvm dumpconfig --type missing' and '--type diff' output to lvmdump.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6e4ba71..ae0bef2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3225,7 +3225,7 @@ static int _rename_sub_lv(struct cmd_context *cmd,
 	 *	a new name for main LV is "lvol1"
 	 */
 	len = strlen(lv_name_new) + strlen(suffix) + 1;
-	new_name = dm_pool_alloc(cmd->mem, len);
+	new_name = dm_pool_alloc(lv->vg->vgmem, len);
 	if (!new_name) {
 		log_error("Failed to allocate space for new name");
 		return 0;
@@ -3235,6 +3235,12 @@ static int _rename_sub_lv(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!validate_name(new_name)) {              *
+		log_error("Cannot rename \"%s\". New logical volume name \"%s\" is invalid.",
+			  lv->name, new_name);
+		return 0;
+	}
+
 	/* Rename it */
 	return _rename_single_lv(lv, new_name);
 }


