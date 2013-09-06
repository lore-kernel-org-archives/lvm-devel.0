From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  6 Sep 2013 00:53:19 +0000 (UTC)
Subject: master - tools: Use backgroundfork_ARG for pvscan -b
Message-ID: <20130906005319.A0F3B610D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5face2010dfb4e9fef43b867b4736a90abe51c00
Commit:        5face2010dfb4e9fef43b867b4736a90abe51c00
Parent:        374653f2b55fe06431e4db4ef8e3d4340cdab29b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Sep 6 01:43:24 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Sep 6 01:43:24 2013 +0100

tools: Use backgroundfork_ARG for pvscan -b

Change pvscan -b to use a new backgroundfork_ARG instead of
background_ARG so as not to affect pvmove -b and lvconvert -b.
---
 tools/args.h       |    1 +
 tools/commands.h   |    2 +-
 tools/lvmcmdline.c |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 4b89ebd..c5e4d14 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -114,6 +114,7 @@ arg(all_ARG, 'a', "all", NULL, 0)
 arg(autobackup_ARG, 'A', "autobackup", yes_no_arg, 0)
 arg(activevolumegroups_ARG, 'A', "activevolumegroups", NULL, 0)
 arg(background_ARG, 'b', "background", NULL, 0)
+arg(backgroundfork_ARG, 'b', "background", NULL, 0)
 arg(blockdevice_ARG, 'b', "blockdevice", NULL, 0)
 arg(chunksize_ARG, 'c', "chunksize", size_kb_arg, 0)
 arg(clustered_ARG, 'c', "clustered", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index ef7848d..a8623bf 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -736,7 +736,7 @@ xx(pvscan,
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   activate_ARG, available_ARG, background_ARG, cache_ARG,
+   activate_ARG, available_ARG, backgroundfork_ARG, cache_ARG,
    exported_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG,
    novolumegroup_ARG, partial_ARG, short_ARG, uuid_ARG)
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index dc5d592..c7917ea 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1097,7 +1097,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	set_cmd_name(cmd->command->name);
 
-	if (arg_count(cmd, background_ARG)) {
+	if (arg_count(cmd, backgroundfork_ARG)) {
 		if (!become_daemon(cmd, 1)) {
 			/* parent - quit immediately */
 			ret = ECMD_PROCESSED;


