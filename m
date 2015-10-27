From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Oct 2015 10:43:21 +0000 (UTC)
Subject: master - cleanup: snapshots of snapshots message
Message-ID: <20151027104321.7866E6103C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1af2ab10d02c2f02891d5047af563651fbe294bb
Commit:        1af2ab10d02c2f02891d5047af563651fbe294bb
Parent:        729f489009b4dfc8488265bc64414edcfeae0755
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 22 13:32:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 27 11:42:48 2015 +0100

cleanup: snapshots of snapshots message

No plans to support thick snapshost of snapshots.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 264b3f7..869e506 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Dropping 'yet' from error of unsupported thick snapshot of snapshots.
   Do not support unpartitioned DASD devices with CDL formatted with pvcreate.
   For thins use flush for suspend only when volume size is reduced.
   Enable code which detects the need of flush during suspend.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8029dab..8e20dfa 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7248,8 +7248,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				return NULL;
 			}
 			if (lv_is_cow(origin_lv)) {
-				log_error("Snapshots of snapshots are not "
-					  "supported yet.");
+				log_error("Snapshots of snapshots are not supported.");
 				return NULL;
 			}
 			if (lv_is_locked(origin_lv)) {


