From: David Teigland <teigland@sourceware.org>
Date: Tue, 1 May 2018 16:20:44 -0400
Subject: master - devices: ignore lvm1 and pool devices
Message-ID: <201805012020.w41KKiDp000491@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=24e7745d7a54c6ef66cc76ebe2358a1bf2d3bd20
Commit:        24e7745d7a54c6ef66cc76ebe2358a1bf2d3bd20
Parent:        db0560c1b0e63bff7c696488cee338653f02545a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 1 14:32:15 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 1 15:18:47 2018 -0500

devices: ignore lvm1 and pool devices

---
 lib/Makefile.in                |    2 +
 lib/commands/toolcontext.c     |    7 ++
 lib/device/dev-lvm1-pool.c     |  174 ++++++++++++++++++++++++++++++++++++++++
 lib/device/dev-type.h          |    3 +
 lib/filters/filter-signature.c |   96 ++++++++++++++++++++++
 lib/filters/filter.h           |    1 +
 6 files changed, 283 insertions(+), 0 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 8b87662..dbe7b90 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -37,6 +37,7 @@ SOURCES =\
 	device/dev-type.c \
 	device/dev-luks.c \
 	device/dev-dasd.c \
+	device/dev-lvm1-pool.c \
 	display/display.c \
 	error/errseg.c \
 	unknown/unknown.c \
@@ -51,6 +52,7 @@ SOURCES =\
 	filters/filter-type.c \
 	filters/filter-usable.c \
 	filters/filter-internal.c \
+	filters/filter-signature.c \
 	format_text/archive.c \
 	format_text/archiver.c \
 	format_text/export.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 64c9b1a..7f74c7e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1134,6 +1134,13 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 	}
 	nr_filt++;
 
+	/* signature filter. Required. */
+	if (!(filters[nr_filt] = signature_filter_create(cmd->dev_types))) {
+		log_error("Failed to create signature device filter");
+		goto bad;
+	}
+	nr_filt++;
+
 	/* md component filter. Optional, non-critical. */
 	if (find_config_tree_bool(cmd, devices_md_component_detection_CFG, NULL)) {
 		init_md_filtering(1);
diff --git a/lib/device/dev-lvm1-pool.c b/lib/device/dev-lvm1-pool.c
new file mode 100644
index 0000000..1fc3805
--- /dev/null
+++ b/lib/device/dev-lvm1-pool.c
@@ -0,0 +1,174 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib.h"
+#include "dev-type.h"
+#include "xlate.h"
+
+/*
+ * These lvm1 structs just used NAME_LEN in the previous format1 lvm2 code, but
+ * NAME_LEN was defined as 128 in generic lvm2 code that was not lvm1-specific
+ * and not disk-format-specific.
+ */
+
+#define LVM1_NAME_LEN 128
+
+struct data_area {
+	uint32_t base;
+	uint32_t size;
+} __attribute__ ((packed));
+
+struct pv_disk {
+	int8_t id[2];
+	uint16_t version;       /* lvm version */
+	struct data_area pv_on_disk;
+	struct data_area vg_on_disk;
+	struct data_area pv_uuidlist_on_disk;
+	struct data_area lv_on_disk;
+	struct data_area pe_on_disk;
+	int8_t pv_uuid[LVM1_NAME_LEN];
+	int8_t vg_name[LVM1_NAME_LEN];
+	int8_t system_id[LVM1_NAME_LEN];     /* for vgexport/vgimport */
+	uint32_t pv_major;
+	uint32_t pv_number;
+	uint32_t pv_status;
+	uint32_t pv_allocatable;
+	uint32_t pv_size;
+	uint32_t lv_cur;
+	uint32_t pe_size;
+	uint32_t pe_total;
+	uint32_t pe_allocated;
+
+	/* only present on version == 2 pv's */
+	uint32_t pe_start;
+} __attribute__ ((packed));
+
+
+int dev_is_lvm1(struct device *dev, char *buf, int buflen)
+{
+	struct pv_disk *pvd = (struct pv_disk *) buf;
+	uint32_t version;
+	int ret;
+
+	version = xlate16(pvd->version);
+
+	if (pvd->id[0] == 'H' && pvd->id[1] == 'M' &&
+	    (version == 1 || version == 2))
+		ret = 1;
+	else
+		ret = 0;
+
+	return ret;
+}
+
+
+#define POOL_MAGIC 0x011670
+#define POOL_NAME_SIZE 256
+
+#define NSPMajorVersion        4
+#define NSPMinorVersion        1
+#define NSPUpdateLevel 3
+
+/* When checking for version matching, the first two numbers **
+** are important for metadata formats, a.k.a pool labels.   **
+** All the numbers are important when checking if the user  **
+** space tools match up with the kernel module............. */
+
+#define POOL_VERSION           (NSPMajorVersion << 16 | \
+				NSPMinorVersion <<  8 | \
+				NSPUpdateLevel)
+
+struct pool_disk {
+	uint64_t pl_magic;      /* Pool magic number */
+	uint64_t pl_pool_id;    /* Unique pool identifier */
+	char pl_pool_name[POOL_NAME_SIZE];      /* Name of pool */
+	uint32_t pl_version;    /* Pool version */
+	uint32_t pl_subpools;   /* Number of subpools in this pool */
+	uint32_t pl_sp_id;      /* Subpool number within pool */
+	uint32_t pl_sp_devs;    /* Number of data partitions in this subpool */
+	uint32_t pl_sp_devid;   /* Partition number within subpool */
+	uint32_t pl_sp_type;    /* Partition type */
+	uint64_t pl_blocks;     /* Number of blocks in this partition */
+	uint32_t pl_striping;   /* Striping size within subpool */
+	/*
+	 * If the number of DMEP devices is zero, then the next field **
+	 * ** (pl_sp_dmepid) becomes the subpool ID for redirection.  In **
+	 * ** other words, if this subpool does not have the capability  **
+	 * ** to do DMEP, then it must specify which subpool will do it  **
+	 * ** in it's place
+	 */
+
+	/*
+	 * While the next 3 field are no longer used, they must stay to keep **
+	 * ** backward compatibility...........................................
+	 */
+	uint32_t pl_sp_dmepdevs;/* Number of dmep devices in this subpool */
+	uint32_t pl_sp_dmepid;  /* Dmep device number within subpool */
+	uint32_t pl_sp_weight;  /* if dmep dev, pref to using it */
+
+	uint32_t pl_minor;      /* the pool minor number */
+	uint32_t pl_padding;    /* reminder - think about alignment */
+
+	/*
+	 * Even though we're zeroing out 8k@the front of the disk before
+	 * writing the label, putting this in
+	 */
+	char pl_reserve[184];   /* bump the structure size out to 512 bytes */
+};
+
+#define CPIN_8(x, y, z) {memcpy((x), (y), (z));}
+#define CPIN_16(x, y) {(x) = xlate16_be((y));}
+#define CPIN_32(x, y) {(x) = xlate32_be((y));}
+#define CPIN_64(x, y) {(x) = xlate64_be((y));}
+
+static void pool_label_in(struct pool_disk *pl, void *buf)
+{
+	struct pool_disk *bufpl = (struct pool_disk *) buf;
+
+	CPIN_64(pl->pl_magic, bufpl->pl_magic);
+	CPIN_64(pl->pl_pool_id, bufpl->pl_pool_id);
+	CPIN_8(pl->pl_pool_name, bufpl->pl_pool_name, POOL_NAME_SIZE);
+	CPIN_32(pl->pl_version, bufpl->pl_version);
+	CPIN_32(pl->pl_subpools, bufpl->pl_subpools);
+	CPIN_32(pl->pl_sp_id, bufpl->pl_sp_id);
+	CPIN_32(pl->pl_sp_devs, bufpl->pl_sp_devs);
+	CPIN_32(pl->pl_sp_devid, bufpl->pl_sp_devid);
+	CPIN_32(pl->pl_sp_type, bufpl->pl_sp_type);
+	CPIN_64(pl->pl_blocks, bufpl->pl_blocks);
+	CPIN_32(pl->pl_striping, bufpl->pl_striping);
+	CPIN_32(pl->pl_sp_dmepdevs, bufpl->pl_sp_dmepdevs);
+	CPIN_32(pl->pl_sp_dmepid, bufpl->pl_sp_dmepid);
+	CPIN_32(pl->pl_sp_weight, bufpl->pl_sp_weight);
+	CPIN_32(pl->pl_minor, bufpl->pl_minor);
+	CPIN_32(pl->pl_padding, bufpl->pl_padding);
+	CPIN_8(pl->pl_reserve, bufpl->pl_reserve, 184);
+}
+
+int dev_is_pool(struct device *dev, char *buf, int buflen)
+{
+	struct pool_disk pd;
+	int ret;
+
+	pool_label_in(&pd, buf);
+
+	/* can ignore 8 rightmost bits for ondisk format check */
+	if ((pd.pl_magic == POOL_MAGIC) &&
+	    (pd.pl_version >> 8 == POOL_VERSION >> 8))
+		ret = 1;
+	else
+		ret = 0;
+
+	return ret;
+}
+
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index b0adfe2..e48e22b 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -62,6 +62,9 @@ int dev_is_luks(struct device *dev, uint64_t *signature);
 int dasd_is_cdl_formatted(struct device *dev);
 int udev_dev_is_mpath_component(struct device *dev);
 
+int dev_is_lvm1(struct device *dev, char *buf, int buflen);
+int dev_is_pool(struct device *dev, char *buf, int buflen);
+
 /* Signature wiping. */
 #define TYPE_LVM1_MEMBER	0x001
 #define TYPE_LVM2_MEMBER	0x002
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
new file mode 100644
index 0000000..b426476
--- /dev/null
+++ b/lib/filters/filter-signature.c
@@ -0,0 +1,96 @@
+/*
+ * Copyright (C) 2004 Luca Berra
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib.h"
+#include "filter.h"
+
+#ifdef __linux__
+
+#define BUFSIZE 4096
+
+static int _ignore_signature(struct dev_filter *f __attribute__((unused)),
+		      struct device *dev)
+{
+	char buf[BUFSIZE];
+	int ret = 0;
+
+	if (!dev_open_readonly(dev)) {
+		stack;
+		return -1;
+	}
+
+	memset(buf, 0, BUFSIZE);
+
+	if (!dev_read(dev, 0, BUFSIZE, DEV_IO_SIGNATURES, buf)) {
+		log_debug_devs("%s: Skipping: error in signature detection",
+			       dev_name(dev));
+		ret = 0;
+		goto out;
+	}
+
+	if (dev_is_lvm1(dev, buf, BUFSIZE)) {
+		log_debug_devs("%s: Skipping lvm1 device", dev_name(dev));
+		ret = 0;
+		goto out;
+	}
+
+	if (dev_is_pool(dev, buf, BUFSIZE)) {
+		log_debug_devs("%s: Skipping gfs-pool device", dev_name(dev));
+		ret = 0;
+		goto out;
+	}
+	ret = 1;
+
+out:
+	dev_close(dev);
+
+	return ret;
+}
+
+static void _destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying signature filter while in use %u times.", f->use_count);
+
+	dm_free(f);
+}
+
+struct dev_filter *signature_filter_create(struct dev_types *dt)
+{
+	struct dev_filter *f;
+
+	if (!(f = dm_zalloc(sizeof(*f)))) {
+		log_error("md filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _ignore_signature;
+	f->destroy = _destroy;
+	f->use_count = 0;
+	f->private = dt;
+
+	log_debug_devs("signature filter initialised.");
+
+	return f;
+}
+
+#else
+
+struct dev_filter *signature_filter_create(struct dev_types *dt)
+{
+	return NULL;
+}
+
+#endif
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index d75f6e1..2f809dd 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -31,6 +31,7 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 					    struct dev_filter *f,
 					    const char *file);
 struct dev_filter *sysfs_filter_create(void);
+struct dev_filter *signature_filter_create(struct dev_types *dt);
 
 struct dev_filter *internal_filter_create(void);
 int internal_filter_allow(struct dm_pool *mem, struct device *dev);


