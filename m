From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 20 Aug 2015 17:07:12 +0000 (UTC)
Subject: master - cmirrord: avoid debugging buffer overflow in LOG_SPRINT
Message-ID: <20150820170712.8A52360960@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c396cf1e1efd179c37ddd71a144deab4b9b806c
Commit:        3c396cf1e1efd179c37ddd71a144deab4b9b806c
Parent:        1ea1cb6dc972868d89ff17cb03f65ce3088009b3
Author:        Ferenc W??gner <wferi@niif.hu>
AuthorDate:    Wed Jul 8 14:41:26 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Aug 20 19:06:47 2015 +0200

cmirrord: avoid debugging buffer overflow in LOG_SPRINT

Use snprintf() instead of sprintf() to exclude the possibility of
overflowing the debugging history buffers.
---
 daemons/cmirrord/cluster.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

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


