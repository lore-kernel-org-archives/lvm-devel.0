From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  8 May 2013 17:45:33 -0500
Subject: [PATCH 11/19] _get_pvs: Remove unused variable
In-Reply-To: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
References: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
Message-ID: <1368053141-13836-12-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index cecf81c..92d0ffa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3671,7 +3671,6 @@ static int _get_pvs(struct cmd_context *cmd, int warnings,
 		struct dm_list *pvslist, struct dm_list *vgslist)
 {
 	struct str_list *strl;
-	struct dm_list * uninitialized_var(results);
 	const char *vgname, *vgid;
 	struct pv_list *pvl, *pvl_copy;
 	struct dm_list *vgids;
-- 
1.8.1.4


