From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  3 Feb 2016 13:57:53 +0000 (UTC)
Subject: master - filter: do not check for suspended devs in filter-usable in lvmetad mode
Message-ID: <20160203135753.7BB4560763@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0e0f5a9234a5ad4083e370c127d394c94726a1c
Commit:        c0e0f5a9234a5ad4083e370c127d394c94726a1c
Parent:        1498bc8cc442ebafea95e5dd8af69cdcd43619c2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 3 14:40:52 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 3 14:57:36 2016 +0100

filter: do not check for suspended devs in filter-usable in lvmetad mode

We already do check for suspended devs within udev rules where
the pvscan is to update lvmetad. So the check for suspended devs
in "pre-lvmetad" chain is not useful here - remove it - it may
be a source of hardly to detect races anyway (if udev rule detects
the device is not suspended and then the pvscan instance sees the
dev as suspended, we may end up not reacting to the event properly).
---
 WHATS_NEW                   |    1 +
 lib/filters/filter-usable.c |    9 +--------
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c2f22e9..48fcd55 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.142 - 
 ====================================
+  Do not check for suspended devices if scanning for lvmetad update.
   Fix part. table filter with external_device_info_source="udev" and blkid<2.20.
 
 Version 2.02.141 - 25th January 2016
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 129723d..4ee2e9d 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -126,15 +126,8 @@ static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 			break;
 		case FILTER_MODE_PRE_LVMETAD:
 			ucp.check_empty = 1;
-			/*
-			 * If we're scanning for lvmetad update,
-			 * we don't want to hang on blocked/suspended devices.
-			 * When the device is unblocked/resumed, surely,
-			 * there's going to be a CHANGE event so the device
-			 * gets scanned via udev rule anyway after resume.
-			 */
 			ucp.check_blocked = 1;
-			ucp.check_suspended = 1;
+			ucp.check_suspended = 0;
 			ucp.check_error_target = 1;
 			ucp.check_reserved = 1;
 			break;


