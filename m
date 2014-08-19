From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:18:55 +0000 (UTC)
Subject: master - cleanup: reindent and make obvious error path
Message-ID: <20140819141855.AB9C46030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e4a21427bdba7d6cfc9083e8c3736707ab31cc0
Commit:        3e4a21427bdba7d6cfc9083e8c3736707ab31cc0
Parent:        10e2370d2efc501067702ffd5cd86940c3637e1c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 18 22:04:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

cleanup: reindent and make obvious error path

---
 lib/filters/filter-mpath.c |   34 +++++++++++++++-------------------
 1 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index a933ba1..902cc25 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -158,25 +158,21 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 		return 0;
 
 	switch (dev_get_primary_dev(dt, dev, &primary_dev)) {
-		default:
-		case 0:
-			/* Error. */
-			log_error("Failed to get primary device for %d:%d.", major, minor);
-			return 0;
-		case 1:
-			/* The dev is already a primary dev. Just continue with the dev. */
-			if (!(name = get_sysfs_name(dev)))
-				return_0;
-			break;
-		case 2:
-			/* The dev is partition. */
-			part_name = dev_name(dev); /* name of original dev for log_debug msg */
-			if (!(name = get_sysfs_name_by_devt(sysfs_dir, primary_dev, parent_name, PATH_MAX)))
-				return_0;
-			log_debug_devs("%s: Device is a partition, using primary "
-				       "device %s for mpath component detection",
-					part_name, name);
-			break;
+	case 2: /* The dev is partition. */
+		part_name = dev_name(dev); /* name of original dev for log_debug msg */
+		if (!(name = get_sysfs_name_by_devt(sysfs_dir, primary_dev, parent_name, sizeof(parent_name))))
+			return_0;
+		log_debug_devs("%s: Device is a partition, using primary "
+			       "device %s for mpath component detection",
+			       part_name, name);
+		break;
+	case 1: /* The dev is already a primary dev. Just continue with the dev. */
+		if (!(name = get_sysfs_name(dev)))
+			return_0;
+		break;
+	default: /* 0, error. */
+		log_error("Failed to get primary device for %d:%d.", major, minor);
+		return 0;
 	}
 
 	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/holders", sysfs_dir, name) < 0) {


