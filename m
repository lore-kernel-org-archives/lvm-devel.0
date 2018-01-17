From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 09:17:11 -0500
Subject: master - activation: move check later
Message-ID: <201801171417.w0HEHBGQ003684@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3c75bb2014e9ae7d212e0c016a94c529ac8a912
Commit:        f3c75bb2014e9ae7d212e0c016a94c529ac8a912
Parent:        e16d309d5651d1697f5246855ae816302cd8516f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 17 15:15:43 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 15:15:43 2018 +0100

activation: move check later

Check for lv when it's known in all cases.
---
 lib/activate/activate.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b23400a..18cc7cf 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2568,6 +2568,12 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	struct lvinfo info;
 	int r = 0;
 
+	if (!activation())
+		return 1;
+
+	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
+		goto out;
+
 	if (!laopts->exclusive &&
 	    (lv_is_origin(lv) ||
 	     lv_is_pvmove(lv) ||
@@ -2578,12 +2584,6 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		return 0;
 	}
 
-	if (!activation())
-		return 1;
-
-	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
-		goto out;
-
 	if (filter && !_passes_activation_filter(cmd, lv)) {
 		log_verbose("Not activating %s since it does not pass "
 			    "activation filter.", display_lvname(lv));


