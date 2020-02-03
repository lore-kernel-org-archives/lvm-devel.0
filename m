From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Feb 2020 12:34:17 -0500
Subject: master - writecache: reject invalid high/low watermark setting
Message-ID: <31633.120020312341201643@us-mta-19.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=adbb0a8d5bd0f735a756e32effcf0bddac0f6de7
Commit:        adbb0a8d5bd0f735a756e32effcf0bddac0f6de7
Parent:        64a82a1c79a4aaef5359150f960932aee4df1982
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 3 11:33:30 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 3 11:33:30 2020 -0600

writecache: reject invalid high/low watermark setting

---
 tools/lvconvert.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d0d277b..f6a329b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5504,6 +5504,12 @@ static int _get_writecache_settings(struct cmd_context *cmd, struct writecache_s
 		}
 	}
 
+	if (settings->high_watermark_set && settings->low_watermark_set &&
+	    (settings->high_watermark <= settings->low_watermark)) {
+		log_error("High watermark must be greater than or equal to low watermark.");
+		return 0;
+	}
+
 	return 1;
 }
 



