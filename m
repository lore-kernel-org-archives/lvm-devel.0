From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 20 Aug 2015 17:07:14 +0000 (UTC)
Subject: master - cmirrord: avoid resync buffer overflow in LOG_SPRINT
Message-ID: <20150820170714.ACA1760960@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5476ee865597e7f2fcc189412aaaccdc15cc3db9
Commit:        5476ee865597e7f2fcc189412aaaccdc15cc3db9
Parent:        3c396cf1e1efd179c37ddd71a144deab4b9b806c
Author:        Ferenc W??gner <wferi@niif.hu>
AuthorDate:    Wed Jul 8 14:41:27 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Aug 20 19:06:47 2015 +0200

cmirrord: avoid resync buffer overflow in LOG_SPRINT

Use snprintf() instead of sprintf() to exclude the possibility of
overflowing the resync history buffers.
---
 daemons/cmirrord/functions.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

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


