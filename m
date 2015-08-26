From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 26 Aug 2015 20:18:00 +0000 (UTC)
Subject: master - vgdisplay: Drop error message for exported VGs.
Message-ID: <20150826201800.BBCB860EBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8740b7cb77699dbb78e80ed4e8bd6c742626558e
Commit:        8740b7cb77699dbb78e80ed4e8bd6c742626558e
Parent:        746b1bcf2ad08b0a15dbf6ea0e140c2eb71ff87a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 26 21:11:46 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 26 21:11:46 2015 +0100

vgdisplay: Drop error message for exported VGs.

Originally when vgdisplay encountered an exported VG it issued a
WARNING.  Commit d6b1de30 replaced this with an error message
but still exited with success (incorrect).  A backtrace was recently
added in commit b19380998739b9971d27845a70a78511c2335cb0.

As vgdisplay already states that the VG is exported in its output,
just drop these messages completely.
---
 WHATS_NEW         |    1 +
 tools/vgdisplay.c |    3 ---
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d98bcc8..cac567f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.129 -
 ===================================
+  Drop error message when vgdisplay encounters an exported VG. (2.02.27)
   Fix shared library generation to stop exporting internal functions.(2.02.120)
   Accept --cachemode with lvconvert.
   Fix and improve reporting properties of cache-pool.
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 0127e7c..1acb3ec 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -22,9 +22,6 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, activevolumegroups_ARG) && !lvs_in_vg_activated(vg))
 		return ECMD_PROCESSED;
 
-	if (!vg_check_status(vg, EXPORTED_VG))
-		stack;
-
 	if (arg_count(cmd, colon_ARG)) {
 		vgdisplay_colons(vg);
 		return ECMD_PROCESSED;


