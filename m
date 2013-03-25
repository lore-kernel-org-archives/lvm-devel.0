From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Mar 2013 14:09:46 +0000 (UTC)
Subject: master - pv_write: clean up non-orphan format1 PV write
Message-ID: <20130325140946.865BD142E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32ae07cef1a30064d3269b5e10f2c54f6486c446
Commit:        32ae07cef1a30064d3269b5e10f2c54f6486c446
Parent:        784867d5bd47fce992b6b6e964d9088a652fc0b9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 25 14:30:40 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 25 15:08:26 2013 +0100

pv_write: clean up non-orphan format1 PV write

...to not pollute the common and format-independent code in the
abstraction layer above.

The format1 pv_write has common code for writing metadata and
PV header by calling the "write_disks" fn and when rewriting
the header itself only (e.g. just for the purpose of changing
the PV UUID) during the pvchange operation, we had to tweak
this functionality for the format1 case and we had to assign
the PV the orphan state temporarily.

This patch removes the need for this format1 tweak and it calls
the write_disks with appropriate flag indicating whether this is
a PV write call or a VG write call, allowing for metatada update
for the latter one.

Also, a side effect of the former tweak was that it effectively
invalidated the cache (even for the non-format1 PVs) as we
assigned it the orphan state temporarily just for the format1
PV write to pass.

Also, that tweak made it difficult to directly detect whether
a PV was part of a VG or not because the state was incorrect.

Also, it's not necessary to backup and restore some PV fields
when doing a PV write:

  orig_pe_size = pv_pe_size(pv);
  orig_pe_start = pv_pe_start(pv);
  orig_pe_count = pv_pe_count(pv);
  ...
  pv_write(pv)
  ...
  pv->pe_size = orig_pe_size;
  pv->pe_start = orig_pe_start;
  pv->pe_count = orig_pe_count;

...this is already done by the layer below itself (the _format1_pv_write fn).

So let's have this cleaned up so we don't need to be bothered
about any 'format1 special case for pv_write' anymore.
---
 WHATS_NEW              |    1 +
 lib/format1/disk-rep.c |   14 +++++++-------
 lib/format1/disk-rep.h |    3 ++-
 lib/format1/format1.c  |    4 ++--
 tools/pvchange.c       |   32 ++++----------------------------
 5 files changed, 16 insertions(+), 38 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a35c09b..61a2558 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Clean up format1 PV write to remove a need for an orphan VG for it to pass.
   Fix vgextend to not allow a PV with 0 MDAs to be used while already in a VG.
   Move update_pool_params() from /tools to /lib for better reuse.
   Give precedence to EMC power2 devices with duplicate PVIDs.
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index ce6cda1..19776e0 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -674,7 +674,7 @@ static int _write_pvd(struct disk_list *data)
  * assumes the device has been opened.
  */
 static int __write_all_pvd(const struct format_type *fmt __attribute__((unused)),
-			   struct disk_list *data)
+			   struct disk_list *data, int write_vg_metadata)
 {
 	const char *pv_name = dev_name(data->dev);
 
@@ -685,9 +685,9 @@ static int __write_all_pvd(const struct format_type *fmt __attribute__((unused))
 
 	/* vgcache_add(data->pvd.vg_name, data->vgd.vg_uuid, data->dev, fmt); */
 	/*
-	 * Stop here for orphan pv's.
+	 * Stop here for orphan PVs or if VG metadata write not requested.
 	 */
-	if (data->pvd.vg_name[0] == '\0') {
+	if ((data->pvd.vg_name[0] == '\0') || !write_vg_metadata) {
 		/* if (!test_mode())
 		   vgcache_add(data->pvd.vg_name, NULL, data->dev, fmt); */
 		return 1;
@@ -723,14 +723,14 @@ static int __write_all_pvd(const struct format_type *fmt __attribute__((unused))
 /*
  * opens the device and hands to the above fn.
  */
-static int _write_all_pvd(const struct format_type *fmt, struct disk_list *data)
+static int _write_all_pvd(const struct format_type *fmt, struct disk_list *data, int write_vg_metadata)
 {
 	int r;
 
 	if (!dev_open(data->dev))
 		return_0;
 
-	r = __write_all_pvd(fmt, data);
+	r = __write_all_pvd(fmt, data, write_vg_metadata);
 
 	if (!dev_close(data->dev))
 		stack;
@@ -743,12 +743,12 @@ static int _write_all_pvd(const struct format_type *fmt, struct disk_list *data)
  * little sanity checking, so make sure correct
  * data is passed to here.
  */
-int write_disks(const struct format_type *fmt, struct dm_list *pvs)
+int write_disks(const struct format_type *fmt, struct dm_list *pvs, int write_vg_metadata)
 {
 	struct disk_list *dl;
 
 	dm_list_iterate_items(dl, pvs) {
-		if (!(_write_all_pvd(fmt, dl)))
+		if (!(_write_all_pvd(fmt, dl, write_vg_metadata)))
 			return_0;
 
 		log_very_verbose("Successfully wrote data to %s",
diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 0d54438..52ee303 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -197,7 +197,8 @@ int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
 		   struct dev_filter *filter,
 		   struct dm_pool *mem, struct dm_list *results);
 
-int write_disks(const struct format_type *fmt, struct dm_list *pvds);
+int write_disks(const struct format_type *fmt, struct dm_list *pvds,
+		int write_vg_metadata);
 
 /*
  * Functions to translate to between disk and in
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index f3945bc..f47ed95 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -299,7 +299,7 @@ static int _format1_vg_write(struct format_instance *fid, struct volume_group *v
 
 	r = (_flatten_vg(fid, mem, vg, &pvds, fid->fmt->cmd->dev_dir,
 			 fid->fmt->cmd->filter) &&
-	     write_disks(fid->fmt, &pvds));
+	     write_disks(fid->fmt, &pvds, 1));
 
 	lvmcache_update_vg(vg, 0);
 	dm_pool_destroy(mem);
@@ -458,7 +458,7 @@ static int _format1_pv_write(const struct format_type *fmt, struct physical_volu
 	dl->pvd.pe_on_disk.base = LVM1_PE_ALIGN << SECTOR_SHIFT;
 
 	dm_list_add(&pvs, &dl->list);
-	if (!write_disks(fmt, &pvs))
+	if (!write_disks(fmt, &pvs, 0))
 		goto_bad;
 
 	goto out;
diff --git a/tools/pvchange.c b/tools/pvchange.c
index c282ec0..1458e92 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -19,13 +19,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
 			    void *handle __attribute__((unused)))
 {
-	uint32_t orig_pe_alloc_count;
-	/* FIXME Next three only required for format1. */
-	uint32_t orig_pe_count, orig_pe_size;
-	uint64_t orig_pe_start;
-
 	const char *pv_name = pv_dev_name(pv);
-	const char *orig_vg_name;
 	char uuid[64] __attribute__((aligned(8)));
 
 	int allocatable = 0;
@@ -129,28 +123,10 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
 			return 0;
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
-		if (!is_orphan(pv)) {
-			orig_vg_name = pv_vg_name(pv);
-			orig_pe_alloc_count = pv_pe_alloc_count(pv);
-
-			/* FIXME format1 pv_write doesn't preserve these. */
-			orig_pe_size = pv_pe_size(pv);
-			orig_pe_start = pv_pe_start(pv);
-			orig_pe_count = pv_pe_count(pv);
-
-			pv->vg_name = pv->fmt->orphan_vg_name;
-			pv->pe_alloc_count = 0;
-			if (!(pv_write(cmd, pv, 0))) {
-				log_error("pv_write with new uuid failed "
-					  "for %s.", pv_name);
-				return 0;
-			}
-			pv->vg_name = orig_vg_name;
-			pv->pe_alloc_count = orig_pe_alloc_count;
-
-			pv->pe_size = orig_pe_size;
-			pv->pe_start = orig_pe_start;
-			pv->pe_count = orig_pe_count;
+		if (!is_orphan(pv) && (!pv_write(cmd, pv, 1))) {
+			log_error("pv_write with new uuid failed "
+				  "for %s.", pv_name);
+			return 0;
 		}
 	}
 


