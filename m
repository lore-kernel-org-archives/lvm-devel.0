From: Jacek Konieczny <jajcus@jajcus.net>
Date: Wed, 12 Dec 2012 12:14:12 +0100
Subject: [PATCH] clvmd: command timeout handling fix
Message-ID: <1355310852-22851-1-git-send-email-jajcus@jajcus.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clvmd would wait for select() to time-out before processing command
time-outs. The select timeout would be set to the cmd_timeout ('-t'
command-line option) value, which is 60 seconds by default.

Normally the select() call is woken up more frequently, so the command
time-outs are never processed. This causes LVM tools wait forever on
cluster locking for operations started during temporary cluster
problems.

Signed-off-by: Jacek Konieczny <jajcus@jajcus.net>
---
 daemons/clvmd/clvmd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index eb0bffd..2b5d753 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -939,8 +939,8 @@ static void main_loop(int local_sock, int cmd_timeout)
 			}
 		}
 
-		/* Select timed out. Check for clients that have been waiting too long for a response */
-		if (select_status == 0) {
+		/* Check for clients that have been waiting too long for a response */
+		if (select_status >= 0) {
 			time_t the_time = time(NULL);
 
 			for (thisfd = &local_client_head; thisfd != NULL;
-- 
1.7.12.4


