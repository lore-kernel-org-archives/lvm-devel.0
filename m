From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  8 Jan 2014 02:18:13 +0000 (UTC)
Subject: master - lvmetad: free fid after vg lookup failure
Message-ID: <20140108021813.EAE6760275@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21c3b41ea893fe64e7ca5245411899ace4ae2a81
Commit:        21c3b41ea893fe64e7ca5245411899ace4ae2a81
Parent:        3a4efb2f1620b5875395966b66510392d1ebe60a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 8 01:51:23 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 8 01:51:23 2014 +0000

lvmetad: free fid after vg lookup failure

---
 lib/cache/lvmetad.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 65ed520..85bbf88 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -240,8 +240,9 @@ static int _read_mda(struct lvmcache_info *info,
 	return 0;
 }
 
-static struct lvmcache_info *_pv_populate_lvmcache(
-	struct cmd_context *cmd, struct dm_config_node *cn, dev_t fallback)
+static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
+						   struct dm_config_node *cn,
+						   dev_t fallback)
 {
 	struct device *dev;
 	struct id pvid, vgid;
@@ -342,7 +343,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	daemon_reply reply;
 	int found;
 	char uuid[64];
-	struct format_instance *fid;
+	struct format_instance *fid = NULL;
 	struct format_instance_ctx fic;
 	struct dm_config_node *top;
 	const char *name, *diag_name;
@@ -424,6 +425,8 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	}
 
 out:
+	if (!vg && fid)
+		fid->fmt->ops->destroy_instance(fid);
 	daemon_reply_destroy(reply);
 
 	return vg;


