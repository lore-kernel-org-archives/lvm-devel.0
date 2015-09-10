From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 10 Sep 2015 14:50:26 +0000 (UTC)
Subject: master - lvmlockd: rename ADOPT_CLIENT_ID
Message-ID: <20150910145026.B9F7860EE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15ae237d2c029116395e5436826f896a5a00d6c4
Commit:        15ae237d2c029116395e5436826f896a5a00d6c4
Parent:        36d16fed1fe883cf2c2756212fd0e6b2f1f99e6b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 9 13:25:39 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 10 09:47:26 2015 -0500

lvmlockd: rename ADOPT_CLIENT_ID

to INTERNAL_CLIENT_ID since it will be
used for more than adopting locks.
---
 daemons/lvmlockd/lvmlockd-core.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index af1a3a9..9b79131 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -197,11 +197,11 @@ static pthread_mutex_t client_mutex;
 static pthread_cond_t client_cond;
 static struct list_head client_list;    /* connected clients */
 static struct list_head client_results; /* actions to send back to clients */
-static uint32_t client_ids;             /* 0 and ADOPT_CLIENT_ID are skipped */
+static uint32_t client_ids;             /* 0 and INTERNAL_CLIENT_ID are skipped */
 static int client_stop;                 /* stop the thread */
 static int client_work;                 /* a client on client_list has work to do */
 
-#define ADOPT_CLIENT_ID 0xFFFFFFFF      /* special client_id for adopt actions */
+#define INTERNAL_CLIENT_ID 0xFFFFFFFF   /* special client_id for internal actions */
 static struct list_head adopt_results;  /* special start actions from adopt_locks() */
 
 /*
@@ -5047,7 +5047,7 @@ static void adopt_locks(void)
 		act->flags = (LD_AF_ADOPT | LD_AF_WAIT);
 		act->rt = LD_RT_GL;
 		act->lm_type = LD_LM_DLM;
-		act->client_id = ADOPT_CLIENT_ID;
+		act->client_id = INTERNAL_CLIENT_ID;
 		add_dlm_global_lockspace(act);
 		count_start++;
 	}
@@ -5059,7 +5059,7 @@ static void adopt_locks(void)
 		act->flags = (LD_AF_ADOPT | LD_AF_WAIT);
 		act->rt = LD_RT_VG;
 		act->lm_type = ls->lm_type;
-		act->client_id = ADOPT_CLIENT_ID;
+		act->client_id = INTERNAL_CLIENT_ID;
 		strncpy(act->vg_name, ls->vg_name, MAX_NAME);
 		memcpy(act->vg_uuid, ls->vg_uuid, 64);
 		memcpy(act->vg_args, ls->vg_args, MAX_ARGS);
@@ -5151,7 +5151,7 @@ static void adopt_locks(void)
 			act->rt = LD_RT_LV;
 			act->mode = LD_LK_EX;
 			act->flags = (LD_AF_ADOPT | LD_AF_PERSISTENT);
-			act->client_id = ADOPT_CLIENT_ID;
+			act->client_id = INTERNAL_CLIENT_ID;
 			act->lm_type = ls->lm_type;
 			strncpy(act->vg_name, ls->vg_name, MAX_NAME);
 			strncpy(act->lv_uuid, r->name, MAX_NAME);
@@ -5179,7 +5179,7 @@ static void adopt_locks(void)
 		act->rt = LD_RT_VG;
 		act->mode = LD_LK_SH;
 		act->flags = LD_AF_ADOPT;
-		act->client_id = ADOPT_CLIENT_ID;
+		act->client_id = INTERNAL_CLIENT_ID;
 		act->lm_type = ls->lm_type;
 		strncpy(act->vg_name, ls->vg_name, MAX_NAME);
 
@@ -5205,7 +5205,7 @@ static void adopt_locks(void)
 	act->rt = LD_RT_GL;
 	act->mode = LD_LK_SH;
 	act->flags = LD_AF_ADOPT;
-	act->client_id = ADOPT_CLIENT_ID;
+	act->client_id = INTERNAL_CLIENT_ID;
 	act->lm_type = (gl_use_sanlock ? LD_LM_SANLOCK : LD_LM_DLM);
 
 	log_debug("adopt lock for gl");
@@ -5444,7 +5444,7 @@ static void process_listener(int poll_fd)
 	pthread_mutex_lock(&client_mutex);
 	client_ids++;
 
-	if (client_ids == ADOPT_CLIENT_ID)
+	if (client_ids == INTERNAL_CLIENT_ID)
 		client_ids++;
 	if (!client_ids)
 		client_ids++;


