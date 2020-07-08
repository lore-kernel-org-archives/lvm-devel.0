From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Jul 2020 09:45:27 +0000 (GMT)
Subject: master - debug: missing stacktrace
Message-ID: <20200708094527.670DA3861019@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0faad0db38fe733cae42d7df136d7ed4f7bcba6
Commit:        d0faad0db38fe733cae42d7df136d7ed4f7bcba6
Parent:        9b9bf8786fb423a4430cc676301edadf2310098d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 11:06:39 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 8 11:40:55 2020 +0200

debug: missing stacktrace

---
 tools/lvconvert.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0dcc77689..2896c67c3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5524,7 +5524,8 @@ static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	ret = wipe_lv(lv, wp);
+	if (!(ret = wipe_lv(lv, wp)))
+		stack;
 
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Failed to deactivate LV %s for zeroing.", display_lvname(lv));


