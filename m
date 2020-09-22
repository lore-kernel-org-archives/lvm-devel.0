From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:47 +0000 (GMT)
Subject: master - vdo: correct message about policy extend support
Message-ID: <20200922214647.13CAE385780B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=642ef5439962c721da37343a51468872027407c1
Commit:        642ef5439962c721da37343a51468872027407c1
Parent:        e08a0421a374164fe49276d0bf676989bf7aea14
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 23:16:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 23:25:16 2020 +0200

vdo: correct message about policy extend support

Policy extend is already supported for vdo pools as well,
so correct the error message.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6ac6a602b..fc0acd6ee 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5121,7 +5121,7 @@ static int _lvresize_check(struct logical_volume *lv,
 	    !lv_is_cow(lv) &&
 	    !lv_is_thin_pool(lv) &&
 	    !lv_is_vdo_pool(lv)) {
-		log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
+		log_error("Policy-based resize is supported only for snapshot, thin pool and vdo pool volumes.");
 		return 0;
 	}
 


