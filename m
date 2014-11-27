From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 27 Nov 2014 19:32:16 +0000 (UTC)
Subject: master - lvcreate: Implement --cachepolicy/--cachesettings.
Message-ID: <20141127193216.A34B360BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b2726fc6142c734e06fa8b49ad856b2e47da9fc
Commit:        5b2726fc6142c734e06fa8b49ad856b2e47da9fc
Parent:        2c3db52356eebd7ad7e950a01f465359c040b379
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 27 20:21:41 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 27 20:22:03 2014 +0100

lvcreate: Implement --cachepolicy/--cachesettings.

---
 test/shell/lvcreate-cache.sh |   14 ++++++++++++++
 tools/commands.h             |    3 ++-
 tools/lvcreate.c             |   19 ++++++++++++++++++-
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index eeba827..f709d8b 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -226,6 +226,20 @@ fail lvcreate -H -L10 --chunksize 16M $vg/cpool4
 
 lvremove -f $vg
 
+lvcreate --type cache-pool -L10 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachepolicy mq --cachesettings migration_threshold=233
+dmsetup status | grep $vg
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
+
+lvremove -f $vg
+
+lvcreate --type cache-pool -L10 --cachepolicy mq --cachesettings migration_threshold=233 $vg/cpool
+lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg
+dmsetup status | grep $vg
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
+
+lvremove -f $vg
+
 
 ##############################
 # Test things that should fail
diff --git a/tools/commands.h b/tools/commands.h
index 852b675..8dc335c 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -308,6 +308,7 @@ xx(lvcreate,
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
+   "\t[--cachepolicy Policy] [--cachesettings Key=Value]\n"
    "\t[-c|--chunksize]\n"
    "\t[-C|--contiguous {y|n}]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -337,7 +338,7 @@ xx(lvcreate,
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
-   cache_ARG, cachemode_ARG, cachepool_ARG,
+   cache_ARG, cachemode_ARG, cachepool_ARG, cachepolicy_ARG, cachesettings_ARG,
    chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG,
    extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
    metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index b0186d3..7236ffc 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -698,7 +698,9 @@ static int _lvcreate_params(struct cmd_context *cmd,
 
 #define CACHE_POOL_ARGS \
 	cachemode_ARG,\
-	cachepool_ARG
+	cachepool_ARG,\
+	cachepolicy_ARG,\
+	cachesettings_ARG
 
 #define MIRROR_ARGS \
 	corelog_ARG,\
@@ -1010,6 +1012,13 @@ static int _lvcreate_params(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if ((arg_count(cmd, cachepolicy_ARG) || arg_count(cmd, cachesettings_ARG)) &&
+	    !(lp->cache_policy = get_cachepolicy_params(cmd)))
+	{
+		log_error("Failed to parse cache policy and/or settings.");
+		return 0;
+	}
+
 	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(current_group->arg_values, addtag_ARG))
 			continue;
@@ -1404,6 +1413,13 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 	return r;
 }
 
+static void _destroy_lvcreate_params(struct lvcreate_params *lp)
+{
+	if (lp->cache_policy)
+		dm_config_destroy(lp->cache_policy);
+	lp->cache_policy = NULL;
+}
+
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int r = ECMD_FAILED;
@@ -1482,6 +1498,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	r = ECMD_PROCESSED;
 out:
+	_destroy_lvcreate_params(&lp);
 	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }


