From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:29:34 +0200
Subject: [PATCH 4/6] Do not show backtrace
In-Reply-To: <cover.1278505444.git.zkabelac@redhat.com>
References: <cover.1278505444.git.zkabelac@redhat.com>
Message-ID: <586511efb594eefc986c474da62905754d3d34ca.1278505444.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When we expect this state and behavior is correct.

FIXME: Add resonable error message instead of 'goto_out'

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2128c41..7edd728 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -961,8 +961,10 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		goto_out;
 
 	if (!info.exists || !info.suspended) {
-		r = error_if_not_active ? 0 : 1;
-		goto_out;
+		if (error_if_not_active)
+			goto_out;
+		r = 1;
+		goto out;
 	}
 
 	if (!_lv_activate_lv(lv))
-- 
1.7.1.1


