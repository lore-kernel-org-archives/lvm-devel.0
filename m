From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Jun 2013 11:17:02 +0000 (UTC)
Subject: master - cleanup: remove old and unused code to detect partition types
Message-ID: <20130612111702.296F360FAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bade9bfeae9b4205472d70232676d70412eefa8
Commit:        8bade9bfeae9b4205472d70232676d70412eefa8
Parent:        966d4f36d7fb29734c6176e21a139375c431eeac
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 12 12:46:46 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 12 13:14:49 2013 +0200

cleanup: remove old and unused code to detect partition types

This part of the code has not been used for ages, if ever.
If needed anytime in future, we should use some library
instead - libblkid?
---
 lib/device/dev-type.c |  181 -------------------------------------------------
 1 files changed, 0 insertions(+), 181 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 92120e8..b28fe75 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -428,187 +428,6 @@ out:
 	return ret;
 }
 
-#if 0
-#include <sys/stat.h>
-#include <sys/mman.h>
-#include <stdio.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include <ctype.h>
-
-#include <errno.h>
-#include <sys/ioctl.h>
-#include <linux/fs.h>
-#include <linux/major.h>
-#include <linux/genhd.h>
-
-int _get_partition_type(struct dev_filter *filter, struct device *d);
-
-#define MINOR_PART(dev) (MINOR((dev)->dev) % max_partitions(MINOR((dev)->dev)))
-
-int is_extended_partition(struct device *d)
-{
-	return (MINOR_PART(d) > 4) ? 1 : 0;
-}
-
-struct device *dev_primary(struct dev_mgr *dm, struct device *d)
-{
-	struct device *ret;
-
-	ret = dev_by_dev(dm, d->dev - MINOR_PART(dm, d));
-	/* FIXME: Needs replacing with a 'refresh' */
-	if (!ret) {
-		init_dev_scan(dm);
-		ret = dev_by_dev(dm, d->dev - MINOR_PART(dm, d));
-	}
-
-	return ret;
-
-}
-
-int partition_type_is_lvm(struct dev_mgr *dm, struct device *d)
-{
-	int pt;
-
-	pt = _get_partition_type(dm, d);
-
-	if (!pt) {
-		if (is_whole_disk(dm, d))
-			/* FIXME: Overloaded pt=0 in error cases */
-			return 1;
-		else {
-			log_error
-			    ("%s: missing partition table "
-			     "on partitioned device", d->name);
-			return 0;
-		}
-	}
-
-	if (is_whole_disk(dm, d)) {
-		log_error("%s: looks to possess partition table", d->name);
-		return 0;
-	}
-
-	/* check part type */
-	if (pt != LVM_PARTITION && pt != LVM_NEW_PARTITION) {
-		log_error("%s: invalid partition type 0x%x "
-			  "(must be 0x%x)", d->name, pt, LVM_NEW_PARTITION);
-		return 0;
-	}
-
-	if (pt == LVM_PARTITION) {
-		log_error
-		    ("%s: old LVM partition type found - please change to 0x%x",
-		     d->name, LVM_NEW_PARTITION);
-		return 0;
-	}
-
-	return 1;
-}
-
-int _get_partition_type(struct dev_mgr *dm, struct device *d)
-{
-	int pv_handle = -1;
-	struct device *primary;
-	ssize_t read_ret;
-	ssize_t bytes_read = 0;
-	char *buffer;
-	unsigned short *s_buffer;
-	struct partition *part;
-	loff_t offset = 0;
-	loff_t extended_offset = 0;
-	int part_sought;
-	int part_found = 0;
-	int first_partition = 1;
-	int extended_partition = 0;
-	int p;
-
-	if (!(primary = dev_primary(dm, d))) {
-		log_error
-		    ("Failed to find main device containing partition %s",
-		     d->name);
-		return 0;
-	}
-
-	if (!(buffer = dm_malloc(SECTOR_SIZE))) {
-		log_error("Failed to allocate partition table buffer");
-		return 0;
-	}
-
-	/* Get partition table */
-	if ((pv_handle = open(primary->name, O_RDONLY)) < 0) {
-		log_error("%s: open failed: %s", primary->name,
-			  strerror(errno));
-		return 0;
-	}
-
-	s_buffer = (unsigned short *) buffer;
-	part = (struct partition *) (buffer + 0x1be);
-	part_sought = MINOR_PART(dm, d);
-
-	do {
-		bytes_read = 0;
-
-		if (llseek(pv_handle, offset * SECTOR_SIZE, SEEK_SET) == -1) {
-			log_error("%s: llseek failed: %s",
-				  primary->name, strerror(errno));
-			return 0;
-		}
-
-		while ((bytes_read < SECTOR_SIZE) &&
-		       (read_ret =
-			read(pv_handle, buffer + bytes_read,
-			     SECTOR_SIZE - bytes_read)) != -1)
-			bytes_read += read_ret;
-
-		if (read_ret == -1) {
-			log_error("%s: read failed: %s", primary->name,
-				  strerror(errno));
-			return 0;
-		}
-
-		if (s_buffer[255] == 0xAA55) {
-			if (is_whole_disk(dm, d))
-				return -1;
-		} else
-			return 0;
-
-		extended_partition = 0;
-
-		/* Loop through primary partitions */
-		for (p = 0; p < 4; p++) {
-			if (part[p].sys_ind == DOS_EXTENDED_PARTITION ||
-			    part[p].sys_ind == LINUX_EXTENDED_PARTITION
-			    || part[p].sys_ind == WIN98_EXTENDED_PARTITION) {
-				extended_partition = 1;
-				offset = extended_offset + part[p].start_sect;
-				if (extended_offset == 0)
-					extended_offset = part[p].start_sect;
-				if (first_partition == 1)
-					part_found++;
-			} else if (first_partition == 1) {
-				if (p == part_sought) {
-					if (part[p].sys_ind == 0) {
-						/* missing primary? */
-						return 0;
-					}
-				} else
-					part_found++;
-			} else if (!part[p].sys_ind)
-				part_found++;
-
-			if (part_sought == part_found)
-				return part[p].sys_ind;
-
-		}
-		first_partition = 0;
-	}
-	while (extended_partition == 1);
-
-	return 0;
-}
-#endif
-
 #ifdef linux
 
 static unsigned long _dev_topology_attribute(struct dev_types *dt,


