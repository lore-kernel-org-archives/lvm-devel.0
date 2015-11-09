From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:37 +0000 (UTC)
Subject: master - lv_manip: do not deref NULL for debug message
Message-ID: <20151109092837.3BD1E6125F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=856e11e11c3b3ba4da3cbbd21982d34daa51aaa0
Commit:        856e11e11c3b3ba4da3cbbd21982d34daa51aaa0
Parent:        fa1d73084769ea4a6d07434e12dcae519938e4c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:28:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:20 2015 +0100

lv_manip: do not deref NULL for debug message

Coverity: when 'pv2' would be passed as NULL, do not try to
deref it in debug message.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 19f24f7..7930631 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Do not deref NULL pointer in debug message for _match_pv_tags().
   Drop unneeded stat() call when checking for sysfs file.
   Fix memory leak on error path of failing thin-pool percentage check.
   Add missing test for failing node allocation in lvmetad.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3c72c08..e23a8b9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2114,7 +2114,7 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 			else {
 				if (!pv_tags)
 					log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
-							tag_matched, pv_dev_name(pv1), pv_dev_name(pv2));
+							tag_matched, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
 				else
 					log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
 							" from consideration: PV tag %s already used.",


