From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:45:50 -0500
Subject: master - lvcreate: fix activation of cached LV
Message-ID: <201803061445.w26EjoDT026647@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23de09aeb87ec10bd1a553ea8868e2f946117232
Commit:        23de09aeb87ec10bd1a553ea8868e2f946117232
Parent:        b2f1254c14b7b86789e542be14041252a652eec2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 5 12:54:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:39:27 2018 +0100

lvcreate: fix activation of cached LV

Since LV for caching can be already a stacked LV, proper activation
needs to use lock holding LV.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 49b995e..3ed3e5a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Activate correct lock holding LV when it is cached.
   Do not modify archived metadata when removing striped raid.
   Fix memleak on error path when obtaining lv_raid_data_offset.
   Fix compatibility size test of extended external origin.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7f86a37..e901968 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1222,6 +1222,8 @@ static int _determine_cache_argument(struct volume_group *vg,
 			return_0; /* FIXME */
 
 		/* Put origin into resulting activation state first */
+		lv = (struct logical_volume *)lv_lock_holder(lv);
+
 		if (is_change_activating(lp->activate)) {
 			if ((lp->activate == CHANGE_AAY) &&
 			    !lv_passes_auto_activation_filter(cmd, lv)) {


