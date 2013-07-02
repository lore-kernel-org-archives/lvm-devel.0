From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:21 +0000 (UTC)
Subject: master - lib2app: Fix warnings in lvm_list_pvs_free
Message-ID: <20130702192621.85C4960CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d079411051e8151b61c7614e791215db065c01cb
Commit:        d079411051e8151b61c7614e791215db065c01cb
Parent:        8ddb1b4abfeeb39044cd26199ff8d966870c2354
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Apr 3 17:07:08 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

lib2app: Fix warnings in lvm_list_pvs_free

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_pv.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 8f53352..bced4f9 100644
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


