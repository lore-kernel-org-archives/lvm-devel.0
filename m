From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:07 +0000 (UTC)
Subject: master - filters: swap device_is_usable test
Message-ID: <20150903213607.359F260F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81a9da8f6190b567bb26f28ff02be0e6b10cad9a
Commit:        81a9da8f6190b567bb26f28ff02be0e6b10cad9a
Parent:        a3c7e326c3e9950fe74e433c406d6e1b5a53bf25
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 2 16:08:30 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

filters: swap device_is_usable test

Fix regression introduced with commit:
2fc126b00d83991c6a2f3ed9aa61457294a4c45e

This commit has moved  pv_min_size() test in front
of device_is_usable(). However pv_min_size needs to open device,
so it may have actually get blocked.

So restore the original order and first validate
dm device to be usable for open.

It's worth to note that such check is not 'race-free',
but it usually eliminates 99.99% of problems ;).
---
 WHATS_NEW                   |    2 ++
 lib/filters/filter-usable.c |   40 ++++++++++++++++++++--------------------
 2 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 48b2a07..a7c7267 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.130 - 
 ===================================
+  Check if dm device is usable before checking its size (2.02.116).
+  Extend parsing of cache_check version in configure.
   Make lvpoll error messages visible in lvmpolld's stderr and in syslog.
   Add 'make install_full_man' to install all man pages regardless of config.
 
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index e39cb54..9377661 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -112,26 +112,11 @@ static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 {
 	filter_mode_t mode = *((filter_mode_t *) f->private);
 	struct dev_usable_check_params ucp = {0};
-	int r;
-
-	/* check if the device is not too small to hold a PV */
-	switch (mode) {
-		case FILTER_MODE_NO_LVMETAD:
-			/* fall through */
-		case FILTER_MODE_PRE_LVMETAD:
-			if (!_check_pv_min_size(dev))
-				return 0;
-			break;
-		case FILTER_MODE_POST_LVMETAD:
-			/* nothing to do here */
-			break;
-	}
+	int r = 1;
 
 	/* further checks are done on dm devices only */
-	if (!dm_is_dm_major(MAJOR(dev->dev)))
-		return 1;
-
-	switch (mode) {
+	if (dm_is_dm_major(MAJOR(dev->dev))) {
+		switch (mode) {
 		case FILTER_MODE_NO_LVMETAD:
 			ucp.check_empty = 1;
 			ucp.check_blocked = 1;
@@ -160,10 +145,25 @@ static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 			ucp.check_error_target = 0;
 			ucp.check_reserved = 0;
 			break;
+		}
+
+		if (!(r = device_is_usable(dev, ucp)))
+			log_debug_devs("%s: Skipping unusable device.", dev_name(dev));
 	}
 
-	if (!(r = device_is_usable(dev, ucp)))
-		log_debug_devs("%s: Skipping unusable device", dev_name(dev));
+	if (r) {
+		/* check if the device is not too small to hold a PV */
+		switch (mode) {
+		case FILTER_MODE_NO_LVMETAD:
+			/* fall through */
+		case FILTER_MODE_PRE_LVMETAD:
+			r = _check_pv_min_size(dev);
+			break;
+		case FILTER_MODE_POST_LVMETAD:
+			/* nothing to do here */
+			break;
+		}
+	}
 
 	return r;
 }


