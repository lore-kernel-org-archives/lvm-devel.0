From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 15:00:45 -0500
Subject: master - pvmove: activation changes
Message-ID: <201711152000.vAFK0jxZ029293@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b978f505ff05c3581ccc633442b04c5d391add04
Commit:        b978f505ff05c3581ccc633442b04c5d391add04
Parent:        a25f9b210692fe5cd164441b76a78b11fb4ee4e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 15 14:26:10 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 21:00:26 2017 +0100

pvmove: activation changes

Do not use precommitted LV for suspend of pvmoving LVs.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   32 ++++----------------------------
 2 files changed, 5 insertions(+), 28 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b1454a3..ff60758 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Avoid using precommitted metadata for suspending pvmove tree.
   Ehnance pvmove locking.
   Deactivate activated LVs on error path when pvmove activation fails.
   Add "io" to log/debug_classes for logging low-level I/O.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d6189bb..efcecde 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2214,10 +2214,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		/* FIXME Consider aborting here */
 		stack;
 
-	critical_section_inc(cmd, "suspending");
-	if (pvmove_lv)
-		critical_section_inc(cmd, "suspending pvmove LV");
-
 	if (!laopts->origin_only &&
 	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
@@ -2229,30 +2225,10 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (laopts->origin_only && lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
 		lockfs = 1;
 
-	/*
-	 * Suspending an LV directly above a PVMOVE LV also
- 	 * suspends other LVs using that same PVMOVE LV.
-	 * FIXME Remove this and delay the 'clear node' until
- 	 * after the code knows whether there's a different
- 	 * inactive table to load or not instead so lv_suspend
- 	 * can be called separately for each LV safely.
- 	 */
-	if ((lv_pre->vg->status & PRECOMMITTED) &&
-	    lv_is_locked(lv_pre) && find_pvmove_lv_in_lv(lv_pre)) {
-		if (!_lv_suspend_lv(lv_pre, laopts, lockfs, flush_required)) {
-			critical_section_dec(cmd, "failed precommitted suspend");
-			if (pvmove_lv)
-				critical_section_dec(cmd, "failed precommitted suspend (pvmove)");
-			goto_out;
-		}
-	} else {
-		/* Normal suspend */
-		if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
-			critical_section_dec(cmd, "failed suspend");
-			if (pvmove_lv)
-				critical_section_dec(cmd, "failed suspend (pvmove)");
-			goto_out;
-		}
+	critical_section_inc(cmd, "suspending");
+	if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
+		critical_section_dec(cmd, "failed suspend");
+		goto_out;
 	}
 
 	r = 1;


