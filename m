From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 12 Apr 2017 16:11:54 -0400
Subject: master - lvconvert: return error without conversion
Message-ID: <201704122011.v3CKBsBn017806@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f715ab3b20f3e2589fa547428e84134349465da
Commit:        1f715ab3b20f3e2589fa547428e84134349465da
Parent:        56704383bfded631ea16707e598e38df93dfaab5
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Apr 12 22:11:30 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Apr 12 22:11:30 2017 +0200

lvconvert: return error without conversion

lvconvert parameters not causing a conversion (i.e. no type,
number of stripes, stripesize or regionsize changes) will
remove any allocated reshape space in which case the command
returns success.  If reshape space does not exist though,
return error.
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d16d49f..35f7fa5 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2227,7 +2227,7 @@ static int _raid_reshape(struct logical_volume *lv,
 		if (where_it_was == alloc_none) {
 			log_print_unless_silent("LV %s does not have reshape space allocated.",
 						display_lvname(lv));
-			return 1;
+			return 0;
 		}
 
 		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, NULL, NULL))


