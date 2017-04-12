From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 15:38:47 -0400
Subject: master - libdm: set min,maj
Message-ID: <201704121938.v3CJclX0012239@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=635e7e0c928aba62f7d6ddf892978ece6217b905
Commit:        635e7e0c928aba62f7d6ddf892978ece6217b905
Parent:        3e3f2a53eaa5979d2c32b231f528e7b99c55675e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 1 12:13:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 21:33:47 2017 +0200

libdm: set min,maj

Reset derefered pointers instead of pointers.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 23f3ce5..2fa2566 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.139 - 
 ==================================
+  Fix assignment in _target_version() when dm task can't run.
   Flush stdout on each iteration when using --count or --interval.
   Show detailed error message when execvp fails while starting dmfilemapd.
   Fix segmentation fault when dmfilemapd is run with no arguments.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 80bfc1b..6ea710d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2400,9 +2400,8 @@ static int _target_version(const char *target_name, uint32_t *maj,
 	if (!dm_task_run(dmt)) {
 		log_debug_activation("Failed to get %s target versions", target_name);
 		/* Assume this was because LIST_VERSIONS isn't supported */
-		maj = min = patchlevel = 0;
+		*maj = *min = *patchlevel = 0;
 		r = 1;
-
 	} else
 		for (target = dm_task_get_versions(dmt);
 		     target != last_target;


