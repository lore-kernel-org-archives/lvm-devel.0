From: Milan Broz <mbroz@redhat.com>
Date: Sat, 23 Jan 2010 21:58:44 +0100
Subject: [PATCH 2/6] Always query device by using uuid only and not name.
In-Reply-To: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
References: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
Message-ID: <1264280328-8728-2-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Otherwise confusion with the device of the same name
(but different UUID, e.g. non-lvm device) can happen.
---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index f18ecf9..433c8cc 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -492,7 +492,7 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	r = _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
+	r = _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 1);
 	vg_release(lv->vg);
 
 	return r;
-- 
1.6.6


