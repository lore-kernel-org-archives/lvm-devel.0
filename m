From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:54 +0000 (GMT)
Subject: main - cleanup: all lvmcache_add users pass char with 0
Message-ID: <20211006134754.5A9A6385BF86@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79e65a3596dc4fef1d7ac74fe727e9c24a539afb
Commit:        79e65a3596dc4fef1d7ac74fe727e9c24a539afb
Parent:        5ccb373d869ca23afc10416c2319331eb108e16b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 14:10:39 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:43:31 2021 +0200

cleanup: all lvmcache_add users pass char with 0

No local copy needed, both users submit zero-end string as pv/vgid.
---
 lib/cache/lvmcache.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 7a7634074..e04f00f2d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2166,8 +2166,8 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 				   const char *vgname, const char *vgid_arg, uint32_t vgstatus,
 				   int *is_duplicate)
 {
-	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
-	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	const char *pvid = pvid_arg;
+	const char *vgid = vgid_arg;
 	char pvid_dashed[64] __attribute__((aligned(8)));
 	struct lvmcache_vgsummary vgsummary = { 0 };
 	struct lvmcache_info *info;
@@ -2175,12 +2175,6 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 	struct device_list *devl;
 	int created = 0;
 
-	/* pvid_arg and vgid_arg may not be null terminated */
-	memcpy(pvid, pvid_arg, ID_LEN);
-
-	if (vgid_arg)
-		memcpy(vgid, vgid_arg, ID_LEN);
-
 	if (!id_write_format((const struct id *)&pvid, pvid_dashed, sizeof(pvid_dashed)))
 		stack;
 
@@ -2282,7 +2276,7 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 update_vginfo:
 	vgsummary.vgstatus = vgstatus;
 	vgsummary.vgname = vgname;
-	if (vgid[0])
+	if (vgid && vgid[0])
 		memcpy(vgsummary.vgid, vgid, ID_LEN);
 
 	if (!lvmcache_update_vgname_and_id(cmd, info, &vgsummary)) {


