From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  9 Oct 2013 22:36:35 +0000 (UTC)
Subject: master - lvmetad: Fix a possible deadlock in pv_clear_all.
Message-ID: <20131009223635.9DC6C610C2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb613d4c101d7e9f51d70d55c1c71a471e6588ab
Commit:        cb613d4c101d7e9f51d70d55c1c71a471e6588ab
Parent:        b5aad86710be57833879ac0e8609021828949682
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 9 22:19:51 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 10 00:34:35 2013 +0200

lvmetad: Fix a possible deadlock in pv_clear_all.

---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index ed44def..5a841e0 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -829,8 +829,8 @@ static response pv_clear_all(lvmetad_state *s, request r)
 	DEBUGLOG(s, "pv_clear_all");
 
 	lock_pvid_to_pvmeta(s);
-	lock_vgid_to_metadata(s);
 	lock_pvid_to_vgid(s);
+	lock_vgid_to_metadata(s);
 
 	destroy_metadata_hashes(s);
 	create_metadata_hashes(s);


