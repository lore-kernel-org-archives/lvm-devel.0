From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 21:45:51 +0000 (UTC)
Subject: master - pvscan, vgscan: include foreign vgs with --cache
Message-ID: <20150225214551.256726092B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1248f94a429faa245968a9efe04250f27a53bc18
Commit:        1248f94a429faa245968a9efe04250f27a53bc18
Parent:        bbaabb8a59980995dfa94948589034c6a93b9f5a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 15:41:15 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 15:46:27 2015 -0600

pvscan, vgscan: include foreign vgs with --cache

pvscan --cache and vgscan --cache scan devices to refresh lvmetad,
and they should also refresh the lvmetad copy of foreign vgs.
---
 tools/commands.h |    2 +-
 tools/pvscan.c   |    2 ++
 tools/vgscan.c   |    2 ++
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 5cd7c2d..719c507 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -616,7 +616,7 @@ xx(lvs,
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "lvscan\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice]\n"
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 4ab2ff7..a04a4b2 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -189,6 +189,8 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	dev_t devno;
 	activation_handler handler = NULL;
 
+	cmd->include_foreign_vgs = 1;
+
 	/*
 	 * Return here immediately if lvmetad is not used.
 	 * Also return if locking_type=3 (clustered) as we
diff --git a/tools/vgscan.c b/tools/vgscan.c
index b3af9bc..7328a09 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -47,6 +47,8 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 	lvmcache_destroy(cmd, 1, 0);
 
 	if (arg_count(cmd, cache_long_ARG)) {
+		cmd->include_foreign_vgs = 1;
+
 		if (lvmetad_active()) {
 			if (!lvmetad_pvscan_all_devs(cmd, NULL))
 				return ECMD_FAILED;


