From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:53 +0000 (GMT)
Subject: stable-2.02 - activation: move locking of critical section
Message-ID: <20201016191153.42D7C396EC6A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6373a8497776909b548fb5dcfb332b6502868f99
Commit:        6373a8497776909b548fb5dcfb332b6502868f99
Parent:        d4d3ff352f7d6bef57ffd724f1714c49b8811b66
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 26 14:56:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

activation: move locking of critical section

Move begining of 'suspending' critical section closer to _lv_suspend_lv()
for better correctness of error paths.
---
 lib/activate/activate.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3f3adafba..0bd769cdc 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2365,8 +2365,6 @@ skip_read:
 	if (laopts->origin_only && lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
 		lockfs = 1;
 
-	critical_section_inc(cmd, "suspending");
-
 	if (!lv_is_locked(lv) && lv_is_locked(lv_pre) &&
 	    (pvmove_lv = find_pvmove_lv_in_lv(lv_pre))) {
 		/*
@@ -2408,16 +2406,23 @@ skip_read:
 			}
 			dm_list_add(&suspend_lvs, &lvl->list);
 		}
+
+		critical_section_inc(cmd, "suspending");
+
 		dm_list_iterate_items(lvl, &suspend_lvs)
 			if (!_lv_suspend_lv(lvl->lv, laopts, lockfs, 1)) {
 				critical_section_dec(cmd, "failed suspend");
 				goto_out; /* FIXME: resume on recovery path? */
 			}
-	} else  /* Standard suspend */
+
+	} else { /* Standard suspend */
+		critical_section_inc(cmd, "suspending");
+
 		if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
 			critical_section_dec(cmd, "failed suspend");
 			goto_out;
 		}
+	}
 
 	r = 1;
 out:


