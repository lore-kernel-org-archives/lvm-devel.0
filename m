From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Jul 2013 08:01:07 +0000 (UTC)
Subject: master - dumpconfig: add --type profilable
Message-ID: <20130709080107.6D83961034@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=953a438e93a1adb0df7c7931cd6271b9d32acd7d
Commit:        953a438e93a1adb0df7c7931cd6271b9d32acd7d
Parent:        f56a1819e90900487d6d58485dd658944922f251
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 9 09:57:46 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 9 10:00:47 2013 +0200

dumpconfig: add --type profilable

The --type profilable shows all config settings that
are customizable by profiles:

  raw/~ $ lvm dumpconfig --type profilable
  allocation {
	  thin_pool_zero=1
	  thin_pool_discards="passdown"
	  thin_pool_chunk_size=64
  }
  activation {
	  thin_pool_autoextend_threshold=100
	  thin_pool_autoextend_percent=20
  }
---
 WHATS_NEW           |    1 +
 lib/config/config.c |    4 ++++
 lib/config/config.h |    3 ++-
 tools/commands.h    |    2 +-
 tools/dumpconfig.c  |    4 ++++
 5 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 68b3b78..b3b846c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add --type profilable to lvm dumpconfig to show profilable config settings.
   Add --mergedconfig to lvm dumpconfig for merged --config/--profile/lvm.conf.
   Relase memory and unblock signals in lock_vol error path.
   Define LVM2_* command errors in lvm2cmd.h and use in dmeventd plugins.
diff --git a/lib/config/config.c b/lib/config/config.c
index 4c1b415..7c4f8ba 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1370,6 +1370,10 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 			if (def->since_version != spec->version)
 				return 1;
 			break;
+		case CFG_DEF_TREE_PROFILABLE:
+			if (!(def->flags & CFG_PROFILABLE))
+				return 1;
+			break;
 		default:
 			if (def->since_version > spec->version)
 				return 1;
diff --git a/lib/config/config.h b/lib/config/config.h
index 94fd1d9..263da4f 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -101,7 +101,8 @@ typedef enum {
 	CFG_DEF_TREE_MISSING,		/* tree of nodes missing in current config using default values */
 	CFG_DEF_TREE_COMPLETE,		/* CURRENT + MISSING, the tree actually used within execution, not implemented yet */
 	CFG_DEF_TREE_DEFAULT,		/* tree of all possible config nodes with default values */
-	CFG_DEF_TREE_NEW		/* tree of all new nodes that appeared in given version */
+	CFG_DEF_TREE_NEW,		/* tree of all new nodes that appeared in given version */
+	CFG_DEF_TREE_PROFILABLE		/* tree of all nodes that are customizable by profiles */
 } cfg_def_tree_t;
 
 /* configuration definition tree specification */
diff --git a/tools/commands.h b/tools/commands.h
index 3f43260..98746b0 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -33,7 +33,7 @@ xx(dumpconfig,
    PERMITTED_READ_ONLY,
    "dumpconfig\n"
    "\t[-f|--file filename] \n"
-   "\t[--type {current|default|missing|new} \n"
+   "\t[--type {current|default|missing|new|profilable} \n"
    "\t[--withcomments] \n"
    "\t[--withversions] \n"
    "\t[--ignoreadvanced] \n"
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 08f996a..da216f5 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -182,6 +182,10 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		tree_spec.type = CFG_DEF_TREE_NEW;
 		/* new type does not require check status */
 	}
+	else if (!strcmp(type, "profilable")) {
+		tree_spec.type = CFG_DEF_TREE_PROFILABLE;
+		/* profilable type does not require check status */
+	}
 	else {
 		log_error("Incorrect type of configuration specified. "
 			  "Expected one of: current, default, missing, new.");


