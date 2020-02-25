From: David Teigland <teigland@sourceware.org>
Date: Tue, 25 Feb 2020 11:35:05 -0500
Subject: master - writecache: check watermark value
Message-ID: <202002251635.01PGZ5xR022234@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=84eab461c843e2018b6ff73a9af8140e27cde391
Commit:        84eab461c843e2018b6ff73a9af8140e27cde391
Parent:        81d03330670f392cfe938d8bb12df2ed4c30f2d0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 25 10:34:30 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 25 10:34:30 2020 -0600

writecache: check watermark value

---
 tools/lvconvert.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4ebda4c..68bd75c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5395,6 +5395,8 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 	if (!strncmp(key, "high_watermark", strlen("high_watermark"))) {
 		if (sscanf(val, "%llu", (unsigned long long *)&settings->high_watermark) != 1)
 			goto_bad;
+		if (settings->high_watermark > 100)
+			goto_bad;
 		settings->high_watermark_set = 1;
 		return 1;
 	}
@@ -5402,6 +5404,8 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 	if (!strncmp(key, "low_watermark", strlen("low_watermark"))) {
 		if (sscanf(val, "%llu", (unsigned long long *)&settings->low_watermark) != 1)
 			goto_bad;
+		if (settings->low_watermark > 100)
+			goto_bad;
 		settings->low_watermark_set = 1;
 		return 1;
 	}



