From: David Teigland <teigland@sourceware.org>
Date: Tue, 29 Sep 2020 19:43:34 +0000 (GMT)
Subject: master - lvmlockd vdo: disallow use of shared lock on LV
Message-ID: <20200929194334.B03033857C57@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82e270c18a76d68e2efc28a194bca2e428c18fae
Commit:        82e270c18a76d68e2efc28a194bca2e428c18fae
Parent:        af8044da3ab6891495f4d96b51a52bc4ae457ffb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 28 13:48:46 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 29 14:43:26 2020 -0500

lvmlockd vdo: disallow use of shared lock on LV

vdo cannot be active on multiple hosts concurrently
---
 lib/locking/lvmlockd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index dca7954ab..9d11077e3 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2374,6 +2374,7 @@ int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	    lv_is_thin_type(lv) ||
 	    lv_is_mirror_type(lv) ||
 	    lv_is_raid_type(lv) ||
+	    lv_is_vdo_type(lv) ||
 	    lv_is_cache_type(lv)) {
 		flags |= LDLV_MODE_NO_SH;
 	}


