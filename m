From: David Teigland <teigland@sourceware.org>
Date: Fri, 21 Feb 2020 09:20:57 -0500
Subject: master - writecache: fix watermark error message
Message-ID: <202002211420.01LEKvEl002320@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2284f845b0328df97dfef6200905b3b462cd3cce
Commit:        2284f845b0328df97dfef6200905b3b462cd3cce
Parent:        8153c5f1e61b305661ab92302ebe1077e2d6f483
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 21 08:13:32 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 21 08:13:32 2020 -0600

writecache: fix watermark error message

---
 tools/lvconvert.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0ddeb35..4ebda4c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5515,7 +5515,7 @@ static int _get_writecache_settings(struct cmd_context *cmd, struct writecache_s
 
 	if (settings->high_watermark_set && settings->low_watermark_set &&
 	    (settings->high_watermark <= settings->low_watermark)) {
-		log_error("High watermark must be greater than or equal to low watermark.");
+		log_error("High watermark must be greater than low watermark.");
 		return 0;
 	}
 



