From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:30:51 +0100
Subject: [PATCH 05/16] Remove fs_unlock after failed suspend
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <bd68b2a9fbc0e2e473641a088b75d68edfa4de33.1297419991.git.zkabelac@redhat.com>
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
index ad9459a..e75415b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1126,7 +1126,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 
 	if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
 		critical_section_dec(cmd);
-		fs_unlock();
 		goto out;
 	}
 
-- 
1.7.4


