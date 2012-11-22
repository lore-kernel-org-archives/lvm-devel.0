From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 22 Nov 2012 00:42:51 +0000 (UTC)
Subject: master - RAID: Do not allow --splitmirrors on RAID10 logical volumes.
Message-ID: <20121122004252.0CE33F8E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb0cee9a66db6141ed331c8058d2c5c2c3a30cc1
Commit:        fb0cee9a66db6141ed331c8058d2c5c2c3a30cc1
Parent:        400f6442861c6832f5f89d6e40e668517895b50d
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Nov 21 18:39:26 2012 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Nov 21 18:39:26 2012 -0600

RAID:  Do not allow --splitmirrors on RAID10 logical volumes.

RAID10 does not have the ability to split off images for independent
use.  So, 'lvconvert --splitmirrors' will not work and must be
disallowed.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e96703c..a0504fc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Do not allow --splitmirrors on RAID10 logical volumes.
   Skip mlocking [vectors] on arm architecture.
   Support allocation of pool metadata with lvconvert command.
   Move common functionality for thin lvcreate and lvconvert to toollib.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b9f75ff..8be0abe 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1152,7 +1152,8 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		return 0;
 	}
 
-	if (!seg_is_mirrored(first_seg(lv))) {
+	if (!seg_is_mirrored(first_seg(lv)) ||
+	    !strcmp(first_seg(lv)->segtype->name, "raid10")) {
 		log_error("Unable to split logical volume of segment type, %s",
 			  first_seg(lv)->segtype->ops->name(first_seg(lv)));
 		return 0;


