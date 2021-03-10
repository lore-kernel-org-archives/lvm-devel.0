From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:29 +0000 (GMT)
Subject: main - backup: set in vg_commit
Message-ID: <20210310003629.9846B3858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=177b63becc8ac0c0a9d74132f419f9ec38d4323d
Commit:        177b63becc8ac0c0a9d74132f419f9ec38d4323d
Parent:        88d04e917363a65374582313b3a4686ec51ea25c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 11:30:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:09:46 2021 +0100

backup: set in vg_commit

Another step towards better automatic handling of backup,
and automatically setup needs_backup after commit.

In some next step we should reduce number of backups and takem
then only at the command finish with  vg_committed content.
---
 lib/metadata/lv_manip.c | 2 --
 lib/metadata/metadata.c | 3 ++-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f580e5835..2ecd45eb1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6791,8 +6791,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 					display_lvname(pool_lv));
 	}
 
-	vg->needs_backup = 1;
-
 	lockd_lv(cmd, lock_lv, "un", LDLV_PERSISTENT);
 	lockd_free_lv(cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5de144616..22cb78337 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3173,7 +3173,8 @@ int vg_commit(struct volume_group *vg)
 			dm_list_init(&vg->msg_list);
 			vg->needs_write_and_commit = 0;
 		}
-	}
+		vg->needs_backup = 0;
+        }
 
 	/* If at least one mda commit succeeded, it was committed */
 	return ret;


