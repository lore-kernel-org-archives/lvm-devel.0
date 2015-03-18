From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Mar 2015 23:58:18 +0000 (UTC)
Subject: master - toollib: Reorder process_each_pv initialisation.
Message-ID: <20150318235818.F03896025C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19c3851d9cd251bdb7eccd47385dd37818161bf7
Commit:        19c3851d9cd251bdb7eccd47385dd37818161bf7
Parent:        5bf74f2997cedb481e0fac21e3aa30fc61f8e5b1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 18 23:34:46 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 18 23:34:46 2015 +0000

toollib: Reorder process_each_pv initialisation.

Perform cheaper command line-based validation before more-expensive
processing and scanning.
---
 tools/toollib.c |   32 +++++++++++++++-----------------
 1 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 98e5879..4bd2339 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2786,15 +2786,6 @@ int process_each_pv(struct cmd_context *cmd,
 	dm_list_init(&all_devices);
 
 	/*
-	 * Read all the vgs first because this has the effect of initializing
-	 * other device/lvmcache info that is needed when creating device lists.
-	 */
-	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, only_this_vgname, 1) != ECMD_PROCESSED)) {
-		stack;
-		return ret;
-	}
-
-	/*
 	 * Create two lists from argv:
 	 * arg_pvnames: pvs explicitly named in argv
 	 * arg_tags: tags explicitly named in argv
@@ -2809,14 +2800,8 @@ int process_each_pv(struct cmd_context *cmd,
 
 	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
 
-	process_all_devices = process_all_pvs &&
-			   (cmd->command->flags & ENABLE_ALL_DEVS) &&
-			   arg_count(cmd, all_ARG);
-
-	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices) != ECMD_PROCESSED)) {
-		/* get_arg_devices reports the error for any PV names not found. */
-		ret_max = ECMD_FAILED;
-	}
+	process_all_devices = process_all_pvs && (cmd->command->flags & ENABLE_ALL_DEVS) &&
+			      arg_count(cmd, all_ARG);
 
 	/*
 	 * If the caller wants to process all devices (not just PVs), then all PVs
@@ -2828,6 +2813,19 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
+	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices) != ECMD_PROCESSED))
+		/* get_arg_devices reports the error for any PV names not found. */
+		ret_max = ECMD_FAILED;
+
+	/*
+	 * Read all the vgs first because this has the effect of initializing
+	 * other device/lvmcache info that is needed when creating device lists.
+	 */
+	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, only_this_vgname, 1) != ECMD_PROCESSED)) {
+		stack;
+		return ret;
+	}
+
 	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
 				  &arg_devices, &arg_tags,
 				  process_all_pvs, process_all_devices,


