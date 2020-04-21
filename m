From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Apr 2020 14:35:03 +0000 (GMT)
Subject: master - vgrename: fix error value when name exists
Message-ID: <20200421143503.6E77C386F812@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2aa36209eb0087228391b9b01b6f03a6875bad9f
Commit:        2aa36209eb0087228391b9b01b6f03a6875bad9f
Parent:        211eaa284c4df992916e0a523d0ff932aa790a98
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 21 09:33:56 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 21 09:33:56 2020 -0500

vgrename: fix error value when name exists

---
 tools/vgrename.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/vgrename.c b/tools/vgrename.c
index 8b76d0b84..f442f731f 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -183,7 +183,7 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 	vg_name_new = skip_dev_dir(cmd, argv[1], NULL);
 
 	if (!validate_vg_rename_params(cmd, vg_name_old, vg_name_new))
-		return_0;
+		return_ECMD_FAILED;
 
 	if (!(vp.vg_name_old = dm_pool_strdup(cmd->mem, vg_name_old)))
 		return_ECMD_FAILED;



