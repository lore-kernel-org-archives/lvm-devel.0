From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 18 Oct 2017 14:32:28 -0400
Subject: master - liblvm: Move lib code used exclusively into metadata-liblvm.c
Message-ID: <201710181832.v9IIWS17023264@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3ae99dcc0b73f5551c08a3e0af8a17b4448ac50
Commit:        f3ae99dcc0b73f5551c08a3e0af8a17b4448ac50
Parent:        f1cc5b12fd80c3c62247fccfb2e5537aef27533d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Oct 18 19:29:32 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Oct 18 19:29:32 2017 +0100

liblvm: Move lib code used exclusively into metadata-liblvm.c

Also remove some redundant function definitions from metadata.h.
---
 WHATS_NEW                        |    1 +
 lib/Makefile.in                  |    1 +
 lib/metadata/metadata-exported.h |    6 +-
 lib/metadata/metadata-liblvm.c   |  701 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata.c          |  494 +--------------------------
 lib/metadata/metadata.h          |   17 +-
 lib/metadata/pv_manip.c          |  176 ----------
 liblvm/lvm_lv.c                  |    2 +-
 liblvm/lvm_pv.c                  |    2 +-
 9 files changed, 727 insertions(+), 673 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 665517b..8ee5b0c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Move lib code used only by liblvm into metadata-liblvm.c.
   Distinguish between device not found and excluded by filter.
   Monitor external origin LVs.
   Remove the replicator code, including configure --with-replicators.
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 7e9fa91..1fdaca8 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -96,6 +96,7 @@ SOURCES =\
 	metadata/lv_manip.c \
 	metadata/merge.c \
 	metadata/metadata.c \
+	metadata/metadata-liblvm.c \
 	metadata/mirror.c \
 	metadata/pool_manip.c \
 	metadata/pv.c \
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index cd6e92a..85e5838 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -688,9 +688,9 @@ uint32_t vg_read_error(struct volume_group *vg_handle);
 struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  struct device *dev, struct pv_create_args *pva);
 
-int pvremove_single(struct cmd_context *cmd, const char *pv_name,
-		    void *handle __attribute__((unused)), unsigned force_count,
-		    unsigned prompt, struct dm_list *pvslist);
+struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
+				     struct pvcreate_params *pp, int write_now);
+
 int pvremove_many(struct cmd_context *cmd, struct dm_list *pv_names,
 		  unsigned force_count, unsigned prompt);
 
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
new file mode 100644
index 0000000..f37008d
--- /dev/null
+++ b/lib/metadata/metadata-liblvm.c
@@ -0,0 +1,701 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
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
+/*
+ * This file contains functions now used only by liblvm.
+ * Ideally this file should be empty as liblvm and toollib should be doing identical things.
+ * FIXME Merge all the code into different parts of the tree.
+ */
+#include "lib.h"
+#include "toolcontext.h"
+#include "lvm-string.h"
+#include "metadata.h"
+#include "label.h"
+#include "lvm-signal.h"
+#include "lvmcache.h"
+#include "lvmetad.h"
+
+int vg_reduce(struct volume_group *vg, const char *pv_name)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+
+	if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+		log_error("Physical volume %s not in volume group %s.",
+			  pv_name, vg->name);
+		return 0;
+	}
+
+	pv = pvl->pv;
+
+	if (vgreduce_single(vg->cmd, vg, pv, 0)) {
+		dm_list_add(&vg->removed_pvs, &pvl->list);
+		return 1;
+	}
+
+	log_error("Unable to remove physical volume '%s' from "
+		  "volume group '%s'.", pv_name, vg->name);
+
+	return 0;
+}
+
+static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
+{
+	struct physical_volume *pv = pvw->pv;
+	struct device *dev = pv->dev;
+	const char *pv_name = dev_name(dev);
+
+	if (pvw->new_pv) {
+		/* Wipe existing label first */
+		if (!label_remove(pv_dev(pv))) {
+			log_error("Failed to wipe existing label on %s", pv_name);
+			return 0;
+		}
+
+		if (pvw->pp->zero) {
+			log_verbose("Zeroing start of device %s", pv_name);
+			if (!dev_open_quiet(dev)) {
+				log_error("%s not opened: device not zeroed", pv_name);
+				return 0;
+			}
+
+			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
+				log_error("%s not wiped: aborting", pv_name);
+				if (!dev_close(dev))
+					stack;
+				return 0;
+			}
+			if (!dev_close(dev))
+				stack;
+		}
+	}
+
+	log_verbose("Writing physical volume data to disk \"%s\"",
+		    pv_name);
+
+	if (!(pv_write(cmd, pv, 1))) {
+		log_error("Failed to write physical volume \"%s\"", pv_name);
+		return 0;
+	}
+
+	if (pvw->new_pv)
+		log_print_unless_silent("Physical volume \"%s\" successfully created", pv_name);
+	else
+		log_verbose("Physical volume \"%s\" successfully written", pv_name);
+
+	return 1;
+}
+
+static int _verify_pv_create_params(struct pvcreate_params *pp)
+{
+	/*
+	 * FIXME: Some of these checks are duplicates in pvcreate_params_validate.
+	 */
+	if (pp->pva.pvmetadatacopies > 2) {
+		log_error("Metadatacopies may only be 0, 1 or 2");
+		return 0;
+	}
+
+	if (pp->pva.data_alignment > UINT32_MAX) {
+		log_error("Physical volume data alignment is too big.");
+		return 0;
+	}
+
+	if (pp->pva.data_alignment_offset > UINT32_MAX) {
+		log_error("Physical volume data alignment offset is too big.");
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * See if we may pvcreate on this device.
+ * 0 indicates we may not.
+ */
+static int _pvcreate_check(struct cmd_context *cmd, const char *name,
+			   struct pvcreate_params *pp, int *wiped)
+{
+	static const char really_init_msg[] = "Really INITIALIZE physical volume";
+	static const char not_init_msg[] = "physical volume not initialized";
+	struct physical_volume *pv;
+	struct device *dev;
+	int r = 0;
+	int scan_needed = 0;
+	int filter_refresh_needed = 0;
+	int used;
+
+	/* FIXME Check partition type is LVM unless --force is given */
+
+	*wiped = 0;
+
+	/* Is there a pv here already? */
+	pv = find_pv_by_name(cmd, name, 1, 1);
+
+	/* Allow partial & exported VGs to be destroyed. */
+	/* We must have -ff to overwrite a non orphan */
+	if (pv) {
+		if (!is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
+			log_error("Can't initialize physical volume \"%s\" of "
+				  "volume group \"%s\" without -ff.", name, pv_vg_name(pv));
+			goto out;
+		}
+
+		if ((used = is_used_pv(pv)) < 0)
+			goto_out;
+
+		if (used && pp->force != DONT_PROMPT_OVERRIDE) {
+			log_error("PV %s is used by a VG but its metadata is missing.", name);
+			log_error("Can't initialize PV '%s' without -ff.", name);
+			goto out;
+		}
+	}
+
+	/* prompt */
+	if (pv && !pp->yes) {
+		if (is_orphan(pv)) {
+			if (used) {
+				if (yes_no_prompt("%s \"%s\" that is marked as belonging to a VG [y/n]? ",
+						  really_init_msg, name) == 'n') {
+					log_error("%s: %s", name, not_init_msg);
+					goto out;
+				}
+			}
+		} else {
+			if (yes_no_prompt("%s \"%s\" of volume group \"%s\" [y/n]? ",
+					  really_init_msg, name, pv_vg_name(pv)) == 'n') {
+				log_error("%s: %s", name, not_init_msg);
+				goto out;
+			}
+		}
+	}
+
+	if (sigint_caught())
+		goto_out;
+
+	dev = dev_cache_get(name, cmd->full_filter);
+
+	/*
+	 * Refresh+rescan at the end is needed if:
+	 *   - we don't obtain device list from udev,
+	 *     hence persistent cache file is used
+	 *     and we need to trash it and reevaluate
+	 *     for any changes done outside - adding
+	 *     any new foreign signature which may affect
+	 *     filtering - before we do pvcreate, we
+	 *     need to be sure that we have up-to-date
+	 *     view for filters
+	 *
+	 *   - we have wiped existing foreign signatures
+	 *     from dev as this may affect what's filtered
+	 *     as well
+	 *
+	 *
+	 * Only rescan at the end is needed if:
+	 *   - we've just checked whether dev is fileterd
+	 *     by MD filter. We do the refresh in-situ,
+	 *     so no need to require the refresh at the
+	 *     end of this fn. This is to allow for
+	 *     wiping MD signature during pvcreate for
+	 *     the dev - the dev would normally be
+	 *     filtered because of MD filter.
+	 *     This is an exception.
+	 */
+
+	/* Is there an md superblock here? */
+	if (!dev && md_filtering()) {
+		if (!refresh_filters(cmd))
+			goto_out;
+
+		init_md_filtering(0);
+		dev = dev_cache_get(name, cmd->full_filter);
+		init_md_filtering(1);
+
+		scan_needed = 1;
+	} else if (!obtain_device_list_from_udev())
+		filter_refresh_needed = scan_needed = 1;
+
+	if (!dev) {
+		log_error("Device %s not found (or ignored by filtering).", name);
+		goto out;
+	}
+
+	/*
+	 * This test will fail if the device belongs to an MD array.
+	 */
+	if (!dev_test_excl(dev)) {
+		/* FIXME Detect whether device-mapper itself is still using it */
+		log_error("Can't open %s exclusively.  Mounted filesystem?",
+			  name);
+		goto out;
+	}
+
+	if (!wipe_known_signatures(cmd, dev, name,
+				   TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
+				   0, pp->yes, pp->force, wiped)) {
+		log_error("Aborting pvcreate on %s.", name);
+		goto out;
+	}
+
+	if (*wiped)
+		filter_refresh_needed = scan_needed = 1;
+
+	if (sigint_caught())
+		goto_out;
+
+	if (pv && !is_orphan(pv) && pp->force)
+		log_warn("WARNING: Forcing physical volume creation on "
+			  "%s%s%s%s", name,
+			  !is_orphan(pv) ? " of volume group \"" : "",
+			  pv_vg_name(pv),
+			  !is_orphan(pv) ? "\"" : "");
+
+	r = 1;
+
+out:
+	if (filter_refresh_needed)
+		if (!refresh_filters(cmd)) {
+			stack;
+			r = 0;
+		}
+
+	if (scan_needed) {
+		lvmcache_force_next_label_scan();
+		if (!lvmcache_label_scan(cmd)) {
+			stack;
+			r = 0;
+		}
+	}
+
+	free_pv_fid(pv);
+	return r;
+}
+
+/*
+ * pvcreate_vol() - initialize a device with PV label and metadata area
+ *
+ * Parameters:
+ * - pv_name: device path to initialize
+ * - pp: parameters to pass to pv_create; if NULL, use default values
+ *
+ * Returns:
+ * NULL: error
+ * struct physical_volume * (non-NULL): handle to physical volume created
+ */
+struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
+				     struct pvcreate_params *pp, int write_now)
+{
+	struct physical_volume *pv = NULL;
+	struct device *dev;
+	int wiped = 0;
+	struct dm_list mdas;
+	struct pvcreate_params default_pp;
+	char buffer[64] __attribute__((aligned(8)));
+	dev_ext_t dev_ext_src;
+
+	pvcreate_params_set_defaults(&default_pp);
+	if (!pp)
+		pp = &default_pp;
+
+	if (!_verify_pv_create_params(pp)) {
+		goto bad;
+	}
+
+	if (pp->pva.idp) {
+		if ((dev = lvmcache_device_from_pvid(cmd, pp->pva.idp, NULL, NULL)) &&
+		    (dev != dev_cache_get(pv_name, cmd->full_filter))) {
+			if (!id_write_format((const struct id*)&pp->pva.idp->uuid,
+			    buffer, sizeof(buffer)))
+				goto_bad;
+			log_error("uuid %s already in use on \"%s\"", buffer,
+				  dev_name(dev));
+			goto bad;
+		}
+	}
+
+	if (!_pvcreate_check(cmd, pv_name, pp, &wiped))
+		goto_bad;
+
+	if (sigint_caught())
+		goto_bad;
+
+	/*
+	 * wipe_known_signatures called in _pvcreate_check fires
+	 * WATCH event to update udev database. But at the moment,
+	 * we have no way to synchronize with such event - we may
+	 * end up still seeing the old info in udev db and pvcreate
+	 * can fail to proceed because of the device still being
+	 * filtered (because of the stale info in udev db).
+	 * Disable udev dev-ext source temporarily here for
+	 * this reason and rescan with DEV_EXT_NONE dev-ext
+	 * source (so filters use DEV_EXT_NONE source).
+	 */
+	dev_ext_src = external_device_info_source();
+	if (wiped && (dev_ext_src == DEV_EXT_UDEV))
+		init_external_device_info_source(DEV_EXT_NONE);
+
+	dev = dev_cache_get(pv_name, cmd->full_filter);
+
+	init_external_device_info_source(dev_ext_src);
+
+	if (!dev) {
+		log_error("%s: Couldn't find device.  Check your filters?",
+			  pv_name);
+		goto bad;
+	}
+
+	dm_list_init(&mdas);
+
+	if (!(pv = pv_create(cmd, dev, &pp->pva))) {
+		log_error("Failed to setup physical volume \"%s\"", pv_name);
+		goto bad;
+	}
+
+	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
+		    " available sectors", pv_name, pv_size(pv));
+
+	pv->status |= UNLABELLED_PV;
+	if (write_now) {
+		struct pv_to_write pvw;
+		pvw.pp = pp;
+		pvw.pv = pv;
+		pvw.new_pv = 1;
+		if (!_pvcreate_write(cmd, &pvw))
+			goto bad;
+	}
+
+	return pv;
+
+bad:
+	return NULL;
+}
+
+/*
+ * Extend a VG by a single PV / device path
+ *
+ * Parameters:
+ * - vg: handle of volume group to extend by 'pv_name'
+ * - pv_name: device path of PV to add to VG
+ * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
+ * - max_phys_block_size: largest physical block size found amongst PVs in a VG
+ *
+ */
+static int _vg_extend_single_pv(struct volume_group *vg, char *pv_name,
+				struct pvcreate_params *pp,
+				unsigned int *max_phys_block_size)
+{
+	struct physical_volume *pv;
+	struct pv_to_write *pvw;
+	int new_pv = 0;
+
+	pv = find_pv_by_name(vg->cmd, pv_name, 1, 1);
+
+	if (!pv && !pp) {
+		log_error("%s not identified as an existing "
+			  "physical volume", pv_name);
+		return 0;
+	}
+
+	if (!pv && pp) {
+		if (!(pv = pvcreate_vol(vg->cmd, pv_name, pp, 0)))
+			return_0;
+		new_pv = 1;
+	}
+
+	if (!(check_dev_block_size_for_vg(pv->dev, (const struct volume_group *) vg,
+					  max_phys_block_size)))
+		goto_bad;
+
+	if (!add_pv_to_vg(vg, pv_name, pv, new_pv))
+		goto_bad;
+
+	if ((pv->fmt->features & FMT_PV_FLAGS) ||
+	    (pv->status & UNLABELLED_PV)) {
+		if (!(pvw = dm_pool_zalloc(vg->vgmem, sizeof(*pvw)))) {
+			log_error("pv_to_write allocation for '%s' failed", pv_name);
+			return 0;
+		}
+		pvw->pv = pv;
+		pvw->pp = new_pv ? pp : NULL;
+		pvw->new_pv = new_pv;
+		dm_list_add(&vg->pvs_to_write, &pvw->list);
+	}
+
+	return 1;
+bad:
+	free_pv_fid(pv);
+	return 0;
+}
+
+/*
+ * Extend a VG by a single PV / device path
+ *
+ * Parameters:
+ * - vg: handle of volume group to extend by 'pv_name'
+ * - pv_count: count of device paths of PVs
+ * - pv_names: device paths of PVs to add to VG
+ * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
+ *
+ */
+int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
+	      struct pvcreate_params *pp)
+{
+	int i;
+	char *pv_name;
+	unsigned int max_phys_block_size = 0;
+
+	if (vg_bad_status_bits(vg, RESIZEABLE_VG))
+		return_0;
+
+	/* attach each pv */
+	for (i = 0; i < pv_count; i++) {
+		if (!(pv_name = dm_strdup(pv_names[i]))) {
+			log_error("Failed to duplicate pv name %s.", pv_names[i]);
+			return 0;
+		}
+		dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
+		if (!_vg_extend_single_pv(vg, pv_name, pp, &max_phys_block_size)) {
+			log_error("Unable to add physical volume '%s' to "
+				  "volume group '%s'.", pv_name, vg->name);
+			dm_free(pv_name);
+			return 0;
+		}
+		dm_free(pv_name);
+	}
+
+	(void) check_pv_dev_sizes(vg);
+
+/* FIXME Decide whether to initialise and add new mdahs to format instance */
+
+	return 1;
+}
+
+/*
+ * Decide whether it is "safe" to wipe the labels on this device.
+ * 0 indicates we may not.
+ */
+static int _pvremove_check(struct cmd_context *cmd, const char *name,
+			   unsigned force_count, unsigned prompt, struct dm_list *pvslist)
+{
+	static const char really_wipe_msg[] = "Really WIPE LABELS from physical volume";
+	struct device *dev;
+	struct label *label;
+	struct pv_list *pvl;
+	struct physical_volume *pv = NULL;
+	int used;
+	int r = 0;
+
+	/* FIXME Check partition type is LVM unless --force is given */
+
+	if (!(dev = dev_cache_get(name, cmd->filter))) {
+		log_error("Device %s not found.", name);
+		return 0;
+	}
+
+	/* Is there a pv here already? */
+	/* If not, this is an error unless you used -f. */
+	if (!label_read(dev, &label, 0)) {
+		if (force_count)
+			return 1;
+		log_error("No PV label found on %s.", name);
+		return 0;
+	}
+
+	dm_list_iterate_items(pvl, pvslist)
+		if (pvl->pv->dev == dev)
+			pv = pvl->pv;
+
+	if (!pv) {
+		log_error(INTERNAL_ERROR "Physical Volume %s has a label, "
+			  "but is neither in a VG nor orphan.", name);
+		goto out; /* better safe than sorry */
+	}
+
+	if (is_orphan(pv)) {
+		if ((used = is_used_pv(pv)) < 0)
+			goto_out;
+
+		if (used) {
+			log_warn("WARNING: PV %s is used by a VG but its metadata is missing.", name);
+
+			if (force_count < 2)
+				goto_bad;
+
+			if (!prompt &&
+			    yes_no_prompt("%s \"%s\" that is marked as belonging to a VG [y/n]? ",
+					  really_wipe_msg, name) == 'n')
+				goto_bad;
+		}
+	} else {
+		log_warn("WARNING: PV %s is used by VG %s (consider using vgreduce).", name, pv_vg_name(pv));
+
+		if (force_count < 2)
+			goto_bad;
+
+		if (!prompt &&
+		    yes_no_prompt("%s \"%s\" of volume group \"%s\" [y/n]? ",
+				  really_wipe_msg, name, pv_vg_name(pv)) == 'n')
+			goto_bad;
+	}
+
+	if (force_count)
+		log_warn("WARNING: Wiping physical volume label from "
+			 "%s%s%s%s", name,
+			 !is_orphan(pv) ? " of volume group \"" : "",
+			 pv_vg_name(pv),
+			 !is_orphan(pv) ? "\"" : "");
+
+	r = 1;
+bad:
+	if (!r) {
+		log_error("%s: physical volume label not removed.", name);
+
+		if (force_count < 2) /* Show hint as log_error() */
+			log_error("(If you are certain you need pvremove, "
+				  "then confirm by using --force twice.)");
+	}
+out:
+	return r;
+}
+
+static int _pvremove_single(struct cmd_context *cmd, const char *pv_name,
+			    void *handle __attribute__((unused)), unsigned force_count,
+			    unsigned prompt, struct dm_list *pvslist)
+{
+	struct device *dev;
+	struct lvmcache_info *info;
+	int r = 0;
+
+	if (!_pvremove_check(cmd, pv_name, force_count, prompt, pvslist))
+		goto out;
+
+	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
+		log_error("%s: Couldn't find device.  Check your filters?",
+			  pv_name);
+		goto out;
+	}
+
+	info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
+
+	if (!dev_test_excl(dev)) {
+		/* FIXME Detect whether device-mapper is still using the device */
+		log_error("Can't open %s exclusively - not removing. "
+			  "Mounted filesystem?", dev_name(dev));
+		goto out;
+	}
+
+	/* Wipe existing label(s) */
+	if (!label_remove(dev)) {
+		log_error("Failed to wipe existing label(s) on %s", pv_name);
+		goto out;
+	}
+
+	if (info)
+		lvmcache_del(info);
+
+	if (!lvmetad_pv_gone_by_dev(dev))
+		goto_out;
+
+	log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
+				pv_name);
+
+	r = 1;
+
+out:
+	return r;
+}
+
+int pvremove_many(struct cmd_context *cmd, struct dm_list *pv_names,
+		  unsigned force_count, unsigned prompt)
+{
+	int ret = 1;
+	struct dm_list *pvslist = NULL;
+	struct pv_list *pvl;
+	const struct dm_str_list *pv_name;
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
+	if (!(pvslist = get_pvs(cmd))) {
+		ret = 0;
+		goto_out;
+	}
+
+	dm_list_iterate_items(pv_name, pv_names) {
+		if (!_pvremove_single(cmd, pv_name->str, NULL, force_count, prompt, pvslist)) {
+			stack;
+			ret = 0;
+		}
+		if (sigint_caught()) {
+			ret = 0;
+			goto_out;
+		}
+	}
+
+out:
+	unlock_vg(cmd, NULL, VG_ORPHANS);
+
+	if (pvslist)
+		dm_list_iterate_items(pvl, pvslist)
+			free_pv_fid(pvl->pv);
+
+	return ret;
+}
+
+/* FIXME: liblvm todo - make into function that returns handle */
+struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
+					const char *pv_name,
+					int allow_orphan, int allow_unformatted)
+{
+	struct device *dev;
+	struct pv_list *pvl;
+	struct dm_list *pvslist;
+	struct physical_volume *pv = NULL;
+
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
+	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
+		if (!allow_unformatted)
+			log_error("Physical volume %s not found", pv_name);
+		return_NULL;
+	}
+
+	if (!(pvslist = get_pvs(cmd)))
+		return_NULL;
+
+	dm_list_iterate_items(pvl, pvslist)
+		if (pvl->pv->dev == dev)
+			pv = pvl->pv;
+		else
+			free_pv_fid(pvl->pv);
+
+	if (!pv && !allow_unformatted)
+		log_error("Physical volume %s not found", pv_name);
+
+	if (pv && !allow_orphan && is_orphan_vg(pv->vg_name)) {
+		log_error("Physical volume %s not in a volume group", pv_name);
+		goto bad;
+	}
+
+	return pv;
+
+bad:
+	free_pv_fid(pv);
+	return NULL;
+}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 15e08e6..bcc23bc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -44,9 +44,6 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct format_instance *fid,
 					uint32_t warn_flags, int scan_label_only);
 
-static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
-				    uint64_t status);
-
 static int _alignment_overrides_default(unsigned long data_alignment,
 					unsigned long default_pe_align)
 {
@@ -177,8 +174,8 @@ void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
  *  1 - success
  * FIXME: remove pv_name - obtain safely from pv
  */
-static int _add_pv_to_vg(struct volume_group *vg, const char *pv_name,
-		         struct physical_volume *pv, int new_pv)
+int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
+		 struct physical_volume *pv, int new_pv)
 {
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
@@ -387,8 +384,8 @@ static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 		return 0;
 	}
 
-	if (_vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
-	    _vg_bad_status_bits(vg_to, RESIZEABLE_VG))
+	if (vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
+	    vg_bad_status_bits(vg_to, RESIZEABLE_VG))
 		return 0;
 
 	del_pvl_from_vgs(vg_from, pvl);
@@ -427,8 +424,8 @@ int move_pvs_used_by_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
-	if (_vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
-	    _vg_bad_status_bits(vg_to, RESIZEABLE_VG))
+	if (vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
+	    vg_bad_status_bits(vg_to, RESIZEABLE_VG))
 		return 0;
 
 	dm_list_iterate_items(lvseg, &lvl->lv->segments) {
@@ -675,7 +672,7 @@ int vg_check_pv_dev_block_sizes(const struct volume_group *vg)
 	return 1;
 }
 
-static int _check_pv_dev_sizes(struct volume_group *vg)
+int check_pv_dev_sizes(struct volume_group *vg)
 {
 	struct pv_list *pvl;
 	uint64_t dev_size, size;
@@ -711,124 +708,15 @@ static int _check_pv_dev_sizes(struct volume_group *vg)
 }
 
 /*
- * Extend a VG by a single PV / device path
- *
- * Parameters:
- * - vg: handle of volume group to extend by 'pv_name'
- * - pv_name: device path of PV to add to VG
- * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
- * - max_phys_block_size: largest physical block size found amongst PVs in a VG
- *
- */
-static int _vg_extend_single_pv(struct volume_group *vg, char *pv_name,
-			        struct pvcreate_params *pp,
-			        unsigned int *max_phys_block_size)
-{
-	struct physical_volume *pv;
-	struct pv_to_write *pvw;
-	int new_pv = 0;
-
-	pv = find_pv_by_name(vg->cmd, pv_name, 1, 1);
-
-	if (!pv && !pp) {
-		log_error("%s not identified as an existing "
-			  "physical volume", pv_name);
-		return 0;
-	}
-
-	if (!pv && pp) {
-		if (!(pv = pvcreate_vol(vg->cmd, pv_name, pp, 0)))
-			return_0;
-		new_pv = 1;
-	}
-
-	if (!(check_dev_block_size_for_vg(pv->dev, (const struct volume_group *) vg,
-					  max_phys_block_size)))
-		goto_bad;
-
-	if (!_add_pv_to_vg(vg, pv_name, pv, new_pv))
-		goto_bad;
-
-	if ((pv->fmt->features & FMT_PV_FLAGS) ||
-	    (pv->status & UNLABELLED_PV)) {
-		if (!(pvw = dm_pool_zalloc(vg->vgmem, sizeof(*pvw)))) {
-			log_error("pv_to_write allocation for '%s' failed", pv_name);
-			return 0;
-		}
-		pvw->pv = pv;
-		pvw->pp = new_pv ? pp : NULL;
-		pvw->new_pv = new_pv;
-		dm_list_add(&vg->pvs_to_write, &pvw->list);
-	}
-
-	return 1;
-bad:
-	free_pv_fid(pv);
-	return 0;
-}
-
-/*
  * FIXME: commands shifting to common code in toollib have left a large
  * amount of code only used by liblvm.  Either remove this by shifting
  * liblvm to use toollib, or isolate all this code into a liblvm-specific
  * source file.  All the following and more are only used by liblvm:
  *
- * . vg_extend()
- * . _vg_extend_single_pv()
- * . pvcreate_vol()
- * . _pvcreate_check()
- * . _pvcreate_write()
- * . pvremove_many()
- * . pvremove_single()
- * . find_pv_by_name()
  * . get_pvs()
  * . the vg->pvs_to_write list and pv_to_write struct
- * . vg_reduce()
  */
 
-/*
- * Extend a VG by a single PV / device path
- *
- * Parameters:
- * - vg: handle of volume group to extend by 'pv_name'
- * - pv_count: count of device paths of PVs
- * - pv_names: device paths of PVs to add to VG
- * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
- *
- */
-int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
-	      struct pvcreate_params *pp)
-{
-	int i;
-	char *pv_name;
-	unsigned int max_phys_block_size = 0;
-
-	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
-		return_0;
-
-	/* attach each pv */
-	for (i = 0; i < pv_count; i++) {
-		if (!(pv_name = dm_strdup(pv_names[i]))) {
-			log_error("Failed to duplicate pv name %s.", pv_names[i]);
-			return 0;
-		}
-		dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
-		if (!_vg_extend_single_pv(vg, pv_name, pp, &max_phys_block_size)) {
-			log_error("Unable to add physical volume '%s' to "
-				  "volume group '%s'.", pv_name, vg->name);
-			dm_free(pv_name);
-			return 0;
-		}
-		dm_free(pv_name);
-	}
-
-	(void) _check_pv_dev_sizes(vg);
-
-/* FIXME Decide whether to initialise and add new mdahs to format instance */
-
-	return 1;
-}
-
 int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 {
 	struct pv_list *pvl;
@@ -836,7 +724,7 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 
 	log_debug_metadata("Adding PVs to VG %s.", vg->name);
 
-	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
+	if (vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return_0;
 
 	dm_list_iterate_items(pvl, &pp->pvs) {
@@ -849,44 +737,20 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 			return 0;
 		}
 
-		if (!_add_pv_to_vg(vg, pv_dev_name(pvl->pv), pvl->pv, 0)) {
+		if (!add_pv_to_vg(vg, pv_dev_name(pvl->pv), pvl->pv, 0)) {
 			log_error("PV %s cannot be added to VG %s.",
 				  pv_dev_name(pvl->pv), vg->name);
 			return 0;
 		}
 	}
 
-	(void) _check_pv_dev_sizes(vg);
+	(void) check_pv_dev_sizes(vg);
 
 	dm_list_splice(&vg->pv_write_list, &pp->pvs);
 
 	return 1;
 }
 
-int vg_reduce(struct volume_group *vg, const char *pv_name)
-{
-	struct physical_volume *pv;
-	struct pv_list *pvl;
-
-	if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-		log_error("Physical volume %s not in volume group %s.",
-			  pv_name, vg->name);
-		return 0;
-	}
-
-	pv = pvl->pv;
-
-	if (vgreduce_single(vg->cmd, vg, pv, 0)) {
-		dm_list_add(&vg->removed_pvs, &pvl->list);
-		return 1;
-	}
-
-	log_error("Unable to remove physical volume '%s' from "
-		  "volume group '%s'.", pv_name, vg->name);
-
-	return 0;
-}
-
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
 {
 	char *tag_new;
@@ -1573,168 +1437,6 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 	dm_list_init(&pp->pvs);
 }
 
-/*
- * See if we may pvcreate on this device.
- * 0 indicates we may not.
- */
-static int _pvcreate_check(struct cmd_context *cmd, const char *name,
-			   struct pvcreate_params *pp, int *wiped)
-{
-	static const char really_init_msg[] = "Really INITIALIZE physical volume";
-	static const char not_init_msg[] = "physical volume not initialized";
-	struct physical_volume *pv;
-	struct device *dev;
-	int r = 0;
-	int scan_needed = 0;
-	int filter_refresh_needed = 0;
-	int used;
-
-	/* FIXME Check partition type is LVM unless --force is given */
-
-	*wiped = 0;
-
-	/* Is there a pv here already? */
-	pv = find_pv_by_name(cmd, name, 1, 1);
-
-	/* Allow partial & exported VGs to be destroyed. */
-	/* We must have -ff to overwrite a non orphan */
-	if (pv) {
-		if (!is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
-			log_error("Can't initialize physical volume \"%s\" of "
-				  "volume group \"%s\" without -ff.", name, pv_vg_name(pv));
-			goto out;
-		}
-
-		if ((used = is_used_pv(pv)) < 0)
-			goto_out;
-
-		if (used && pp->force != DONT_PROMPT_OVERRIDE) {
-			log_error("PV %s is used by a VG but its metadata is missing.", name);
-			log_error("Can't initialize PV '%s' without -ff.", name);
-			goto out;
-		}
-	}
-
-	/* prompt */
-	if (pv && !pp->yes) {
-		if (is_orphan(pv)) {
-			if (used) {
-				if (yes_no_prompt("%s \"%s\" that is marked as belonging to a VG [y/n]? ",
-						  really_init_msg, name) == 'n') {
-					log_error("%s: %s", name, not_init_msg);
-					goto out;
-				}
-			}
-		} else {
-			if (yes_no_prompt("%s \"%s\" of volume group \"%s\" [y/n]? ",
-					  really_init_msg, name, pv_vg_name(pv)) == 'n') {
-				log_error("%s: %s", name, not_init_msg);
-				goto out;
-			}
-		}
-	}
-
-	if (sigint_caught())
-		goto_out;
-
-	dev = dev_cache_get(name, cmd->full_filter);
-
-	/*
-	 * Refresh+rescan at the end is needed if:
-	 *   - we don't obtain device list from udev,
-	 *     hence persistent cache file is used
-	 *     and we need to trash it and reevaluate
-	 *     for any changes done outside - adding
-	 *     any new foreign signature which may affect
-	 *     filtering - before we do pvcreate, we
-	 *     need to be sure that we have up-to-date
-	 *     view for filters
-	 *
-	 *   - we have wiped existing foreign signatures
-	 *     from dev as this may affect what's filtered
-	 *     as well
-	 *
-	 *
-	 * Only rescan at the end is needed if:
-	 *   - we've just checked whether dev is fileterd
-	 *     by MD filter. We do the refresh in-situ,
-	 *     so no need to require the refresh at the
-	 *     end of this fn. This is to allow for
-	 *     wiping MD signature during pvcreate for
-	 *     the dev - the dev would normally be
-	 *     filtered because of MD filter.
-	 *     This is an exception.
-	 */
-
-	/* Is there an md superblock here? */
-	if (!dev && md_filtering()) {
-		if (!refresh_filters(cmd))
-			goto_out;
-
-		init_md_filtering(0);
-		dev = dev_cache_get(name, cmd->full_filter);
-		init_md_filtering(1);
-
-		scan_needed = 1;
-	} else if (!obtain_device_list_from_udev())
-		filter_refresh_needed = scan_needed = 1;
-
-	if (!dev) {
-		log_error("Device %s not found (or ignored by filtering).", name);
-		goto out;
-	}
-
-	/*
-	 * This test will fail if the device belongs to an MD array.
-	 */
-	if (!dev_test_excl(dev)) {
-		/* FIXME Detect whether device-mapper itself is still using it */
-		log_error("Can't open %s exclusively.  Mounted filesystem?",
-			  name);
-		goto out;
-	}
-
-	if (!wipe_known_signatures(cmd, dev, name,
-				   TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
-				   0, pp->yes, pp->force, wiped)) {
-		log_error("Aborting pvcreate on %s.", name);
-		goto out;
-	}
-
-	if (*wiped)
-		filter_refresh_needed = scan_needed = 1;
-
-	if (sigint_caught())
-		goto_out;
-
-	if (pv && !is_orphan(pv) && pp->force)
-		log_warn("WARNING: Forcing physical volume creation on "
-			  "%s%s%s%s", name,
-			  !is_orphan(pv) ? " of volume group \"" : "",
-			  pv_vg_name(pv),
-			  !is_orphan(pv) ? "\"" : "");
-
-	r = 1;
-
-out:
-	if (filter_refresh_needed)
-		if (!refresh_filters(cmd)) {
-			stack;
-			r = 0;
-		}
-
-	if (scan_needed) {
-		lvmcache_force_next_label_scan();
-		if (!lvmcache_label_scan(cmd)) {
-			stack;
-			r = 0;
-		}
-	}
-
-	free_pv_fid(pv);
-	return r;
-}
-
 static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 {
 	struct physical_volume *pv = pvw->pv;
@@ -1782,129 +1484,6 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 	return 1;
 }
 
-static int _verify_pv_create_params(struct pvcreate_params *pp)
-{
-	/*
-	 * FIXME: Some of these checks are duplicates in pvcreate_params_validate.
-	 */
-	if (pp->pva.pvmetadatacopies > 2) {
-		log_error("Metadatacopies may only be 0, 1 or 2");
-		return 0;
-	}
-
-	if (pp->pva.data_alignment > UINT32_MAX) {
-		log_error("Physical volume data alignment is too big.");
-		return 0;
-	}
-
-	if (pp->pva.data_alignment_offset > UINT32_MAX) {
-		log_error("Physical volume data alignment offset is too big.");
-		return 0;
-	}
-
-	return 1;
-}
-
-
-/*
- * pvcreate_vol() - initialize a device with PV label and metadata area
- *
- * Parameters:
- * - pv_name: device path to initialize
- * - pp: parameters to pass to pv_create; if NULL, use default values
- *
- * Returns:
- * NULL: error
- * struct physical_volume * (non-NULL): handle to physical volume created
- */
-struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
-				     struct pvcreate_params *pp, int write_now)
-{
-	struct physical_volume *pv = NULL;
-	struct device *dev;
-	int wiped = 0;
-	struct dm_list mdas;
-	struct pvcreate_params default_pp;
-	char buffer[64] __attribute__((aligned(8)));
-	dev_ext_t dev_ext_src;
-
-	pvcreate_params_set_defaults(&default_pp);
-	if (!pp)
-		pp = &default_pp;
-
-	if (!_verify_pv_create_params(pp)) {
-		goto bad;
-	}
-
-	if (pp->pva.idp) {
-		if ((dev = lvmcache_device_from_pvid(cmd, pp->pva.idp, NULL, NULL)) &&
-		    (dev != dev_cache_get(pv_name, cmd->full_filter))) {
-			if (!id_write_format((const struct id*)&pp->pva.idp->uuid,
-			    buffer, sizeof(buffer)))
-				goto_bad;
-			log_error("uuid %s already in use on \"%s\"", buffer,
-				  dev_name(dev));
-			goto bad;
-		}
-	}
-
-	if (!_pvcreate_check(cmd, pv_name, pp, &wiped))
-		goto_bad;
-
-	if (sigint_caught())
-		goto_bad;
-
-	/*
-	 * wipe_known_signatures called in _pvcreate_check fires
-	 * WATCH event to update udev database. But at the moment,
-	 * we have no way to synchronize with such event - we may
-	 * end up still seeing the old info in udev db and pvcreate
-	 * can fail to proceed because of the device still being
-	 * filtered (because of the stale info in udev db).
-	 * Disable udev dev-ext source temporarily here for
-	 * this reason and rescan with DEV_EXT_NONE dev-ext
-	 * source (so filters use DEV_EXT_NONE source).
-	 */
-	dev_ext_src = external_device_info_source();
-	if (wiped && (dev_ext_src == DEV_EXT_UDEV))
-		init_external_device_info_source(DEV_EXT_NONE);
-
-	dev = dev_cache_get(pv_name, cmd->full_filter);
-
-	init_external_device_info_source(dev_ext_src);
-
-	if (!dev) {
-		log_error("%s: Couldn't find device.  Check your filters?",
-			  pv_name);
-		goto bad;
-	}
-
-	dm_list_init(&mdas);
-
-	if (!(pv = pv_create(cmd, dev, &pp->pva))) {
-		log_error("Failed to setup physical volume \"%s\"", pv_name);
-		goto bad;
-	}
-
-	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-		    " available sectors", pv_name, pv_size(pv));
-
-	pv->status |= UNLABELLED_PV;
-	if (write_now) {
-		struct pv_to_write pvw;
-		pvw.pp = pp;
-		pvw.pv = pv;
-		pvw.new_pv = 1;
-		if (!_pvcreate_write(cmd, &pvw))
-			goto bad;
-	}
-
-	return pv;
-
-bad:
-	return NULL;
-}
-
 static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev)
 {
 	struct physical_volume *pv;
@@ -2203,48 +1782,6 @@ struct physical_volume *find_pv(struct volume_group *vg, struct device *dev)
 	return NULL;
 }
 
-/* FIXME: liblvm todo - make into function that returns handle */
-struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
-					const char *pv_name,
-					int allow_orphan, int allow_unformatted)
-{
-	struct device *dev;
-	struct pv_list *pvl;
-	struct dm_list *pvslist;
-	struct physical_volume *pv = NULL;
-
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
-	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
-		if (!allow_unformatted)
-			log_error("Physical volume %s not found", pv_name);
-		return_NULL;
-	}
-
-	if (!(pvslist = get_pvs(cmd)))
-		return_NULL;
-
-	dm_list_iterate_items(pvl, pvslist)
-		if (pvl->pv->dev == dev)
-			pv = pvl->pv;
-		else
-			free_pv_fid(pvl->pv);
-
-	if (!pv && !allow_unformatted)
-		log_error("Physical volume %s not found", pv_name);
-
-	if (pv && !allow_orphan && is_orphan_vg(pv->vg_name)) {
-		log_error("Physical volume %s not in a volume group", pv_name);
-		goto bad;
-	}
-
-	return pv;
-
-bad:
-	free_pv_fid(pv);
-	return NULL;
-}
-
 /* Find segment at a given logical extent in an LV */
 struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le)
 {
@@ -4899,7 +4436,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, consistent, 0)))
 		goto_out;
 
-	if (!_check_pv_dev_sizes(vg))
+	if (!check_pv_dev_sizes(vg))
 		log_warn("One or more devices used as PVs in VG %s "
 			 "have changed sizes.", vg->name);
 
@@ -5573,8 +5110,7 @@ static int _access_vg_clustered(struct cmd_context *cmd, const struct volume_gro
  *
  * FIXME Remove the unnecessary duplicate definitions and return bits directly.
  */
-static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
-				    uint64_t status)
+uint32_t vg_bad_status_bits(const struct volume_group *vg, uint64_t status)
 {
 	uint32_t failure = 0;
 
@@ -5610,7 +5146,7 @@ static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
  */
 int vg_check_status(const struct volume_group *vg, uint64_t status)
 {
-	return !_vg_bad_status_bits(vg, status);
+	return !vg_bad_status_bits(vg, status);
 }
 
 /*
@@ -5830,7 +5366,7 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 }
 
 /*
- * FIXME: move _vg_bad_status_bits() checks in here.
+ * FIXME: move vg_bad_status_bits() checks in here.
  */
 static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg,
 				uint32_t lockd_state, uint32_t *failure)
@@ -5966,7 +5502,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		goto bad;
 	}
 
-	failure |= _vg_bad_status_bits(vg, status_flags);
+	failure |= vg_bad_status_bits(vg, status_flags);
 	if (failure)
 		goto_bad;
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f3b1c95..0de9ed8 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -353,16 +353,13 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
 
-struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
-                                     struct pvcreate_params *pp, int write_now);
-
 int check_dev_block_size_for_vg(struct device *dev, const struct volume_group *vg,
 				unsigned int *max_phys_block_size_found);
+int check_pv_dev_sizes(struct volume_group *vg);
+uint32_t vg_bad_status_bits(const struct volume_group *vg, uint64_t status);
+int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
+		 struct physical_volume *pv, int new_pv);
 
-/* Manipulate PV structures */
-int pv_add(struct volume_group *vg, struct physical_volume *pv);
-int pv_remove(struct volume_group *vg, struct physical_volume *pv);
-struct physical_volume *pv_find(struct volume_group *vg, const char *pv_name);
 
 /* Find a PV within a given VG */
 int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
@@ -375,10 +372,6 @@ struct logical_volume *find_lv_in_vg_by_lvid(struct volume_group *vg,
 struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
 				   const struct logical_volume *lv);
 
-/* Return the VG that contains a given LV (based on path given in lv_name) */
-/* or environment var */
-struct volume_group *find_vg_with_lv(const char *lv_name);
-
 /* Find LV with given lvid (used during activation) */
 struct logical_volume *lv_from_lvid(struct cmd_context *cmd,
 				    const char *lvid_s,
@@ -466,8 +459,6 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
  */
 size_t export_vg_to_buffer(struct volume_group *vg, char **buf);
 struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg);
-struct volume_group *import_vg_from_buffer(const char *buf,
-					   struct format_instance *fid);
 struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
 						struct format_instance *fid);
 struct volume_group *import_vg_from_lvmetad_config_tree(const struct dm_config_tree *cft,
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 2a1754d..d68561c 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -705,179 +705,3 @@ out:
 			  "to repair from archived metadata.");
 	return r;
 }
-
-/*
- * Decide whether it is "safe" to wipe the labels on this device.
- * 0 indicates we may not.
- */
-static int _pvremove_check(struct cmd_context *cmd, const char *name,
-			   unsigned force_count, unsigned prompt, struct dm_list *pvslist)
-{
-	static const char really_wipe_msg[] = "Really WIPE LABELS from physical volume";
-	struct device *dev;
-	struct label *label;
-	struct pv_list *pvl;
-	struct physical_volume *pv = NULL;
-	int used;
-	int r = 0;
-
-	/* FIXME Check partition type is LVM unless --force is given */
-
-	if (!(dev = dev_cache_get(name, cmd->filter))) {
-		log_error("Device %s not found.", name);
-		return 0;
-	}
-
-	/* Is there a pv here already? */
-	/* If not, this is an error unless you used -f. */
-	if (!label_read(dev, &label, 0)) {
-		if (force_count)
-			return 1;
-		log_error("No PV label found on %s.", name);
-		return 0;
-	}
-
-	dm_list_iterate_items(pvl, pvslist)
-		if (pvl->pv->dev == dev)
-			pv = pvl->pv;
-
-	if (!pv) {
-		log_error(INTERNAL_ERROR "Physical Volume %s has a label, "
-			  "but is neither in a VG nor orphan.", name);
-		goto out; /* better safe than sorry */
-	}
-
-	if (is_orphan(pv)) {
-		if ((used = is_used_pv(pv)) < 0)
-			goto_out;
-
-		if (used) {
-			log_warn("WARNING: PV %s is used by a VG but its metadata is missing.", name);
-
-			if (force_count < 2)
-				goto_bad;
-
-			if (!prompt &&
-			    yes_no_prompt("%s \"%s\" that is marked as belonging to a VG [y/n]? ",
-					  really_wipe_msg, name) == 'n')
-				goto_bad;
-		}
-	} else {
-		log_warn("WARNING: PV %s is used by VG %s (consider using vgreduce).", name, pv_vg_name(pv));
-
-		if (force_count < 2)
-			goto_bad;
-
-		if (!prompt &&
-		    yes_no_prompt("%s \"%s\" of volume group \"%s\" [y/n]? ",
-				  really_wipe_msg, name, pv_vg_name(pv)) == 'n')
-			goto_bad;
-	}
-
-	if (force_count)
-		log_warn("WARNING: Wiping physical volume label from "
-			 "%s%s%s%s", name,
-			 !is_orphan(pv) ? " of volume group \"" : "",
-			 pv_vg_name(pv),
-			 !is_orphan(pv) ? "\"" : "");
-
-	r = 1;
-bad:
-	if (!r) {
-		log_error("%s: physical volume label not removed.", name);
-
-		if (force_count < 2) /* Show hint as log_error() */
-			log_error("(If you are certain you need pvremove, "
-				  "then confirm by using --force twice.)");
-	}
-out:
-	return r;
-}
-
-int pvremove_single(struct cmd_context *cmd, const char *pv_name,
-		    void *handle __attribute__((unused)), unsigned force_count,
-	            unsigned prompt, struct dm_list *pvslist)
-{
-	struct device *dev;
-	struct lvmcache_info *info;
-	int r = 0;
-
-	if (!_pvremove_check(cmd, pv_name, force_count, prompt, pvslist))
-		goto out;
-
-	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
-		log_error("%s: Couldn't find device.  Check your filters?",
-			  pv_name);
-		goto out;
-	}
-
-	info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
-
-	if (!dev_test_excl(dev)) {
-		/* FIXME Detect whether device-mapper is still using the device */
-		log_error("Can't open %s exclusively - not removing. "
-			  "Mounted filesystem?", dev_name(dev));
-		goto out;
-	}
-
-	/* Wipe existing label(s) */
-	if (!label_remove(dev)) {
-		log_error("Failed to wipe existing label(s) on %s", pv_name);
-		goto out;
-	}
-
-	if (info)
-		lvmcache_del(info);
-
-	if (!lvmetad_pv_gone_by_dev(dev))
-		goto_out;
-
-	log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
-				pv_name);
-
-	r = 1;
-
-out:
-	return r;
-}
-
-int pvremove_many(struct cmd_context *cmd, struct dm_list *pv_names,
-		  unsigned force_count, unsigned prompt)
-{
-	int ret = 1;
-	struct dm_list *pvslist = NULL;
-	struct pv_list *pvl;
-	const struct dm_str_list *pv_name;
-
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return 0;
-	}
-
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
-	if (!(pvslist = get_pvs(cmd))) {
-		ret = 0;
-		goto_out;
-	}
-
-	dm_list_iterate_items(pv_name, pv_names) {
-		if (!pvremove_single(cmd, pv_name->str, NULL, force_count, prompt, pvslist)) {
-			stack;
-			ret = 0;
-		}
-		if (sigint_caught()) {
-			ret = 0;
-			goto_out;
-		}
-	}
-
-out:
-	unlock_vg(cmd, NULL, VG_ORPHANS);
-
-	if (pvslist)
-		dm_list_iterate_items(pvl, pvslist)
-			free_pv_fid(pvl->pv);
-
-	return ret;
-}
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 580e942..20ceda3 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -13,7 +13,7 @@
  */
 
 #include "lib.h"
-#include "metadata.h"
+#include "metadata-exported.h"
 #include "lvm-string.h"
 #include "defaults.h"
 #include "segtype.h"
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 26e3cf1..143545b 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -14,7 +14,7 @@
 
 #include <stddef.h>
 #include "lib.h"
-#include "metadata.h"
+#include "metadata-exported.h"
 #include "lvm-string.h"
 #include "str_list.h"
 #include "lvm_misc.h"


