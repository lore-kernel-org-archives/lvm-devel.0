From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Sep 2021 13:26:29 +0000 (GMT)
Subject: main - cleanup: free already does NULL check
Message-ID: <20210915132629.DACF83858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed59b50512f966125b972f9d2eafee3058f8063f
Commit:        ed59b50512f966125b972f9d2eafee3058f8063f
Parent:        73087c2c0fd51b1ff543580dadbf3d02dd49a35d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 15 14:08:12 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 15 15:24:56 2021 +0200

cleanup: free already does NULL check

Drop extra check for NULL before calling free().
Also drop zeroing data that will be free().
---
 daemons/lvmlockd/lvmlockd-core.c | 19 +++++--------------
 daemons/lvmlockd/lvmlockd-idm.c  |  8 ++++----
 2 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index e53eebfe7..35c9b6c25 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -438,18 +438,11 @@ static void free_pvs_path(struct pvs *pvs)
 {
 	int i;
 
-	for (i = 0; i < pvs->num; i++) {
-		if (!pvs->path[i])
-			continue;
-
+	for (i = 0; i < pvs->num; i++)
 		free((char *)pvs->path[i]);
-		pvs->path[i] = NULL;
-	}
 
-	if (!pvs->path) {
-		free(pvs->path);
-		pvs->path = NULL;
-	}
+	free(pvs->path);
+	pvs->path = NULL;
 }
 
 static char **alloc_and_copy_pvs_path(struct pvs *dst, struct pvs *src)
@@ -563,10 +556,8 @@ static struct lock *alloc_lock(void)
 
 static void free_action(struct action *act)
 {
-	if (act->path) {
-		free(act->path);
-		act->path = NULL;
-	}
+	free(act->path);
+	act->path = NULL;
 
 	free_pvs_path(&act->pvs);
 
diff --git a/daemons/lvmlockd/lvmlockd-idm.c b/daemons/lvmlockd/lvmlockd-idm.c
index e9f50535c..e13fb62ae 100644
--- a/daemons/lvmlockd/lvmlockd-idm.c
+++ b/daemons/lvmlockd/lvmlockd-idm.c
@@ -456,8 +456,9 @@ int lm_add_lockspace_idm(struct lockspace *ls, int adopt)
 fail:
 	if (lmi && lmi->sock)
 		close(lmi->sock);
-	if (lmi)
-		free(lmi);
+
+	free(lmi);
+
 	return rv;
 }
 
@@ -506,8 +507,7 @@ int lm_rem_resource_idm(struct lockspace *ls, struct resource *r)
 {
 	struct rd_idm *rdi = (struct rd_idm *)r->lm_data;
 
-	if (rdi->vb)
-		free(rdi->vb);
+	free(rdi->vb);
 
 	memset(rdi, 0, sizeof(struct rd_idm));
 	r->lm_init = 0;


