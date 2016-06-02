From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Jun 2016 11:50:58 +0000 (UTC)
Subject: master - lvmconfig: fix lvmconfig --type diff to display complete diff if config cascade used
Message-ID: <20160602115058.9513C60971@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=687bc5cecfe6293ee5556aa4e448459bb5c167e6
Commit:        687bc5cecfe6293ee5556aa4e448459bb5c167e6
Parent:        fc37ee63c0562d3f42b597d485495ee79a857dc5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 2 13:41:55 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 2 13:49:38 2016 +0200

lvmconfig: fix lvmconfig --type diff to display complete diff if config cascade used

If configuration consists of several sources in config cascade
("config cascade" defined in man lvmconfig(8)), lvmconfig displayed
only difference from defaults of the topmost config in the cascade.
Fix lvmconfig to display complete difference, considering all
the configuration in the cascade.

For example, before this patch:

	(use_lvmetad=0 set in lvm.conf which differs from defaults)
	$ lvmconfig --type diff
	global {
		use_lvmetad=0
	}

	(compact_output=1 set on cmd line)
	$ lvmconfig --type diff --config report/compact_output=1
	report {
		compact_output=1
	}

	(headings=0 set in profile)
	$ lvmconfig --type diff --commandprofile test
	report {
		headings=0
	}

	(difference in topmost configuration source is displayed)
	$ lvmconfig --type diff --commandprofile test --config report/compact_output=1
	report {
		compact_output=1
	}

With this patch applied (the config cascade is merged before looking for
difference from defaults in configuration):

	$ lvmconfig --type diff
	global {
		use_lvmetad=0
	}

	$ lvmconfig --type diff --config report/compact_output=1
	report {
		compact_output=1
	}
	global {
		use_lvmetad=0
	}

	$ lvmconfig --type diff --profile test
	report {
		headings=0
	}
	global {
		use_lvmetad=0
	}

	$ lvmconfig --type diff --profile test --config report/compact_output=1
	report {
		headings=0
		compact_output=1
	}
	global {
		use_lvmetad=0
	}
---
 WHATS_NEW          |    1 +
 tools/dumpconfig.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 74b5bdb..ea36c17 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Fix lvmconfig --type diff to display complete diff if config cascade used.
   Automatically filter out partitioned loop devices with partscan (losetup -P).
   Fix lvm devtypes internal error if -S used with field name from pvs/vgs/lvs.
   When reporting Data%,Snap%,Meta%,Cpy%Sync use single ioctl per LV.
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 81b488e..0880740 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -210,7 +210,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	 * Set the 'cft' to work with based on whether we need the plain
 	 * config tree or merged config tree cascade if --mergedconfig is used.
 	 */
-	if ((arg_count(cmd, mergedconfig_ARG) || !strcmp(type, "full")) && cmd->cft->cascade) {
+	if ((arg_count(cmd, mergedconfig_ARG) || !strcmp(type, "full") || !strcmp(type, "diff")) && cmd->cft->cascade) {
 		if (!_merge_config_cascade(cmd, cmd->cft, &cft)) {
 			log_error("Failed to merge configuration.");
 			r = ECMD_FAILED;


