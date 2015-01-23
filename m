From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 23 Jan 2015 20:01:53 +0000 (UTC)
Subject: master - devices: Do not support unpartitioned DASD.
Message-ID: <20150123200153.BEF23603A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dab3ebce4c75e931345159dfcf906cc32a066541
Commit:        dab3ebce4c75e931345159dfcf906cc32a066541
Parent:        4f5ce1fa430004f853b9aee1ac28fdd3cd5014ba
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 23 20:01:34 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 23 20:01:34 2015 +0000

devices: Do not support unpartitioned DASD.

---
 WHATS_NEW             |    1 +
 lib/device/dev-type.c |   14 ++++++++++++++
 lib/device/dev-type.h |    1 +
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 02f76be..666c51e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Do not support unpartitioned DASD devices.
   Improve config validation to check if setting with string value can be empty.
 
 Version 2.02.115 - 21st January 2015
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index a84f7e9..389b0c8 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -112,6 +112,10 @@ struct dev_types *create_dev_types(const char *proc_dir,
 		if (!strncmp("drbd", line + i, 4) && isspace(*(line + i + 4)))
 			dt->drbd_major = line_maj;
 
+		/* Look for DASD */
+		if (!strncmp("dasd", line + i, 4) && isspace(*(line + i + 4)))
+			dt->dasd_major = line_maj;
+
 		/* Look for EMC powerpath */
 		if (!strncmp("emcpower", line + i, 8) && isspace(*(line + i + 8)))
 			dt->emcpower_major = line_maj;
@@ -203,6 +207,9 @@ int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->emcpower_major)
 		return 1;
 
+	if (MAJOR(dev->dev) == dt->dasd_major)
+		return 1;
+
 	if (MAJOR(dev->dev) == dt->power2_major)
 		return 1;
 
@@ -222,6 +229,9 @@ const char *dev_subsystem_name(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->drbd_major)
 		return "DRBD";
 
+	if (MAJOR(dev->dev) == dt->dasd_major)
+		return "DASD";
+
 	if (MAJOR(dev->dev) == dt->emcpower_major)
 		return "EMCPOWER";
 
@@ -322,6 +332,10 @@ int dev_is_partitioned(struct dev_types *dt, struct device *dev)
 	if (!_is_partitionable(dt, dev))
 		return 0;
 
+	/* Unpartitioned DASD devices are not supported. */
+	if (MAJOR(dev->dev) == dt->dasd_major)
+		return 1;
+
 	return _has_partition_table(dev);
 }
 
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 8dcd4c8..10f82ba 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -44,6 +44,7 @@ struct dev_types {
 	int device_mapper_major;
 	int emcpower_major;
 	int power2_major;
+	int dasd_major;
 	struct dev_type_def dev_type_array[NUMBER_OF_MAJORS];
 };
 


