From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:39:44 -0400
Subject: master - debug: use log_warn
Message-ID: <201903201339.x2KDdi7X012436@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74b5f228383d29ff84293a3691ecc02f023512ad
Commit:        74b5f228383d29ff84293a3691ecc02f023512ad
Parent:        dc6dea40331687b8740cc48833f4c7c42a2db1a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 13 12:58:13 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:37:44 2019 +0100

debug: use log_warn

This reports are not causing command failure, so report them as
warning.
---
 lib/filters/filter-mpath.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 25a507c..466d9c9 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -211,12 +211,12 @@ static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
 			return_0;
 		break;
 	default: /* 0, error. */
-		log_error("Failed to get primary device for %d:%d.", major, minor);
+		log_warn("Failed to get primary device for %d:%d.", major, minor);
 		return 0;
 	}
 
 	if (dm_snprintf(path, sizeof(path), "%s/block/%s/holders", sysfs_dir, name) < 0) {
-		log_error("Sysfs path to check mpath is too long.");
+		log_warn("Sysfs path to check mpath is too long.");
 		return 0;
 	}
 
@@ -225,7 +225,7 @@ static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
 		return 0;
 
 	if (!S_ISDIR(info.st_mode)) {
-		log_error("Path %s is not a directory.", path);
+		log_warn("Path %s is not a directory.", path);
 		return 0;
 	}
 


