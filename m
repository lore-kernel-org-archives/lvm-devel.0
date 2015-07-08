From: Ferenc Wágner <wferi@niif.hu>
Date: Wed,  8 Jul 2015 14:41:27 +0200
Subject: [PATCH 6/6] cmirrord: avoid resync buffer overflow in LOG_SPRINT
In-Reply-To: <1436359287-6682-1-git-send-email-wferi@niif.hu>
References: <1436359287-6682-1-git-send-email-wferi@niif.hu>
Message-ID: <1436359287-6682-7-git-send-email-wferi@niif.hu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use snprintf() instead of sprintf() to exclude the possibility of
overflowing the resync history buffers.
---
 daemons/cmirrord/functions.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index f6e0918..61b3e11 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -32,12 +32,13 @@
 #define LOG_OFFSET 2
 
 #define RESYNC_HISTORY 50
+#define RESYNC_BUFLEN 128
 //static char resync_history[RESYNC_HISTORY][128];
 //static int idx = 0;
 #define LOG_SPRINT(_lc, f, arg...) do {					\
 		lc->idx++;						\
 		lc->idx = lc->idx % RESYNC_HISTORY;			\
-		sprintf(lc->resync_history[lc->idx], f, ## arg);	\
+		snprintf(lc->resync_history[lc->idx], RESYNC_BUFLEN, f, ## arg); \
 	} while (0)
 
 struct log_header {
@@ -88,7 +89,7 @@ struct log_c {
 	size_t disk_size;       /* size of disk_buffer in bytes */
 	void *disk_buffer;      /* aligned memory for O_DIRECT */
 	int idx;
-	char resync_history[RESYNC_HISTORY][128];
+	char resync_history[RESYNC_HISTORY][RESYNC_BUFLEN];
 };
 
 struct mark_entry {
-- 
1.7.10.4


