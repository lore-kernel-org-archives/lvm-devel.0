From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  7 Jan 2014 02:32:03 +0000 (UTC)
Subject: master - lvmetad: Fix a corruption-prone race in error path.
Message-ID: <20140107023203.75A3F600D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89e7d81d92274ed60b73332e04ceb966e398a0e6
Commit:        89e7d81d92274ed60b73332e04ceb966e398a0e6
Parent:        087d33d73b28fcf42f7db5402c80bd174c3d9451
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jan 7 03:04:14 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jan 7 03:04:14 2014 +0100

lvmetad: Fix a corruption-prone race in error path.

---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index bc306f3..7409839 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -903,8 +903,8 @@ static response pv_found(lvmetad_state *s, request r)
 
 	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
 	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup)) {
-		unlock_pvid_to_pvmeta(s);
 		dm_hash_remove(s->pvid_to_pvmeta, pvid);
+		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(cft);
 		dm_free(pvid_dup);
 		return reply_fail("out of memory");


