From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Oct 2014 09:03:15 +0000 (UTC)
Subject: master - filter-usable: filter out blocked and suspended devices firmly when scanning for lvmetad
Message-ID: <20141008090315.E303960E46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c87e5a308a95e6e7c2d120ce816df14644f8e70a
Commit:        c87e5a308a95e6e7c2d120ce816df14644f8e70a
Parent:        f3bb1c018f7b6e38f0351a9994760bae7d9f00e3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 8 10:57:44 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 8 11:03:08 2014 +0200

filter-usable: filter out blocked and suspended devices firmly when scanning for lvmetad

We can't hang on blocked or suspended devices when the scan is done
for lvmetad update - when the device gets unblocked or resumed, there's
always CHANGE event generated which will fire the udev rule to run
extra pvscan --cache for that device which makes sure that lvmetad
is up-to-date.
---
 lib/filters/filter-usable.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 2a7ef49..a6932b0 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -36,8 +36,15 @@ static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 			break;
 		case FILTER_MODE_PRE_LVMETAD:
 			ucp.check_empty = 1;
-			ucp.check_blocked = 0;
-			ucp.check_suspended = ignore_suspended_devices();
+			/*
+			 * If we're scanning for lvmetad update,
+			 * we don't want to hang on blocked/suspended devices.
+			 * When the device is unblocked/resumed, surely,
+			 * there's going to be a CHANGE event so the device
+			 * gets scanned via udev rule anyway after resume.
+			 */
+			ucp.check_blocked = 1;
+			ucp.check_suspended = 1;
 			ucp.check_error_target = 1;
 			ucp.check_reserved = 1;
 			break;


