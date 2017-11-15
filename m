From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:46 -0500
Subject: master - pvmove: always flush when working with pvmove tree
Message-ID: <201711151309.vAFD9ku8001992@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8212e1047e2f42f4e13e2aadec5cf73b8d3a082e
Commit:        8212e1047e2f42f4e13e2aadec5cf73b8d3a082e
Parent:        35b207946a514c411e4d7c9be235e093ae5adf7d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 15 12:07:47 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 14:03:22 2017 +0100

pvmove: always flush when working with pvmove tree

---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 0dc67f2..d6189bb 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2204,7 +2204,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	 * NOTE: Mirror repair requires noflush for proper repair!
 	 * TODO: Relax this limiting condition further */
 	if (!flush_required &&
-	    (lv_is_pvmove(lv) ||
+	    (lv_is_pvmove(lv) || pvmove_lv ||
 	     (!lv_is_mirror(lv) && !lv_is_thin_pool(lv) && !lv_is_thin_volume(lv)))) {
 		log_debug("Requiring flush for LV %s.", display_lvname(lv));
 		flush_required = 1;


