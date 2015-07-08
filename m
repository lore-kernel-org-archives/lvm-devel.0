From: Ferenc Wágner <wferi@niif.hu>
Date: Wed,  8 Jul 2015 14:41:26 +0200
Subject: [PATCH 5/6] cmirrord: avoid debugging buffer overflow in LOG_SPRINT
In-Reply-To: <1436359287-6682-1-git-send-email-wferi@niif.hu>
References: <1436359287-6682-1-git-send-email-wferi@niif.hu>
Message-ID: <1436359287-6682-6-git-send-email-wferi@niif.hu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use snprintf() instead of sprintf() to exclude the possibility of
overflowing the debugging history buffers.
---
 daemons/cmirrord/cluster.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 4a4bdab..2850d9b 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -104,10 +104,11 @@ static SaVersionT version = { 'B', 1, 1 };
 #endif
 
 #define DEBUGGING_HISTORY 100
+#define DEBUGGING_BUFLEN 128
 #define LOG_SPRINT(cc, f, arg...) do {				\
 		cc->idx++;					\
 		cc->idx = cc->idx % DEBUGGING_HISTORY;		\
-		sprintf(cc->debugging[cc->idx], f, ## arg);	\
+		snprintf(cc->debugging[cc->idx], DEBUGGING_BUFLEN, f, ## arg); \
 	} while (0)
 
 static int log_resp_rec = 0;
@@ -150,7 +151,7 @@ struct clog_cpg {
 	uint32_t checkpoint_requesters[MAX_CHECKPOINT_REQUESTERS];
 	struct checkpoint_data *checkpoint_list;
 	int idx;
-	char debugging[DEBUGGING_HISTORY][128];
+	char debugging[DEBUGGING_HISTORY][DEBUGGING_BUFLEN];
 };
 
 static struct dm_list clog_cpg_list;
-- 
1.7.10.4


