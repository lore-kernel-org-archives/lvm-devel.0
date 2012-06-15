From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Jun 2012 12:44:10 +0000 (UTC)
Subject: master - Sync filesystem for thin snapshots
Message-ID: <20120615124410.C2020235D@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f99e5e35a9918c337e66b74aa6126cca9328c64
Commit:        2f99e5e35a9918c337e66b74aa6126cca9328c64
Parent:        2955f13ecc5cd654b7b332e7d8e03c481ec67ea5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 11:26:54 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 15 14:43:07 2012 +0200

Sync filesystem for thin snapshots

Add missing lockfs option when suspend origin, before thin volume
snapshot is created
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9128607..0158c6c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Fix missing sync of filesystem when creating thin volume snapshot.
 
 Version 2.02.96 - 8th June 2012
 ===============================
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d2cc5bf..1f21573 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1518,6 +1518,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
 
+	if (laopts->origin_only && lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
+		lockfs = 1;
+
 	/*
 	 * Suspending an LV directly above a PVMOVE LV also
  	 * suspends other LVs using that same PVMOVE LV.
@@ -1597,7 +1600,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	if (lv_is_thin_pool(lv) && laopts->origin_only)
 		messages_only = 1;
 
-	if (!lv_is_origin(lv))
+	if (!lv_is_origin(lv) && !lv_is_thin_volume(lv))
 		laopts->origin_only = 0;
 
 	if (test_mode()) {


