From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  8 May 2013 17:45:34 -0500
Subject: [PATCH 12/19] lib2app: Fix warnings in lvm_list_pvs_free
In-Reply-To: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
References: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
Message-ID: <1368053141-13836-13-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_pv.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 38b0126..568ab5b 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -116,9 +116,7 @@ int lvm_list_pvs_free(struct dm_list *pvlist)
 	int rc = 0;
 	struct lvm_list_wrapper *to_delete = NULL;
 	struct vg_list *vgl = NULL;
-	struct vg_list *tmp_vgl = NULL;
 	struct pv_list *pvl = NULL;
-	struct pv_list *tmp_pvl = NULL;
 	struct cmd_context *cmd = NULL;
 
 	if (pvlist ) {
-- 
1.8.1.4


