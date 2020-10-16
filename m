From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:30 +0000 (GMT)
Subject: stable-2.02 - vgrename: fix error value when name exists
Message-ID: <20201016191130.62CD3396EC6A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=667cfeeacfae7941b662bffede86e38d425575c5
Commit:        667cfeeacfae7941b662bffede86e38d425575c5
Parent:        d1f7c531eb20e580d02fc0950d12df34cb2fc51b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 21 09:33:56 2020 -0500
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

vgrename: fix error value when name exists

---
 tools/vgrename.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/vgrename.c b/tools/vgrename.c
index f13289e53..d2dee3ddf 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -194,7 +194,7 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 	vg_name_new = skip_dev_dir(cmd, argv[1], NULL);
 
 	if (!validate_vg_rename_params(cmd, vg_name_old, vg_name_new))
-		return_0;
+		return_ECMD_FAILED;
 
 	if (!(vp.vg_name_old = dm_pool_strdup(cmd->mem, vg_name_old)))
 		return_ECMD_FAILED;


