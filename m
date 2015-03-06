From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:44 +0000 (UTC)
Subject: master - lib: drop unneeded vg_read call
Message-ID: <20150306133144.4F0DE600E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04101bc4307e14f71f6ca3a1d253761f82e6a76e
Commit:        04101bc4307e14f71f6ca3a1d253761f82e6a76e
Parent:        a9b28a4f2105b92fdfc9f3915859e0deec4004a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 6 10:22:33 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 14:05:06 2015 +0100

lib: drop unneeded vg_read call

Since we take a lock inside vg_lock_newname() and we do a full
detection of presence of  vgname inside all scanned labels,
there is no point to do this for second time to be sure
there is no such vg.

The only side-effect of such call would be a full validation of
some already exising VG metadata - but that's not the task for
vgcreate when create a new VG.

This call noticable reduces number of scans during 'vgcreate'.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   10 ----------
 2 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9bf8699..680879d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Don't do a full read of VG when creating a new VG with an existing name.
   Reduce number of VG metadata parsing when looking for vgname on a PV.
   Avoid reparsing same metadata when reading same metadata from multiple PVs.
   Save extra device open/close when scanning device for size.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 57066a5..f495bdd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1009,7 +1009,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 		.context.vg_ref.vg_name = vg_name
 	};
 	struct format_instance *fid;
-	int consistent = 0;
 	uint32_t rc;
 
 	if (!validate_name(vg_name)) {
@@ -1023,15 +1022,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 		/* NOTE: let caller decide - this may be check for existence */
 		return _vg_make_handle(cmd, NULL, rc);
 
-	/* FIXME: Is this vg_read_internal necessary? Move it inside
-	   vg_lock_newname? */
-	/* is this vg name already in use ? */
-	if ((vg = vg_read_internal(cmd, vg_name, NULL, WARN_PV_READ, &consistent))) {
-		log_error("A volume group called '%s' already exists.", vg_name);
-		unlock_and_release_vg(cmd, vg, vg_name);
-		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
-	}
-
 	/* Strip dev_dir if present */
 	vg_name = strip_dir(vg_name, cmd->dev_dir);
 


