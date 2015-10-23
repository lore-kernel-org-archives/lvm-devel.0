From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 23 Oct 2015 15:27:02 +0000 (UTC)
Subject: master - vgextend: fix use of the wrong flag
Message-ID: <20151023152702.40AF860FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=98d81a43ea31ec963a36b8610f3b5a9be28b4cc1
Commit:        98d81a43ea31ec963a36b8610f3b5a9be28b4cc1
Parent:        1a74171ca5682a684d0e05c6090c3d33cab8795b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 23 10:21:06 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 23 10:21:06 2015 -0500

vgextend: fix use of the wrong flag

The ONE_VGNAME_ARG was being passed and tested as
vg_read() flag but it's a cmd struct flag.

(It affects command arg processing in toollib,
not vg_read behavior.  Flags related to command
processing are generally cmd struct flags, while
vg_read arg flags are generally related to vg_read
behavior.)
---
 tools/commands.h |    2 +-
 tools/toollib.c  |    2 +-
 tools/vgextend.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 92d13fd..ae5dff7 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1211,7 +1211,7 @@ xx(vgexport,
 
 xx(vgextend,
    "Add physical volumes to a volume group",
-   0,
+   ONE_VGNAME_ARG,
    "vgextend\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--restoremissing]\n"
diff --git a/tools/toollib.c b/tools/toollib.c
index b17fe53..39bf0ac 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2032,7 +2032,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
 
 	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
-	unsigned one_vgname_arg = (flags & ONE_VGNAME_ARG);
+	int one_vgname_arg = (cmd->command->flags & ONE_VGNAME_ARG);
 	int ret;
 
 	/* Disable error in vg_read so we can print it from ignore_vg. */
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 581c211..bddc22f 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -170,7 +170,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 
 	ret = process_each_vg(cmd, argc, argv,
-			      READ_FOR_UPDATE | ONE_VGNAME_ARG, handle,
+			      READ_FOR_UPDATE, handle,
 			      restoremissing ? &_vgextend_restoremissing : &_vgextend_single);
 
 	destroy_processing_handle(cmd, handle);


