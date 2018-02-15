From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Feb 2018 07:57:25 -0500
Subject: master - locking: exclusive can be either remote or local
Message-ID: <201802151257.w1FCvPXr005055@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a2d2fe3a8cf840fcfcd23fb0e706c3699b79b5fa
Commit:        a2d2fe3a8cf840fcfcd23fb0e706c3699b79b5fa
Parent:        a1195aaa66ab4a04bc2149f53bf442f141b78229
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 14 23:06:49 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 15 13:54:55 2018 +0100

locking: exclusive can be either remote or local

When LOCK is exclusive and LV is already locally active,
it cannot be active remotely.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e2deaae..b11de8c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Do not report LV as remotely active when it's locally exclusive in cluster.
   Add deprecate messages for usage of mirrors with mirrorlog.
   Separate reporting of monitoring status and error status.
   Improve validation of created strings in vgimportclone.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1b870f7..3052f31 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1543,8 +1543,11 @@ static int _lv_is_active(const struct logical_volume *lv,
 	if (skip_cluster_query)
 		goto out;
 
-	if ((r = cluster_lock_held(lv->lvid.s, "", &e)) >= 0)
+	if ((r = cluster_lock_held(lv->lvid.s, "", &e)) >= 0) {
+		if (l && e)
+			r = 0; /* exclusive locally */
 		goto out;
+	}
 
 	/*
 	 * If lock query is not supported (due to interfacing with old


