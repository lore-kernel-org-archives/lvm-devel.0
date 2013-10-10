From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Oct 2013 07:09:41 +0000 (UTC)
Subject: master - cleanup: WHATS_NEW + compiler warning about discarding const
Message-ID: <20131010070941.6058560755@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=304159c99ab59c61543cac747e47a1ff59d2dbb6
Commit:        304159c99ab59c61543cac747e47a1ff59d2dbb6
Parent:        7d299ecbb3a56f1633f17f746f864c02cd344c85
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 10 09:07:42 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 10 09:09:16 2013 +0200

cleanup: WHATS_NEW + compiler warning about discarding const

---
 WHATS_NEW                      |    3 +++
 daemons/lvmetad/lvmetad-core.c |    2 +-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a87a906..d0ed2ce 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.104
 ===================================
+  Fix possible race during daemon worker thread creation (lvmetad).
+  Fix possible deadlock while clearing lvmetad cache for full rescan.
+  Fix possible race while creating/destroying memory pools.
   Recognise NVM Express devices in filter.
   Fix failing metadata repair when lvmetad is used.
   Fix incorrect memory handling when reading messages from lvmetad.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 5a841e0..285c8cc 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -796,7 +796,7 @@ static response pv_gone(lvmetad_state *s, request r)
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
-	const char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
+	char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
 	if (vgid && !(vgid = dm_strdup(vgid))) {
 		unlock_pvid_to_pvmeta(s);


