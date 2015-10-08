From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  8 Oct 2015 15:17:57 +0000 (UTC)
Subject: master - vgcreate: allow both --shared and --lock-type options
Message-ID: <20151008151757.3F86F602F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09981afc1c03e1d79109c483b3d19ae1c207e158
Commit:        09981afc1c03e1d79109c483b3d19ae1c207e158
Parent:        3d03e504cda6307f692c5879f6850b2e27af7d71
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 8 10:14:33 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 8 10:14:33 2015 -0500

vgcreate: allow both --shared and --lock-type options

Using --lock-type sanlock|dlm implies --shared.

Using --shared selects lock type sanlock|dlm
(by choosing the one that's running.)

Using both --shared and --lock-type sanlock|dlm should
also be allowed (--shared is just redundant information.)
---
 tools/toollib.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 01146a4..cf5e236 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -898,12 +898,18 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	use_clvmd = (locking_type == 3);
 
 	if (arg_is_set(cmd, locktype_ARG)) {
-		if (arg_is_set(cmd, clustered_ARG) || arg_is_set(cmd, shared_ARG)) {
-			log_error("A lock type cannot be specified with --shared or --clustered.");
+		if (arg_is_set(cmd, clustered_ARG)) {
+			log_error("A lock type cannot be specified with --clustered.");
 			return 0;
 		}
+
 		lock_type = arg_str_value(cmd, locktype_ARG, "");
 
+		if (arg_is_set(cmd, shared_ARG) && !is_lockd_type(lock_type)) {
+			log_error("The --shared option requires lock type sanlock or dlm.");
+			return 0;
+		}
+
 	} else if (arg_is_set(cmd, clustered_ARG)) {
 		const char *arg_str = arg_str_value(cmd, clustered_ARG, "");
 		int clustery = strcmp(arg_str, "y") ? 0 : 1;


