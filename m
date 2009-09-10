From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 10 Sep 2009 16:25:19 +0200
Subject: [PATCH 3/3] cmirror: port to corosync/cpg api
In-Reply-To: <1252592719-7061-1-git-send-email-fdinitto@redhat.com>
References: <1252592719-7061-1-git-send-email-fdinitto@redhat.com>
Message-ID: <b27cf69d9a4671188d4416169711aae8ab16b25b.1252591904.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 0cfe5a9... 27d6262... M	daemons/cmirrord/cluster.c
 daemons/cmirrord/cluster.c |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 0cfe5a9..27d6262 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -21,8 +21,9 @@
 #include <sys/un.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
+#include <corosync/corotypes.h>
+#include <corosync/cpg.h>
 #include <openais/saAis.h>
-#include <openais/cpg.h>
 #include <openais/saCkpt.h>
 
 #include "dm-log-userspace.h"
@@ -932,9 +933,9 @@ static int flush_startup_list(struct clog_cpg *entry)
 	return 0;
 }
 
-static void cpg_message_callback(cpg_handle_t handle, struct cpg_name *gname,
+static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gname,
 				 uint32_t nodeid, uint32_t pid,
-				 void *msg, int msg_len)
+				 void *msg, size_t msg_len)
 {
 	int i;
 	int r = 0;
@@ -1154,9 +1155,9 @@ out:
 }
 
 static void cpg_join_callback(struct clog_cpg *match,
-			      struct cpg_address *joined,
-			      struct cpg_address *member_list,
-			      int member_list_entries)
+			      const struct cpg_address *joined,
+			      const struct cpg_address *member_list,
+			      size_t member_list_entries)
 {
 	int i;
 	int my_pid = getpid();
@@ -1233,9 +1234,9 @@ out:
 }
 
 static void cpg_leave_callback(struct clog_cpg *match,
-			       struct cpg_address *left,
-			       struct cpg_address *member_list,
-			       int member_list_entries)
+			       const struct cpg_address *left,
+			       const struct cpg_address *member_list,
+			       size_t member_list_entries)
 {
 	int i, j, fd;
 	uint32_t lowest = match->lowest_id;
@@ -1366,13 +1367,13 @@ static void cpg_leave_callback(struct clog_cpg *match,
 	}
 }
 
-static void cpg_config_callback(cpg_handle_t handle, struct cpg_name *gname,
-				struct cpg_address *member_list,
-				int member_list_entries,
-				struct cpg_address *left_list,
-				int left_list_entries,
-				struct cpg_address *joined_list,
-				int joined_list_entries)
+static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gname,
+				const struct cpg_address *member_list,
+				size_t member_list_entries,
+				const struct cpg_address *left_list,
+				size_t left_list_entries,
+				const struct cpg_address *joined_list,
+				size_t joined_list_entries)
 {
 	struct clog_cpg *match;
 	int found = 0;
-- 
1.5.4.3


