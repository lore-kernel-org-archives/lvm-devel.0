From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Feb 2020 11:33:57 -0500
Subject: master - writecache: skip zeroing in test mode
Message-ID: <45515.120020711335200575@us-mta-364.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f794f2095583d41393ee9c697f470015b29f064
Commit:        8f794f2095583d41393ee9c697f470015b29f064
Parent:        744b75f88158156f7d8ffe6c2bc5af9856e63258
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 7 10:32:10 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 7 10:32:10 2020 -0600

writecache: skip zeroing in test mode

---
 tools/lvconvert.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a1fb8c1..cd9a3e8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5351,6 +5351,9 @@ static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 	};
 	int ret;
 
+	if (test_mode())
+		return 1;
+
 	if (!activate_lv(cmd, lv)) {
 		log_error("Failed to activate LV %s for zeroing.", display_lvname(lv));
 		return 0;



