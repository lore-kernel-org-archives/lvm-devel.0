From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:53 +0100
Subject: [PATCH 7/9] Add CLVMD_CMD_UNLOCK_FS command
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <dd4c64aae4fa40fac9817738280f0d3178ea1338.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Try to add new UNLOCK_FS command into clvmd.
It's calling lvm_do_unlock_fs() when such command arrives.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvm.h          |    1 +
 daemons/clvmd/clvmd-command.c |    6 ++++++
 daemons/clvmd/clvmd.c         |    3 +++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/clvm.h b/daemons/clvmd/clvm.h
index c9ea10c..b608692 100644
--- a/daemons/clvmd/clvm.h
+++ b/daemons/clvmd/clvm.h
@@ -71,4 +71,5 @@ static const char CLVMD_SOCKNAME[]= DEFAULT_RUN_DIR "/clvmd.sock";
 #define CLVMD_CMD_SET_DEBUG	    42
 #define CLVMD_CMD_VG_BACKUP	    43
 #define CLVMD_CMD_RESTART	    44
+#define CLVMD_CMD_UNLOCK_FS	    45
 #endif
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 915fcc7..115c149 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -147,6 +147,10 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		restart_clvmd();
 		break;
 
+	case CLVMD_CMD_UNLOCK_FS:
+		lvm_do_unlock_fs();
+		break;
+
 	case CLVMD_CMD_GET_CLUSTERNAME:
 		status = clops->get_cluster_name(*buf, buflen);
 		if (!status)
@@ -276,6 +280,7 @@ int do_pre_command(struct local_client *client)
 	case CLVMD_CMD_VG_BACKUP:
 	case CLVMD_CMD_LOCK_QUERY:
 	case CLVMD_CMD_RESTART:
+	case CLVMD_CMD_UNLOCK_FS:
 		break;
 
 	default:
@@ -307,6 +312,7 @@ int do_post_command(struct local_client *client)
 	case CLVMD_CMD_LOCK_VG:
 	case CLVMD_CMD_VG_BACKUP:
 	case CLVMD_CMD_LOCK_QUERY:
+	case CLVMD_CMD_UNLOCK_FS:
 		/* Nothing to do here */
 		break;
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 40d7feb..bd9d69c 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -277,6 +277,9 @@ static const char *decode_cmd(unsigned char cmdl)
 	case CLVMD_CMD_RESTART:
 		command = "RESTART";
 		break;
+	case CLVMD_CMD_UNLOCK_FS:
+		command = "UNLOCK_FS";
+		break;
 	default:
 		command = "unknown";
 		break;
-- 
1.7.3.3


