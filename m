From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:30 -0400
Subject: master - activation: add generic rule for visibility change
Message-ID: <201804201101.w3KB1Uxa031136@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff3ffe30e4c3ceac4abbdece7068bf7299a8ab39
Commit:        ff3ffe30e4c3ceac4abbdece7068bf7299a8ab39
Parent:        9068de011d900df46a87d6cb0de08160136bde66
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 20 11:55:22 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:07:36 2018 +0200

activation: add generic rule for visibility change

Whenever we make visible LV out of previously invisible one,
reload it's table - the is mandator for proper udev rule
processing as well as ensure content of dm table is correct.

TODO: this new generic rule probably make extra raid rules unnecessary.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 82b47c5..15908ca 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Enhnace preloading tree creating.
   Fix regression on acceptance of any LV on lvconvert.
   Restore usability of thin LV to be again external origin for another thin.
   Keep systemd vars on change event in 69-dm-lvm-metad.rules for systemd reload.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 777fc21..6611e99 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2108,6 +2108,12 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
 			return_0;
 	}
 
+	if (!lv_is_visible(lv) && (lv_pre = find_lv(detached->lv_pre->vg, lv->name)) &&
+	    lv_is_visible(lv_pre)) {
+		if (!_lv_preload(lv_pre, detached->laopts, detached->flush_required))
+			return_0;
+	}
+
 	/* FIXME: condition here should be far more limiting to really
 	 *        detect detached LVs */
 	if ((lv_pre = find_lv(detached->lv_pre->vg, lv->name))) {


