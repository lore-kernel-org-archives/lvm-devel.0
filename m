From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Feb 2014 08:44:56 +0000 (UTC)
Subject: master - cleanup: keep pv_count unsigned
Message-ID: <20140225084456.A953361268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b566a2152f5b7fcf55f2c148a5fe52d7370666e
Commit:        1b566a2152f5b7fcf55f2c148a5fe52d7370666e
Parent:        e7d189baf741d8f27c66cb53ea15f78dcc29efec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 25 09:43:04 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 25 09:43:04 2014 +0100

cleanup: keep pv_count unsigned

---
 tools/lvcreate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7a734f2..dc473f8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -21,7 +21,7 @@ struct lvcreate_cmdline_params {
 	percent_type_t percent;
 	uint64_t size;
 	char **pvs;
-	int pv_count;
+	uint32_t pv_count;
 };
 
 static int _set_vg_name(struct lvcreate_params *lp, const char *vg_name)
@@ -1181,7 +1181,7 @@ static int _check_raid_parameters(struct volume_group *vg,
 				  struct lvcreate_params *lp,
 				  struct lvcreate_cmdline_params *lcp)
 {
-	int devs = lcp->pv_count ? lcp->pv_count : dm_list_size(&vg->pvs);
+	unsigned devs = lcp->pv_count ? : dm_list_size(&vg->pvs);
 	struct cmd_context *cmd = vg->cmd;
 
 	/*


