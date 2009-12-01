From: Milan Broz <mbroz@redhat.com>
Date: Tue,  1 Dec 2009 20:04:21 +0100
Subject: [PATCH] Fix memory leak in lv_info_by_lvid
Message-ID: <1259694261-18466-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The lv_from_lvid calls internally vg_read(),
we myst relelase vg structure afterwards.

Code is called only from clvmd.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b3a70db..1aaa16c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -486,12 +486,16 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvi
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
+	int r;
 	struct logical_volume *lv;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	return _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
+	r = _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
+	vg_release(lv->vg);
+
+	return r;
 }
 
 /*
-- 
1.6.5.3


