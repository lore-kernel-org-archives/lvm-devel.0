From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Jun 2016 19:22:42 +0000 (UTC)
Subject: master - pvscan: do activation when lvmetad is not running
Message-ID: <20160615192242.AB08E605A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15da467b52465076a8d587b94cc638bab8a0a95c
Commit:        15da467b52465076a8d587b94cc638bab8a0a95c
Parent:        ae0a8740c5899520ec4c94fbf080623167d8ecba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 15 14:19:18 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 15 14:19:18 2016 -0500

pvscan: do activation when lvmetad is not running

When pvscan --cache -aay fails to connect to lvmetad it will
simply exit and do nothing.  Change this so that it will
skip the lvmetad cache step and do the activation step from
disk.
---
 tools/pvscan.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 3e9efef..5987e8b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -315,7 +315,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	dm_list_init(&found_vgnames);
 	dm_list_init(&pp.changed_vgnames);
 
-	if (!lvmetad_used()) {
+	if (!lvmetad_used() && !arg_is_set(cmd, activate_ARG)) {
 		log_verbose("Ignoring pvscan --cache command because lvmetad is not in use.");
 		return ret;
 	}
@@ -341,6 +341,13 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (!lvmetad_used() && do_activate) {
+		log_verbose("Activating all VGs without lvmetad running.");
+		all_vgs = 1;
+		devno_args = 0;
+		goto activate;
+	}
+
 	/*
 	 * Scan all devices when no args are given.
 	 */


