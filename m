From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Nov 2006 23:11:49 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20061130231149.19159.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-30 23:11:42

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/cache      : lvmcache.c 
	lib/device     : dev-io.c device.c 
	lib/display    : display.c 
	lib/format1    : disk-rep.c disk-rep.h lvm1-label.c 
	lib/format_pool: disk_rep.c disk_rep.h pool_label.c 
	lib/format_text: format-text.c import_vsn1.c text_label.c 
	lib/label      : label.c label.h 
	lib/locking    : cluster_locking.c locking.c 
	lib/metadata   : metadata.c 
	tools          : pvchange.c pvscan.c vgmerge.c vgreduce.c 

Log message:
	Adjust some alignments for ia64 and sparc.
	(Some of the changes are probably unnecessary.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.511&r2=1.512
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.h.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/pool_label.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2006/11/30 17:52:47	1.511
+++ LVM2/WHATS_NEW	2006/11/30 23:11:39	1.512
@@ -1,5 +1,6 @@
 Version 2.02.16 -
 ====================================
+  Adjust some alignments for ia64/sparc.
   Fix mirror segment removal to use temporary error segment.
   Always compile debug logging into clvmd.
   Add startup timeout to RHEL4 clvmd startup script.
--- LVM2/lib/activate/dev_manager.c	2006/11/20 16:45:45	1.116
+++ LVM2/lib/activate/dev_manager.c	2006/11/30 23:11:39	1.117
@@ -1072,7 +1072,7 @@
 {
 	struct dm_tree *dtree;
 	struct dm_tree_node *root;
-	char dlid[sizeof(UUID_PREFIX) + sizeof(struct id) - 1];
+	char dlid[sizeof(UUID_PREFIX) + sizeof(struct id) - 1] __attribute((aligned(8)));
 	int r = 1;
 
 	if (!(dtree = dm_tree_create())) {
--- LVM2/lib/cache/lvmcache.c	2006/08/01 14:56:32	1.28
+++ LVM2/lib/cache/lvmcache.c	2006/11/30 23:11:39	1.29
@@ -114,7 +114,7 @@
 	struct list *devh, *tmp;
 	struct list devs;
 	struct device_list *devl;
-	char vgid_found[ID_LEN + 1];
+	char vgid_found[ID_LEN + 1] __attribute((aligned(8)));
 
 	if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 		return NULL;
@@ -151,7 +151,7 @@
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
-	char id[ID_LEN + 1];
+	char id[ID_LEN + 1] __attribute((aligned(8)));
 
 	if (!_vgid_hash || !vgid)
 		return NULL;
@@ -186,7 +186,7 @@
 struct lvmcache_info *info_from_pvid(const char *pvid)
 {
 	struct lvmcache_info *info;
-	char id[ID_LEN + 1];
+	char id[ID_LEN + 1] __attribute((aligned(8)));
 
 	if (!_pvid_hash || !pvid)
 		return NULL;
@@ -476,7 +476,8 @@
 			  struct lvmcache_vginfo *primary_vginfo)
 {
 	struct lvmcache_vginfo *last_vginfo = primary_vginfo;
-	char uuid_primary[64], uuid_new[64];
+	char uuid_primary[64] __attribute((aligned(8)));
+	char uuid_new[64] __attribute((aligned(8)));
 	int use_new = 0;
 	
 	/* Pre-existing VG takes precedence. Unexported VG takes precedence. */
@@ -709,7 +710,7 @@
 {
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
-	char pvid_s[ID_LEN + 1];
+	char pvid_s[ID_LEN + 1] __attribute((aligned(8)));
 
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
@@ -733,7 +734,7 @@
 {
 	struct label *label;
 	struct lvmcache_info *existing, *info;
-	char pvid_s[ID_LEN + 1];
+	char pvid_s[ID_LEN + 1] __attribute((aligned(8)));
 
 	if (!_vgname_hash && !lvmcache_init()) {
 		log_error("Internal cache initialisation failed");
--- LVM2/lib/device/dev-io.c	2006/08/17 18:23:43	1.54
+++ LVM2/lib/device/dev-io.c	2006/11/30 23:11:40	1.55
@@ -605,7 +605,7 @@
 int dev_set(struct device *dev, uint64_t offset, size_t len, int value)
 {
 	size_t s;
-	char buffer[4096];
+	char buffer[4096] __attribute((aligned(8)));
 
 	if (!dev_open(dev)) {
 		stack;
--- LVM2/lib/device/device.c	2006/05/11 17:58:58	1.21
+++ LVM2/lib/device/device.c	2006/11/30 23:11:40	1.22
@@ -53,7 +53,7 @@
 {
 	int ret = 0;
 	unsigned p;
-	uint8_t buf[SECTOR_SIZE];
+	uint16_t buf[SECTOR_SIZE/sizeof(uint16_t)];
 	uint16_t *part_magic;
 	struct partition *part;
 
@@ -70,7 +70,7 @@
 	/* FIXME Check for other types of partition table too */
 
 	/* Check for msdos partition table */
-	part_magic = (uint16_t *)(buf + PART_MAGIC_OFFSET);
+	part_magic = buf + PART_MAGIC_OFFSET/sizeof(buf[0]);
 	if ((*part_magic == xlate16(PART_MAGIC))) {
 		part = (struct partition *) (buf + PART_OFFSET);
 		for (p = 0; p < 4; p++, part++) {
--- LVM2/lib/display/display.c	2006/11/10 18:24:11	1.69
+++ LVM2/lib/display/display.c	2006/11/30 23:11:40	1.70
@@ -234,7 +234,7 @@
 
 void pvdisplay_colons(struct physical_volume *pv)
 {
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 
 	if (!pv)
 		return;
@@ -262,7 +262,7 @@
 void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
 		    void *handle __attribute((unused)))
 {
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 	const char *size;
 
 	uint32_t pe_free;
@@ -324,7 +324,7 @@
 		    struct physical_volume *pv,
 		    void *handle __attribute((unused)))
 {
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 
 	if (!pv)
 		return 0;
@@ -371,7 +371,7 @@
 {
 	struct lvinfo info;
 	int inkernel, snap_active = 0;
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 	struct lv_segment *snap_seg = NULL;
 	float snap_percent;	/* fused, fsize; */
 
@@ -537,7 +537,7 @@
 {
 	uint32_t access;
 	uint32_t active_pvs;
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 
 	if (vg->status & PARTIAL_VG)
 		active_pvs = list_size(&vg->pvs);
@@ -616,7 +616,7 @@
 {
 	uint32_t active_pvs;
 	const char *access;
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 
 	if (vg->status & PARTIAL_VG)
 		active_pvs = list_size(&vg->pvs);
--- LVM2/lib/format1/disk-rep.c	2006/08/01 14:56:32	1.64
+++ LVM2/lib/format1/disk-rep.c	2006/11/30 23:11:40	1.65
@@ -248,7 +248,7 @@
 {
 	unsigned num_read = 0;
 	struct uuid_list *ul;
-	char buffer[NAME_LEN];
+	char buffer[NAME_LEN] __attribute((aligned(8)));
 	uint64_t pos = data->pvd.pv_uuidlist_on_disk.base;
 	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;
 
--- LVM2/lib/format1/disk-rep.h	2006/10/19 12:53:46	1.49
+++ LVM2/lib/format1/disk-rep.h	2006/11/30 23:11:40	1.50
@@ -148,7 +148,7 @@
 
 struct uuid_list {
 	struct list list;
-	char uuid[NAME_LEN];
+	char uuid[NAME_LEN] __attribute((aligned(8)));
 };
 
 struct lvd_list {
@@ -161,11 +161,11 @@
 	struct dm_pool *mem;
 	struct device *dev;
 
-	struct pv_disk pvd;
-	struct vg_disk vgd;
-	struct list uuids;
-	struct list lvds;
-	struct pe_disk *extents;
+	struct pv_disk pvd __attribute((aligned(8)));
+	struct vg_disk vgd __attribute((aligned(8)));
+	struct list uuids __attribute((aligned(8)));
+	struct list lvds __attribute((aligned(8)));
+	struct pe_disk *extents __attribute((aligned(8)));
 };
 
 /*
--- LVM2/lib/format1/lvm1-label.c	2006/05/09 21:23:50	1.13
+++ LVM2/lib/format1/lvm1-label.c	2006/11/30 23:11:40	1.14
@@ -30,7 +30,7 @@
 		op);
 }
 
-static int _lvm1_can_handle(struct labeller *l, char *buf, uint64_t sector)
+static int _lvm1_can_handle(struct labeller *l, void *buf, uint64_t sector)
 {
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	uint32_t version;
@@ -48,13 +48,13 @@
 	return 0;
 }
 
-static int _lvm1_write(struct label *label, char *buf)
+static int _lvm1_write(struct label *label, void *buf)
 {
 	_not_supported("write");
 	return 0;
 }
 
-static int _lvm1_read(struct labeller *l, struct device *dev, char *buf,
+static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 		 struct label **label)
 {
 	struct pv_disk *pvd = (struct pv_disk *) buf;
--- LVM2/lib/format_pool/disk_rep.c	2006/05/09 21:23:50	1.8
+++ LVM2/lib/format_pool/disk_rep.c	2006/11/30 23:11:40	1.9
@@ -36,7 +36,7 @@
 			    struct dm_pool *mem, struct pool_list *pl,
 			    const char *vg_name)
 {
-	char buf[512];
+	char buf[512] __attribute((aligned(8)));
 
 	/* FIXME: Need to check the cache here first */
 	if (!dev_read(dev, UINT64_C(0), 512, buf)) {
@@ -59,7 +59,7 @@
 
 	list_iterate_items(pl, head) {
 		if (id_equal(&data->pv_uuid, &pl->pv_uuid)) {
-			char uuid[ID_LEN + 7];
+			char uuid[ID_LEN + 7] __attribute((aligned(8)));
 
 			id_write_format(&pl->pv_uuid, uuid, ID_LEN + 7);
 
@@ -84,7 +84,7 @@
 	struct lvmcache_info *info;
 	struct id pvid;
 	struct id vgid;
-	char uuid[ID_LEN + 7];
+	char uuid[ID_LEN + 7] __attribute((aligned(8)));
 	struct pool_disk *pd = &pl->pd;
 
 	pool_label_in(pd, buf);
@@ -128,7 +128,7 @@
  * be able to interpret ondisk labels correctly.  Always use
  * this function before writing to disk.
  */
-void pool_label_out(struct pool_disk *pl, char *buf)
+void pool_label_out(struct pool_disk *pl, void *buf)
 {
 	struct pool_disk *bufpl = (struct pool_disk *) buf;
 
@@ -163,7 +163,7 @@
  * correctly.  Always use this function before using labels that
  * were read from disk.
  */
-void pool_label_in(struct pool_disk *pl, char *buf)
+void pool_label_in(struct pool_disk *pl, void *buf)
 {
 	struct pool_disk *bufpl = (struct pool_disk *) buf;
 
--- LVM2/lib/format_pool/disk_rep.h	2005/10/16 23:03:57	1.4
+++ LVM2/lib/format_pool/disk_rep.h	2006/11/30 23:11:40	1.5
@@ -134,8 +134,8 @@
 
 int read_pool_label(struct pool_list *pl, struct labeller *l,
 		    struct device *dev, char *buf, struct label **label);
-void pool_label_out(struct pool_disk *pl, char *buf);
-void pool_label_in(struct pool_disk *pl, char *buf);
+void pool_label_out(struct pool_disk *pl, void *buf);
+void pool_label_in(struct pool_disk *pl, void *buf);
 void get_pool_uuid(char *uuid, uint64_t poolid, uint32_t spid, uint32_t devid);
 int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct list *pls);
 int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem,
--- LVM2/lib/format_pool/pool_label.c	2006/05/09 21:23:50	1.4
+++ LVM2/lib/format_pool/pool_label.c	2006/11/30 23:11:40	1.5
@@ -29,7 +29,7 @@
 		  op);
 }
 
-static int _pool_can_handle(struct labeller *l, char *buf, uint64_t sector)
+static int _pool_can_handle(struct labeller *l, void *buf, uint64_t sector)
 {
 
 	struct pool_disk pd;
@@ -50,13 +50,13 @@
 	return 0;
 }
 
-static int _pool_write(struct label *label, char *buf)
+static int _pool_write(struct label *label, void *buf)
 {
 	_pool_not_supported("write");
 	return 0;
 }
 
-static int _pool_read(struct labeller *l, struct device *dev, char *buf,
+static int _pool_read(struct labeller *l, struct device *dev, void *buf,
 		 struct label **label)
 {
 	struct pool_list pl;
--- LVM2/lib/format_text/format-text.c	2006/11/10 18:24:11	1.69
+++ LVM2/lib/format_text/format-text.c	2006/11/30 23:11:41	1.70
@@ -193,7 +193,7 @@
 				       int *precommitted)
 {
 	size_t len;
-	char vgnamebuf[NAME_LEN + 2];
+	char vgnamebuf[NAME_LEN + 2] __attribute((aligned(8)));
 	struct raw_locn *rlocn, *rlocn_precommitted;
 	struct lvmcache_info *info;
 
@@ -885,8 +885,8 @@
 	uint32_t wrap = 0;
 	const char *vgname = NULL;
 	unsigned int len = 0;
-	char buf[NAME_LEN + 1];
-        char uuid[64];
+	char buf[NAME_LEN + 1] __attribute((aligned(8)));
+	char uuid[64] __attribute((aligned(8)));
 
 	if (!dev_open(dev_area->dev)) {
 		stack;
@@ -1131,7 +1131,7 @@
 	struct lvmcache_info *info;
 	struct mda_context *mdac;
 	struct metadata_area *mda;
-	char buf[MDA_HEADER_SIZE];
+	char buf[MDA_HEADER_SIZE] __attribute((aligned(8)));
 	struct mda_header *mdah = (struct mda_header *) buf;
 	uint64_t adjustment;
 
@@ -1742,7 +1742,7 @@
 	}
 
 	if (!(dev_area.dev = device_from_pvid(cmd, &id))) {
-		char buffer[64];
+		char buffer[64] __attribute((aligned(8)));
 
 		if (!id_write_format(&id, buffer, sizeof(buffer)))
 			log_err("Couldn't find device.");
--- LVM2/lib/format_text/import_vsn1.c	2006/10/19 12:53:47	1.37
+++ LVM2/lib/format_text/import_vsn1.c	2006/11/30 23:11:41	1.38
@@ -149,7 +149,7 @@
 	 * Convert the uuid into a device.
 	 */
 	if (!(pv->dev = device_from_pvid(fid->fmt->cmd, &pv->id))) {
-		char buffer[64];
+		char buffer[64] __attribute((aligned(8)));
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			log_error("Couldn't find device.");
--- LVM2/lib/format_text/text_label.c	2006/05/11 17:58:58	1.16
+++ LVM2/lib/format_text/text_label.c	2006/11/30 23:11:41	1.17
@@ -24,7 +24,7 @@
 #include <fcntl.h>
 
 static int _text_can_handle(struct labeller *l __attribute((unused)),
-			    char *buf,
+			    void *buf,
 			    uint64_t sector __attribute((unused)))
 {
 	struct label_header *lh = (struct label_header *) buf;
@@ -35,7 +35,7 @@
 	return 0;
 }
 
-static int _text_write(struct label *label, char *buf)
+static int _text_write(struct label *label, void *buf)
 {
 	struct label_header *lh = (struct label_header *) buf;
 	struct pv_header *pvhdr;
@@ -189,7 +189,7 @@
 	return 1;
 }
 
-static int _text_read(struct labeller *l, struct device *dev, char *buf,
+static int _text_read(struct labeller *l, struct device *dev, void *buf,
 		 struct label **label)
 {
 	struct label_header *lh = (struct label_header *) buf;
--- LVM2/lib/label/label.c	2006/11/14 15:03:07	1.35
+++ LVM2/lib/label/label.c	2006/11/30 23:11:41	1.36
@@ -115,7 +115,7 @@
 	struct lvmcache_info *info;
 	uint64_t sector;
 	int found = 0;
-	char readbuf[LABEL_SCAN_SIZE];
+	char readbuf[LABEL_SCAN_SIZE] __attribute((aligned(8)));
 
 	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, readbuf)) {
 		log_debug("%s: Failed to read label area", dev_name(dev));
@@ -186,8 +186,8 @@
 /* FIXME Also wipe associated metadata area headers? */
 int label_remove(struct device *dev)
 {
-	char buf[LABEL_SIZE];
-	char readbuf[LABEL_SCAN_SIZE];
+	char buf[LABEL_SIZE] __attribute((aligned(8)));
+	char readbuf[LABEL_SCAN_SIZE] __attribute((aligned(8)));
 	int r = 1;
 	uint64_t sector;
 	int wipe;
@@ -258,7 +258,7 @@
 /* FIXME Avoid repeated re-reading if cache lock held */
 int label_read(struct device *dev, struct label **result)
 {
-	char buf[LABEL_SIZE];
+	char buf[LABEL_SIZE] __attribute((aligned(8)));
 	struct labeller *l;
 	uint64_t sector;
 	struct lvmcache_info *info;
@@ -290,7 +290,7 @@
 /* Caller may need to use label_get_handler to create label struct! */
 int label_write(struct device *dev, struct label *label)
 {
-	char buf[LABEL_SIZE];
+	char buf[LABEL_SIZE] __attribute((aligned(8)));
 	struct label_header *lh = (struct label_header *) buf;
 	int r = 1;
 
@@ -341,7 +341,7 @@
 int label_verify(struct device *dev)
 {
 	struct labeller *l;
-	char buf[LABEL_SIZE];
+	char buf[LABEL_SIZE] __attribute((aligned(8)));
 	uint64_t sector;
 	struct lvmcache_info *info;
 	int r = 0;
--- LVM2/lib/label/label.h	2006/05/09 21:23:50	1.17
+++ LVM2/lib/label/label.h	2006/11/30 23:11:41	1.18
@@ -49,23 +49,23 @@
 	/*
 	 * Is the device labelled with this format ?
 	 */
-	int (*can_handle) (struct labeller * l, char *buf, uint64_t sector);
+	int (*can_handle) (struct labeller * l, void *buf, uint64_t sector);
 
 	/*
 	 * Write a label to a volume.
 	 */
-	int (*write) (struct label * label, char *buf);
+	int (*write) (struct label * label, void *buf);
 
 	/*
 	 * Read a label from a volume.
 	 */
 	int (*read) (struct labeller * l, struct device * dev,
-		     char *buf, struct label ** label);
+		     void *buf, struct label ** label);
 
 	/*
 	 * Additional consistency checks for the paranoid.
 	 */
-	int (*verify) (struct labeller * l, char *buf, uint64_t sector);
+	int (*verify) (struct labeller * l, void *buf, uint64_t sector);
 
 	/*
 	 * Populate label_type etc.
--- LVM2/lib/locking/cluster_locking.c	2006/08/21 12:54:52	1.14
+++ LVM2/lib/locking/cluster_locking.c	2006/11/30 23:11:41	1.15
@@ -94,7 +94,7 @@
 /* Send a request and return the status */
 static int _send_request(char *inbuf, int inlen, char **retbuf)
 {
-	char outbuf[PIPE_BUF];
+	char outbuf[PIPE_BUF] __attribute((aligned(8)));
 	struct clvm_header *outheader = (struct clvm_header *) outbuf;
 	int len;
 	int off;
@@ -195,7 +195,7 @@
 static int _cluster_request(char cmd, const char *node, void *data, int len,
 			   lvm_response_t ** response, int *num)
 {
-	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1];
+	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1] __attribute((aligned(8)));
 	int *outptr;
 	char *inptr;
 	char *retbuf = NULL;
--- LVM2/lib/locking/locking.c	2006/10/14 16:37:54	1.34
+++ LVM2/lib/locking/locking.c	2006/11/30 23:11:41	1.35
@@ -249,7 +249,7 @@
 
 int lock_vol(struct cmd_context *cmd, const char *vol, int flags)
 {
-	char resource[258];
+	char resource[258] __attribute((aligned(8)));
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
--- LVM2/lib/metadata/metadata.c	2006/11/10 18:24:11	1.101
+++ LVM2/lib/metadata/metadata.c	2006/11/30 23:11:42	1.102
@@ -738,7 +738,7 @@
 {
 	struct pv_list *pvl, *pvl2;
 	struct lv_list *lvl, *lvl2;
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 	int r = 1;
 
 	/* FIXME Also check there's no data/metadata overlap */
--- LVM2/tools/pvchange.c	2006/09/02 01:18:17	1.43
+++ LVM2/tools/pvchange.c	2006/11/30 23:11:42	1.44
@@ -29,7 +29,7 @@
 	const char *pv_name = dev_name(pv->dev);
 	const char *tag = NULL;
 	const char *orig_vg_name;
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 
 	int consistent = 1;
 	int allocatable = 0;
--- LVM2/tools/pvscan.c	2006/05/09 21:23:51	1.29
+++ LVM2/tools/pvscan.c	2006/11/30 23:11:42	1.30
@@ -22,7 +22,7 @@
 				   struct physical_volume *pv,
 				   void *handle __attribute((unused)))
 {
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 	unsigned vg_name_len = 0;
 
 	char pv_tmp_name[NAME_LEN] = { 0, };
--- LVM2/tools/vgmerge.c	2006/09/02 01:18:17	1.34
+++ LVM2/tools/vgmerge.c	2006/11/30 23:11:42	1.35
@@ -176,7 +176,7 @@
 	/* Fix up LVIDs */
 	list_iterate_items(lvl1, &vg_to->lvs) {
 		union lvid *lvid1 = &lvl1->lv->lvid;
-		char uuid[64];
+		char uuid[64] __attribute((aligned(8)));
 
 		list_iterate_items(lvl2, &vg_from->lvs) {
 			union lvid *lvid2 = &lvl2->lv->lvid;
--- LVM2/tools/vgreduce.c	2006/09/07 23:23:45	1.53
+++ LVM2/tools/vgreduce.c	2006/11/30 23:11:42	1.54
@@ -18,7 +18,7 @@
 
 static int _remove_pv(struct volume_group *vg, struct pv_list *pvl)
 {
-	char uuid[64];
+	char uuid[64] __attribute((aligned(8)));
 
 	if (vg->pv_count == 1) {
 		log_error("Volume Groups must always contain at least one PV");


