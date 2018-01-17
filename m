From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:45 -0500
Subject: master - activation: guard exclusive activation
Message-ID: <201801171346.w0HDkjue030008@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8bcdef4fd172b705572e3c0b277e6941be642f4
Commit:        a8bcdef4fd172b705572e3c0b277e6941be642f4
Parent:        f41935909fec9eb8d64bc04530be2f38866f0b8e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 15 16:26:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:45:47 2018 +0100

activation: guard exclusive activation

Add protectional internall error whenever we spot activation
of 'exclusive' only segments in 'non-exclusive' mode.

TODO: possibly the activation locking could be enhanced to handle
this fully behind the scene - as for now this works purely for
lvchange/vgchange activation.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 00334b5..bc73cd7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Avoid non-exclusive activation of exclusive segment types.
   Fix trimming sibling PVs when doing a pvmove of raid subLVs.
   Preserve exclusive activation during thin snaphost merge.
   Suppress some repeated reads of the same disk data at the device layer.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4c69af7..b23400a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2568,6 +2568,16 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	struct lvinfo info;
 	int r = 0;
 
+	if (!laopts->exclusive &&
+	    (lv_is_origin(lv) ||
+	     lv_is_pvmove(lv) ||
+	     seg_only_exclusive(first_seg(lv))))  {
+		log_error(INTERNAL_ERROR "Trying non-exlusive activation of %s with "
+			  "a volume type %s requiring exclusive activation.",
+			  display_lvname(lv), lvseg_name(first_seg(lv)));
+		return 0;
+	}
+
 	if (!activation())
 		return 1;
 


