From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:12 +0000 (GMT)
Subject: master - cleanup: add spaces between literals
Message-ID: <20200901170212.283CF39540BE@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4baedfc5787e5b87cfb3f4b0ea13a6ae9bc9c52e
Commit:        4baedfc5787e5b87cfb3f4b0ea13a6ae9bc9c52e
Parent:        a37565709232085a61063385c1042a0ade0bc10b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 21:53:31 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

cleanup: add spaces between literals

---
 tools/vgextend.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/vgextend.c b/tools/vgextend.c
index dca87ff62..52393340f 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -111,7 +111,7 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 
 		if ((mda_copies != VGMETADATACOPIES_UNMANAGED) &&
 		    (mda_copies != mda_used)) {
-			log_warn("WARNING: Changing preferred number of copies of VG %s metadata from %"PRIu32" to %"PRIu32,
+			log_warn("WARNING: Changing preferred number of copies of VG %s metadata from %" PRIu32 " to %" PRIu32,
 				 vg_name, mda_copies, mda_used);
 			vg_set_mda_copies(vg, mda_used);
 		}


