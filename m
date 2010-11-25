From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:10 +0100
Subject: [PATCH 06/29] Replace snprintf -> dm_snprintf
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <ad12e2d21c4356d9d34fc8d1f752ec1d6d39dce3.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use dm_snprintf with known error case behavior - return -1.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 8d1dcff..915fcc7 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -97,10 +97,10 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		}
 		if (*buf) {
 			uname(&nodeinfo);
-			*retlen = 1 + snprintf(*buf, buflen,
-					       "TEST from %s: %s v%s",
-					       nodeinfo.nodename, args,
-					       nodeinfo.release);
+			*retlen = 1 + dm_snprintf(*buf, buflen,
+						  "TEST from %s: %s v%s",
+						  nodeinfo.nodename, args,
+						  nodeinfo.release);
 		}
 		break;
 
@@ -121,9 +121,8 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		status = do_lock_lv(lock_cmd, lock_flags, lockname);
 		/* Replace EIO with something less scary */
 		if (status == EIO) {
-			*retlen =
-			    1 + snprintf(*buf, buflen, "%s",
-					 get_last_lvm_error());
+			*retlen = 1 + dm_snprintf(*buf, buflen, "%s",
+						  get_last_lvm_error());
 			return EIO;
 		}
 		break;
@@ -133,7 +132,7 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		if (buflen < 3)
 			return EIO;
 		if ((locktype = do_lock_query(lockname)))
-			*retlen = 1 + snprintf(*buf, buflen, "%s", locktype);
+			*retlen = 1 + dm_snprintf(*buf, buflen, "%s", locktype);
 		break;
 
 	case CLVMD_CMD_REFRESH:
@@ -169,8 +168,8 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 
 	/* Check the status of the command and return the error text */
 	if (status) {
-		*retlen = 1 + (*buf) ? snprintf(*buf, buflen, "%s",
-						strerror(status)) : -1;
+		*retlen = 1 + (*buf) ? dm_snprintf(*buf, buflen, "%s",
+						   strerror(status)) : -1;
 	}
 
 	return status;
@@ -377,7 +376,7 @@ static int restart_clvmd(void)
 	/* Propogate debug options */
 	if (debug) {
 		if (!(debug_arg = malloc(16)) ||
-		    snprintf(debug_arg, 16, "-d%d", (int)debug) < 0)
+		    dm_snprintf(debug_arg, 16, "-d%d", (int)debug) < 0)
 			goto_out;
 		argv[argc++] = debug_arg;
 	}
-- 
1.7.3.2


