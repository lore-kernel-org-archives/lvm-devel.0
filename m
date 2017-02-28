From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 28 Feb 2017 17:10:57 -0500
Subject: master - lvconvert: adjust mininum region size check
Message-ID: <201702282210.v1SMAuH5017578@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=964114950ce3ce0539a47b966494868285679ef8
Commit:        964114950ce3ce0539a47b966494868285679ef8
Parent:        1828822bd8ad773d57d90841cb4036b49f3653b1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Feb 28 23:09:30 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 28 23:10:37 2017 +0100

lvconvert: adjust mininum region size check

The imposed minimum region size can cause rejection on
disk removing reshapes.  Lower it to avoid that.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 34e8856..b8447a0 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -106,7 +106,7 @@ static int _check_region_size_constraints(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (region_size * 8 > lv->size) {
+	if (region_size > lv->size) {
 		log_error("Regionsize too large for %s LV %s.",
 			   segtype->name, display_lvname(lv));
 		return 0;


