From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:27:20 +0200
Subject: [PATCH 01/23] Return ECMD_FAILED for break
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <1c89a9d6ba2bfb863fb66b02743ccd9fa00f97e5.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Return ECMD_FAILED when sigint has been caught.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 393c529..eac63e0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -330,7 +330,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
-			break;
+			return ECMD_FAILED;
 	}
 
 	return ret_max;
-- 
1.7.0.1


