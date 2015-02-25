From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 16:53:00 +0000 (UTC)
Subject: master - systemid: silently ignore foreign vgs unless named
Message-ID: <20150225165300.B830E60E1A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8668a9e81c5bde921c9c8e6ba1162c5d4f7ffbe5
Commit:        8668a9e81c5bde921c9c8e6ba1162c5d4f7ffbe5
Parent:        4ff9abd01f60e3bfe433da5596078a12fb49f9eb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 10:44:42 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 10:53:52 2015 -0600

systemid: silently ignore foreign vgs unless named

A foreign VG should be silently ignored by a reporting/display
command like 'vgs'.  If the reporting/display command specifies
a foreign VG by name on the command line, it should produce an
error message.

Scanning commands pvscan/vgscan/lvscan are always allowed to
read and update caches from all PVs, including those that belong
to foreign VGs.

Other non-report/display/scan commands always ignore a foreign
VG, or report an error if they attempt to use a foreign VG.

vgimport should always invalidate the lvmetad cache because
lvmetad likely holds a pre-vgexported copy of the VG.
(This is unrelated to using foreign VGs; the pre-vgexported
VG may have had no system_id at all.)
---
 lib/commands/toolcontext.h |    1 +
 lib/metadata/metadata.c    |   15 +++++++++++++--
 tools/commands.h           |   20 ++++++++++----------
 tools/lvmcmdline.c         |    6 +++---
 tools/tools.h              |    4 ++--
 tools/vgimport.c           |   11 +++++++++++
 6 files changed, 40 insertions(+), 17 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 8b38fb1..f491d1c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -98,6 +98,7 @@ struct cmd_context {
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
 	unsigned unknown_system_id:1;
 	unsigned include_foreign_vgs:1;
+	unsigned error_foreign_vgs:1;
 
 	struct dev_types *dev_types;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 71197ba..f011af8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4430,8 +4430,19 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 		return 0;
 	}
 
-	log_error("Cannot access VG %s with system id \"%s\" with local system ID %s.",
-		  vg->name, vg->system_id, cmd->system_id);
+	/*
+	 * Some commands always produce an error when accessing foreign VG.
+	 */
+	if (cmd->error_foreign_vgs) {
+		log_error("Cannot access VG %s with system id \"%s\" with local system ID %s.",
+			  vg->name, vg->system_id, cmd->system_id);
+		return 0;
+	}
+
+	/*
+	 * When include_foreign_vgs is 0 and error_foreign_vgs is 0,
+	 * the result is to silently ignore foreign vgs.
+	 */
 
 	return 0;
 }
diff --git a/tools/commands.h b/tools/commands.h
index 00708f6..3cb8f56 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -356,7 +356,7 @@ xx(lvcreate,
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
    "lvdisplay\n"
    "\t[-a|--all]\n"
    "\t[-c|--colon]\n"
@@ -578,7 +578,7 @@ xx(lvresize,
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
    "lvs\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -616,7 +616,7 @@ xx(lvs,
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
    "lvscan\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice]\n"
@@ -742,7 +742,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_FOREIGN_VGS,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -833,7 +833,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_FOREIGN_VGS,
    "pvs\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -871,7 +871,7 @@ xx(pvs,
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ENABLE_FOREIGN_VGS,
    "pvscan\n"
    "\t[-b|--background]\n"
    "\t[--cache [-a|--activate ay] [ DevicePath | -j|--major major --minor minor]...]\n"
@@ -1056,7 +1056,7 @@ xx(vgcreate,
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
    "vgdisplay\n"
    "\t[-A|--activevolumegroups]\n"
    "\t[-c|--colon | -s|--short | -v|--verbose]\n"
@@ -1142,7 +1142,7 @@ xx(vgextend,
 
 xx(vgimport,
    "Register exported volume group with system",
-   ALL_VGS_IS_DEFAULT | NEEDS_FOREIGN_VGS,
+   ALL_VGS_IS_DEFAULT,
    "vgimport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -1244,7 +1244,7 @@ xx(vgrename,
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
    "vgs\n"
    "\t[--aligned]\n"
    "\t[--binary]\n"
@@ -1281,7 +1281,7 @@ xx(vgs,
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
    "vgscan "
    "\t[--cache]\n"
    "\t[--commandprofile ProfileName]\n"
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b38039b..7a11183 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1075,9 +1075,9 @@ static int _get_settings(struct cmd_context *cmd)
 		init_ignorelockingfailure(0);
 
 	cmd->ignore_clustered_vgs = arg_is_set(cmd, ignoreskippedcluster_ARG);
-	cmd->include_foreign_vgs =
-	     ((cmd->command->flags & NEEDS_FOREIGN_VGS) || arg_is_set(cmd, foreign_ARG)) ? 1 : 0;
-
+	cmd->error_foreign_vgs = cmd->command->flags & ENABLE_FOREIGN_VGS ? 0 : 1;
+	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG) ? 1 : 0;
+		
 	if (!arg_count(cmd, sysinit_ARG))
 		lvmetad_connect_or_warn();
 
diff --git a/tools/tools.h b/tools/tools.h
index be4b166..1f344b0 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -108,8 +108,8 @@ struct arg_value_group_list {
 #define ENABLE_ALL_DEVS		0x00000008	
 /* Exactly one VG name argument required. */
 #define ONE_VGNAME_ARG		0x00000010
-/* Processes foreign VGs by default */
-#define NEEDS_FOREIGN_VGS	0x00000020
+/* Command is allowed to read foreign VGs. */
+#define ENABLE_FOREIGN_VGS	0x00000020
  
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 7000284..b416e21 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -85,6 +85,17 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		cmd->handles_missing_pvs = 1;
 	}
 
+	/*
+	 * Rescan devices and update lvmetad.  lvmetad may hold a copy of the
+	 * VG from before it was exported, if it was exported by another host.
+	 * We need to reread it to see that it's been exported before we can
+	 * import it.
+	 */
+	if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL)) {
+		log_error("Failed to scan devices.");
+		return ECMD_FAILED;
+	}
+
 	return process_each_vg(cmd, argc, argv,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       NULL,


