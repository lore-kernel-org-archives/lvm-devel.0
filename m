From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Jan 2022 14:10:30 +0000 (GMT)
Subject: main - lvcreate: fix crash for unspecified LV name for writecache
Message-ID: <20220126141030.3908238515D9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a06ccdf44bd385863792baed887303c714da9685
Commit:        a06ccdf44bd385863792baed887303c714da9685
Parent:        c6639056e0bb2fc5f072b2c0d6bb629ad17eee6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 20 16:01:17 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 26 15:09:58 2022 +0100

lvcreate: fix crash for unspecified LV name for writecache

Fix aplication crash when creating writecached LV with 'automatic' name.
---
 tools/lvcreate.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 79af42685..0115b3c32 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1691,6 +1691,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	struct lvcreate_params *lp = pp->lp;
 	struct lvcreate_cmdline_params *lcp = pp->lcp;
 	struct logical_volume *spare = vg->pool_metadata_spare_lv;
+	struct logical_volume *lv;
 	int ret = ECMD_FAILED;
 
 	if (!_read_activation_params(cmd, vg, lp))
@@ -1759,9 +1760,12 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 		lp->needs_lockd_init = 1;
 	}
 
-	if (!lv_create_single(vg, lp))
+	if (!(lv = lv_create_single(vg, lp)))
 		goto_out;
 
+	if (!lp->lv_name)
+		lp->lv_name = lv->name; /* Get created LV name when it was not specified */
+
 	ret = ECMD_PROCESSED;
 out:
 	if (ret != ECMD_PROCESSED && !spare && vg->pool_metadata_spare_lv)


