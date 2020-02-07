From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Feb 2020 11:33:59 -0500
Subject: master - writecache: check for invalid cachevol
Message-ID: <06062.120020711334900909@us-mta-177.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=744b75f88158156f7d8ffe6c2bc5af9856e63258
Commit:        744b75f88158156f7d8ffe6c2bc5af9856e63258
Parent:        b756cb3e49b762b3a5160f9748aeb5bf995ae80e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 7 10:26:59 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 7 10:26:59 2020 -0600

writecache: check for invalid cachevol

---
 tools/lvconvert.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a83b019..a1fb8c1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5578,6 +5578,11 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		goto bad;
 	}
 
+	if (lv_fast == lv) {
+		log_error("Invalid cachevol LV.");
+		goto bad;
+	}
+
 	if (!seg_is_linear(first_seg(lv_fast))) {
 		log_error("LV %s must be linear to use as a writecache.", display_lvname(lv_fast));
 		goto bad;



