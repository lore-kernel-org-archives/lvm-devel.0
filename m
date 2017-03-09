From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 9 Mar 2017 06:16:25 -0500
Subject: master - lvconvert: remove superfluous compile time conditonal code
Message-ID: <201703091116.v29BGPAA007152@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=413164765fc81b6b9e551114d92f382ad273429b
Commit:        413164765fc81b6b9e551114d92f382ad273429b
Parent:        3d1df10af381bd1ae87be2209b1a7ff0d1167793
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 12:16:11 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 12:16:11 2017 +0100

lvconvert: remove superfluous compile time conditonal code

---
 tools/lvconvert.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4827d6e..9153633 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1369,12 +1369,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		}
 		goto try_new_takeover_or_reshape;
 	}
-#if 0
-	} else if ((!*lp->type_str || seg->segtype == lp->segtype) && !lp->stripe_size_supplied) {
-		log_error("Conversion operation not yet supported.");
-		return 0;
-	}
-#endif
 
 	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
 	    (lp->type_str && lp->type_str[0])) {


