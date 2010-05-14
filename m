From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 17:18:56 +0200
Subject: [PATCH 01/23] Return ECMD_FAILED for break Return ECMD_FAILED when sigint has been caught.
In-Reply-To: <cover.1273849980.git.zkabelac@redhat.com>
References: <cover.1273849980.git.zkabelac@redhat.com>
Message-ID: <06e52952e33528384e68c3b19db84df62e3777a5.1273849980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 735f3b0..39d86d8 100644
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
@@ -409,7 +409,7 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
-			break;
+			return ECMD_FAILED;
 	}
 
 	return ret_max;
-- 
1.7.0.1


