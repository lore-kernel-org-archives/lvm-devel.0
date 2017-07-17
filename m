From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:59 -0400
Subject: master - lvmetad: cleanup
Message-ID: <201707171140.v6HBexFc022628@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=567aa60fa1aa1779d0f30c9ff2ad9c4fafec3d23
Commit:        567aa60fa1aa1779d0f30c9ff2ad9c4fafec3d23
Parent:        767a5e1281ed436a11af90e0249bd59a5fbd40c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 22:28:50 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:33:17 2017 +0200

lvmetad: cleanup

Avoid hashing insertion when object with same content is already there.
---
 daemons/lvmetad/lvmetad-core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 64d4fbb..6d5f6a7 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -808,7 +808,8 @@ static int _update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 
 		if ((mode == REMOVE_EMPTY) && vgid_old) {
 			/* This copies the vgid_old string, doesn't reference it. */
-			if (!dm_hash_insert(to_check, vgid_old, (void*) 1)) {
+			if ((dm_hash_lookup(to_check, vgid_old) != (void*) 1) &&
+			    !dm_hash_insert(to_check, vgid_old, (void*) 1)) {
 				ERROR(s, "update_pvid_to_vgid out of memory for hash insert vgid_old %s", vgid_old);
 				goto abort_daemon;
 			}


