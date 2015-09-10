From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Sep 2015 14:14:02 +0000 (UTC)
Subject: master - dev-cache: ignore persistent cache if configuration changed
Message-ID: <20150910141402.1C6BD609E7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2296999cf6922b2be0c6dc38abae0c6766996060
Commit:        2296999cf6922b2be0c6dc38abae0c6766996060
Parent:        d323acdfec8aaab1161aa5f80ae67622e396a632
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 10 16:00:14 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 10 16:13:39 2015 +0200

dev-cache: ignore persistent cache if configuration changed

Commit f6473baffc2d0b486b2aa941cf2681683026b3a5 introduced a new
cmd->initialized variable to keep info about which parts of the
cmd_context have been initialized.

A part of this patch was also a change in refresh_filters fn
which checks for cmd->initialized.filters variable and it does
the filter refresh *only* if the filter has already been initialized
before otherwise it's a NOOP (before, the refresh_filters also
initialized filters as a side effect in case it had not been
initialized before which was not quite correct).

However, the commit f6473baffc2d0b486b2aa941cf2681683026b3a5
did not handle the case in which configuration changes
either via --config argument or when configuration file changed
and its timestamp was higher than the timestamp of the persistent
cache file - the /etc/lvm/cache/.cache.

This patch fixes this issue and it causes the init_filters fn
in lvm_run_command fn to be called with proper value of
"load_persistent_cache" switch even if the configuration changes,
hence causing the persistent cache file to be ignored in this
case.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 43fbb56..184eb19 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Ignore persistent cache if configuration changed. (2.02.127)
   Fix devices/filter to be applied before disk-accessing filters. (2.02.112)
   Make tags only when requested via 'make tags'.
   Configure supports --disable-dependency-tracking for one-time builds.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b7809c7..d3bace7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1478,6 +1478,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	char *arg_new, *arg;
 	int i;
 	int skip_hyphens;
+	int refresh_done = 0;
 
 	init_error_message_produced(0);
 
@@ -1554,6 +1555,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			log_error("Updated config file invalid. Aborting.");
 			return ECMD_FAILED;
 		}
+		refresh_done = 1;
 	}
 
 	if (!_prepare_profiles(cmd))
@@ -1562,7 +1564,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (!cmd->initialized.connections && !_cmd_no_meta_proc(cmd) && !init_connections(cmd))
 		return_ECMD_FAILED;
 
-	if (!cmd->initialized.filters && !_cmd_no_meta_proc(cmd) && !init_filters(cmd, 1))
+	/* Note: Load persistent cache only if we haven't refreshed toolcontext!
+	 *       If toolcontext has been refreshed, it means config has changed
+	 *       and we can't rely on persistent cache anymore.
+	 */
+	if (!cmd->initialized.filters && !_cmd_no_meta_proc(cmd) && !init_filters(cmd, !refresh_done))
 		return_ECMD_FAILED;
 
 	if (arg_count(cmd, readonly_ARG))


