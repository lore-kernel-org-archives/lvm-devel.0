From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:45 +0000 (GMT)
Subject: main - lvmlockd: better error path
Message-ID: <20210920132945.1070E3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48163e32f100a9567cb28ab89f70488d0a0abc7f
Commit:        48163e32f100a9567cb28ab89f70488d0a0abc7f
Parent:        a0bbdfba7fa300cec657c8a1bac2af062bea3439
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 18 00:25:33 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 10:49:56 2021 +0200

lvmlockd: better error path

Set ->num to correct num of pointers.
and fixes regression from previous clang fix
9c5d2874a73d884ede9bb3f0583b238f8764ab92.
---
 lib/locking/lvmlockd.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 6eb71d08d..2284d60fe 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -270,18 +270,13 @@ static void _lockd_retrive_vg_pv_list(struct volume_group *vg,
 		lock_pvs->path[i] = strdup(pv_dev_name(pvl->pv));
 		if (!lock_pvs->path[i]) {
 			log_error("Fail to allocate PV path for VG %s", vg->name);
-			goto fail;
+			_lockd_free_pv_list(lock_pvs);
+			return;
 		}
 
 		log_debug("VG %s find PV device %s", vg->name, lock_pvs->path[i]);
-		i++;
+		lock_pvs->num = ++i;
 	}
-
-	lock_pvs->num = pv_num;
-	return;
-
-fail:
-	_lockd_free_pv_list(lock_pvs);
 }
 
 static int _lockd_retrive_lv_pv_num(struct volume_group *vg,
@@ -345,20 +340,15 @@ static void _lockd_retrive_lv_pv_list(struct volume_group *vg,
 			if (!lock_pvs->path[i]) {
 				log_error("Fail to allocate PV path for LV %s/%s",
 					  vg->name, lv_name);
-				goto fail;
+				_lockd_free_pv_list(lock_pvs);
+				return;
 			}
 
 			log_debug("Find PV device %s for LV %s/%s",
 				  lock_pvs->path[i], vg->name, lv_name);
-			i++;
+			lock_pvs->num = ++i;
 		}
 	}
-
-	lock_pvs->num = pv_num;
-	return;
-
-fail:
-	_lockd_free_pv_list(lock_pvs);
 }
 
 /*


