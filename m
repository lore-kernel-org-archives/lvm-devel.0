From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:38 +0100
Subject: [PATCH 15/24] Remove fs_unlock after failed suspend
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <bafe960aae1f584af4659779dd75c1cac9adce74.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Explicit fs_unlock() after failed suspend is not need -
as it will happen automatically with nearest lv_info()
or vg_unlock().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4e862f5..b320021 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1057,7 +1057,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
 		critical_section_dec(cmd);
-		fs_unlock();
 		goto out;
 	}
 
-- 
1.7.3.5


