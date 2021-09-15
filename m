From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Sep 2021 13:26:25 +0000 (GMT)
Subject: main - clang: avoid double free on error path
Message-ID: <20210915132625.5A12C3858413@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c5d2874a73d884ede9bb3f0583b238f8764ab92
Commit:        9c5d2874a73d884ede9bb3f0583b238f8764ab92
Parent:        8935dfee56fe2cfb29152f0af2a4c4c32e62895b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 14 18:00:22 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 15 15:24:56 2021 +0200

clang: avoid double free on error path

Error path in _lockd_retrive_vg_pv_list() has not zeroed released path
caussing possible double-free later in the code.

Fix it by using one single function freeing lock_pvs structure.
---
 lib/locking/lvmlockd.c | 47 +++++++++++++++--------------------------------
 1 file changed, 15 insertions(+), 32 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 766be71ba..6eb71d08d 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -232,6 +232,18 @@ static int _lockd_retrive_vg_pv_num(struct volume_group *vg)
 	return num;
 }
 
+static void _lockd_free_pv_list(struct lvmlockd_pvs *lock_pvs)
+{
+	int i;
+
+	for (i = 0; i < lock_pvs->num; i++)
+		free(lock_pvs->path[i]);
+
+	free(lock_pvs->path);
+	lock_pvs->path = NULL;
+	lock_pvs->num = 0;
+}
+
 static void _lockd_retrive_vg_pv_list(struct volume_group *vg,
 				      struct lvmlockd_pvs *lock_pvs)
 {
@@ -269,13 +281,7 @@ static void _lockd_retrive_vg_pv_list(struct volume_group *vg,
 	return;
 
 fail:
-	for (i = 0; i < pv_num; i++) {
-		if (!lock_pvs->path[i])
-			continue;
-		free(lock_pvs->path[i]);
-	}
-	free(lock_pvs->path);
-	return;
+	_lockd_free_pv_list(lock_pvs);
 }
 
 static int _lockd_retrive_lv_pv_num(struct volume_group *vg,
@@ -327,7 +333,7 @@ static void _lockd_retrive_lv_pv_list(struct volume_group *vg,
 	}
 
 	/* Allocate buffer for PV list */
-	lock_pvs->path = malloc(sizeof(*lock_pvs->path) * pv_num);
+	lock_pvs->path = zalloc(sizeof(*lock_pvs->path) * pv_num);
 	if (!lock_pvs->path) {
 		log_error("Fail to allocate PV list for %s/%s", vg->name, lv_name);
 		return;
@@ -352,30 +358,7 @@ static void _lockd_retrive_lv_pv_list(struct volume_group *vg,
 	return;
 
 fail:
-	for (i = 0; i < pv_num; i++) {
-		if (!lock_pvs->path[i])
-			continue;
-		free(lock_pvs->path[i]);
-		lock_pvs->path[i] = NULL;
-	}
-	free(lock_pvs->path);
-	lock_pvs->path = NULL;
-	lock_pvs->num = 0;
-	return;
-}
-
-static void _lockd_free_pv_list(struct lvmlockd_pvs *lock_pvs)
-{
-	int i;
-
-	for (i = 0; i < lock_pvs->num; i++) {
-		free(lock_pvs->path[i]);
-		lock_pvs->path[i] = NULL;
-	}
-
-	free(lock_pvs->path);
-	lock_pvs->path = NULL;
-	lock_pvs->num = 0;
+	_lockd_free_pv_list(lock_pvs);
 }
 
 /*


