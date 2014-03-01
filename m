From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  1 Mar 2014 13:24:42 +0000 (UTC)
Subject: master - lvmetad: fix memleak when pv changes it device
Message-ID: <20140301132442.8825460C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8513da9be5c061a85ab35d7d35ad937e8130490
Commit:        d8513da9be5c061a85ab35d7d35ad937e8130490
Parent:        c8e868f6e077e733b56514fb34301e11f4a8300a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 1 11:36:05 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 1 14:00:15 2014 +0100

lvmetad: fix memleak when pv changes it device

Test vgimportclone invokes mem leak of pvid which
would be otherwise lost when device_old_pvid
is removed from hash table.
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 224e351..8b5f31a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix memleak when lvmetad discovers PV to appear on another device.
   Fix calculation of maximum size of COW device for snapshot (2.02.99).
   Do not allow stripe size to be bigger then extent size for lvresize.
   Zero snapshot COW header when creating read-only snapshot.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1792fc0..bf0892b 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -908,6 +908,7 @@ static response pv_found(lvmetad_state *s, request r)
 
 	if (pvmeta_old_pvid && device != device_old_pvid) {
 		DEBUGLOG(s, "pv %s no longer on device %" PRIu64, pvid, device_old_pvid);
+		dm_free(dm_hash_lookup_binary(s->device_to_pvid, &device_old_pvid, sizeof(device_old_pvid)));
 		dm_hash_remove_binary(s->device_to_pvid, &device_old_pvid, sizeof(device_old_pvid));
 	}
 


