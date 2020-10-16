From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:04 +0000 (GMT)
Subject: stable-2.02 - cleanup: add spaces between literals
Message-ID: <20201016191104.2E396396E83D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f0c281f9a94dead2e32737f69f5e42a757433900
Commit:        f0c281f9a94dead2e32737f69f5e42a757433900
Parent:        736691ee6c1e971ad64c8e83a8f458094098ba24
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 21:53:31 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

cleanup: add spaces between literals

---
 tools/vgextend.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/vgextend.c b/tools/vgextend.c
index b803be086..fb6d76f71 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -102,7 +102,7 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 
 		if ((mda_copies != VGMETADATACOPIES_UNMANAGED) &&
 		    (mda_copies != mda_used)) {
-			log_warn("WARNING: Changing preferred number of copies of VG %s metadata from %"PRIu32" to %"PRIu32,
+			log_warn("WARNING: Changing preferred number of copies of VG %s metadata from %" PRIu32 " to %" PRIu32,
 				 vg_name, mda_copies, mda_used);
 			vg_set_mda_copies(vg, mda_used);
 		}


