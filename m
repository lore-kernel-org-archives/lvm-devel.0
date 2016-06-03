From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  3 Jun 2016 15:02:24 +0000 (UTC)
Subject: master - pvmove: disallow tag args
Message-ID: <20160603150224.EC1A260C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b321d2b1b9a3b6a1f8d67888a04c7318aa3148c2
Commit:        b321d2b1b9a3b6a1f8d67888a04c7318aa3148c2
Parent:        68e097972462e3c7c208ac34c62e737b161dd3c4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 3 09:56:48 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 3 09:56:48 2016 -0500

pvmove: disallow tag args

pvmove began processing tags unintentionally from commit,
6d7dc87cb pvmove: use toollib

pvmove works on a single PV, but tags can match multiple PVs.
If we allowed tags, but processed only the first matching PV,
then the resulting PV would be unpredictable.

Also, the current processing code does not allow us to simply
report an error and do nothing if more than one PV matches the tag,
because the command starts processing PVs as they are found,
so it's too late to do nothing if a second PV matches.
---
 tools/commands.h |    4 +++-
 tools/toollib.c  |    5 +++++
 tools/tools.h    |    2 ++
 3 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index da432a7..888f3a2 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -874,9 +874,11 @@ xx(pvdisplay,
    select_ARG, separator_ARG, shared_ARG, short_ARG, sort_ARG, unbuffered_ARG,
    units_ARG)
 
+/* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
+
 xx(pvmove,
    "Move extents from one physical volume to another",
-   ALL_VGS_IS_DEFAULT,	/* For polldaemon to find pvmoves in-progress using process_each_vg. */
+   ALL_VGS_IS_DEFAULT | DISALLOW_TAG_ARGS,
    "pvmove\n"
    "\t[--abort]\n"
    "\t[--alloc AllocationPolicy]\n"
diff --git a/tools/toollib.c b/tools/toollib.c
index 0de6ee8..0563fea 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3375,6 +3375,11 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
+	if ((cmd->command->flags & DISALLOW_TAG_ARGS) && !dm_list_empty(&arg_tags)) {
+		log_error("Tags cannot be used with this command.");
+		return ECMD_FAILED;
+	}
+
 	orphans_locked = lvmcache_vgname_is_locked(VG_ORPHANS);
 
 	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
diff --git a/tools/tools.h b/tools/tools.h
index 2abc750..8704749 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -114,6 +114,8 @@ struct arg_value_group_list {
 #define NO_LVMETAD_AUTOSCAN      0x00000200
 /* Command should process unused duplicate devices. */
 #define ENABLE_DUPLICATE_DEVS    0x00000400
+/* Command does not accept tags as args. */
+#define DISALLOW_TAG_ARGS        0x00000800
  
 /* a register of the lvm commands */
 struct command {


