From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:10:50 -0500
Subject: master - resume: secure critical section
Message-ID: <201711241510.vAOFAolk000336@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8cf10948bd3acce7ae03f16982f0acbc4cde4fee
Commit:        8cf10948bd3acce7ae03f16982f0acbc4cde4fee
Parent:        ae6beda12ddd203b806c565faabb5715379eaf85
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 24 13:53:02 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:05:21 2017 +0100

resume: secure critical section

Only  thin-pool with origin_only suspend is allowed to be not suspending anything.
In such case pairing resume will 'decrement' critical section counter.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5ffe0ed..6ff4ccd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Do not change critical section counter on resume path without real resume.
   Enhance activation code to automatically suspend pvmove participants.
   Remove unnecessary single read from lvmdiskscan.
   Avoid using precommitted metadata for suspending pvmove tree.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index fe2fcc6..17bbe15 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2353,11 +2353,17 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		if (error_if_not_active)
 			goto_out;
 
+
+		/* ATM only thin-pool with origin-only suspend does not really suspend anything
+		 * it's used only for message passing to thin-pool */
+		if (laopts->origin_only && lv_is_thin_pool(lv))
+			critical_section_dec(cmd, "resumed");
+
 		if (!info.suspended && critical_section()) {
 			/* check if any subLV is suspended */
 			if ((r = for_each_sub_lv((struct logical_volume *)lv, &_check_suspended_lv, NULL))) {
 				/* Everything seems resumed */
-				critical_section_dec(cmd, "already resumed");
+				log_debug_activation("LV %s not suspended.", display_lvname(lv));
 				goto out;
 			}
 		} else {


