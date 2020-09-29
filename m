From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:19 +0000 (GMT)
Subject: master - activation: move locking of critical section
Message-ID: <20200929084519.7C62B384B010@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af5f29c7e2f07005462d505c57a2f1440c9d50a3
Commit:        af5f29c7e2f07005462d505c57a2f1440c9d50a3
Parent:        3ed11170da87089bbfb263c84b25b53159ae1558
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 26 14:56:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:56 2020 +0200

activation: move locking of critical section

Move begining of 'suspending' critical section closer to _lv_suspend_lv()
for better correctness of error paths.
---
 lib/activate/activate.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a9a01a8bc..2e8f0e467 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2197,8 +2197,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (laopts->origin_only && lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
 		lockfs = 1;
 
-	critical_section_inc(cmd, "suspending");
-
 	if (!lv_is_locked(lv) && lv_is_locked(lv_pre) &&
 	    (pvmove_lv = find_pvmove_lv_in_lv(lv_pre))) {
 		/*
@@ -2240,16 +2238,23 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
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


