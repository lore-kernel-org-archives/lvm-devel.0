From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 20 Apr 2011 16:16:25 -0500
Subject: [PATCH 1 of 1] LVM: add raid support
Message-ID: <201104202116.p3KLGPHC014012@localhost6.localdomain6>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-add-raid-support.patch

I've attached the patch for LVM RAID.  It includes a basic design doc.  I've tested
it with the 2.6.38 kernel + patches.  The current upstream kernel does not work
because of some recent churn, so please consider this patch as a request for
input.  It will not go in until the upstream kernel changes are in place.

Things that are working (and addressed by the code) are:
- lvcreate
	- can create RAID 1/4/5/6
	- cannot specify new parameters yet (like --write_mostly)
- lvconvert
	- not implemented
- lvremove
	- works
- lvresize
	- not implemented
-lvs
	- works, but would be nice to convert '% Moved' heading to '% In-sync'
	  so that it would mean something for RAID 4/5/6 also.  Right now,
	  i simply don't display the sync % for RAID 4/5/6.

 brassow

LVM RAID Design Doc
===================

User-Interface
--------------

***************** CREATING A RAID DEVICE ******************

01: lvcreate --type <RAID type> \
02:	     [--region_size <size>] \
03:	     [-i/--stripes <#>] [-I,--stripesize <size>] \
04:	     [-m/--mirrors <#>] \
05:	     [--[min|max]_recovery_rate <kB/sec/disk>] \
06:	     [--stripe_cache <size>] \
07:	     [--write_mostly <devices>] \
08:	     [--max_write_behind <size>] \
09:	     [[no]sync] \
10:	     <Other normal args, like: -L 5G -n lv vg> \
11:	     [devices]

Line 01:
I don't intend for there to be shorthand options for specifying the
segment type.  The available RAID types are:
	"raid0"  - unneeded, not supported
	"raid1"  - should replace DM Mirroring
	"raid10" - striped mirrors, not implemented
	"raid4"  - RAID4
	"raid5"  - Same as "raid5_ls" (Same default as MD)
	"raid5_la" - RAID5 w/ parity layout of left-asymmetric
	"raid5_ra" - RAID5 w/ parity layout of right-asymmetric
	"raid5_ls" - RAID5 w/ parity layout of left-symmetric
	"raid5_rs" - RAID5 w/ parity layout of right-symmetric
	"raid6"    - Same as "raid6_zr"
	"raid6_zr" - RAID6 w/ parity layout of ?
	"raid6_nr" - RAID6 w/ parity layout of ?
	"raid6_nc" - RAID6 w/ parity layout of ?
If the MD RAID1 becomes the default mirror implementation in LVM, of course
the shorthand ('-m #') will work.  If we did use MD striping, that shorthand
would also work ('-i <#>').

Line 02:
Region size is relevant for all RAID types.  It defines the granularity for
which the bitmap will track the active areas of disk.  The default is currently
4MiB.  I see no reason to change this unless it is a problem for MD performance.
MD does impose a restriction of 2^21 regions for a given device, however.  This
means two things: 1) we should never need a metadata area larger than
8kiB+sizeof(superblock)+bitmap_offset (IOW, pretty small) and 2) the region
size will have to be upwardly revised if the device is larger than 8TiB
(assuming defaults).

Line 03/04:
The '-m/--mirrors' option is only relevant to RAID1 and will be used just like
it is today for DM mirroring.  For all other RAID types, -i/--stripes and
-I/--stripesize are relevant.  The former will specify the number of data
devices that will be used for striping.  For example, if the user specifies
'--type raid0 -i 3', then 3 devices are needed.  If the user specifies
'--type raid6 -i 3', then 5 devices are needed.  The -I/--stripesize may be
confusing to MD users, as they use the term "chunksize".  I think they will
adapt without issue and I don't wish to create a conflict with the term
"chunksize" we use for snapshots.

Line 05/06/07:
I'm still not clear on how to specify these options.  Some are easier than
others.  '--write-mostly' is particularly hard because it involves specifying
which devices shall be 'write-mostly' and thus, also have 'max-write-behind'
applied to them.  I also welcome suggestions on exactly how the options should
appear (--stripe_cache, --stripe-cache, or --stripecache).  It has been
suggested that a '--read-mostly'/'--read-favored' or similar option could be
introduced as a way to specify a primary disk vs. specifying all the non-primary
disks via '--write-mostly'.  I like this idea, but haven't come up with a good
name yet.

Line 09/10/11:
These are familiar.

Further creation related ideas:
Today, you can specify '--type mirror' without an '-m/--mirrors' argument
necessary.  The number of devices defaults to two (and the log defaults to
'disk').  A similar thing should happen with the RAID types.  All of them
should default to having two data devices unless otherwise specified.  This
would mean a total number of 2 devices for RAID 0/1, 3 devices for RAID 4/5,
and 4 devices for RAID 6/10.  There should be two ways to change this:
    1) By specifying -i/--stripes or -m/--mirrors
    2) By simply specifying [devices] (line 11).
If the user is specifying the devices to use at creation time, that should
be enough information allong with the RAID type to infer the number of total
devices.

Another "nice to have" would be automatic VG creation, but it's understandable
if this won't happen.  There could be a default VG name that is modeled after
the LV name chosen.  Alternately, a system default VG could be extended when a
create is performed and the LV could be added to that.  When devices are
specified, there are really only three conditions:
	   1) the devices are associated with no VG
	   2) the devices are associated with different VGs
	   3) the devices are associated with one VG
We can do as described above in the case of #1, #2 is an error, and #3 can
just proceed with the revealed name.  This could simplify all the PV, VG,
and LV steps of creating a RAID device down just one very short command:

$> lvcreate --type raid1 /dev/sd[bc]1

Note that even the size can be inferred from the above command.  Simply use
all the space on the devices provided!

If we chose to have a system default VG instead of modeling the name after
the LV, then creating a snapshot of this RAID volume would again be simple:

$> lvcreate -s <VG/LV> /dev/sdd1


***************** CONVERTING A RAID DEVICE ******************

01: lvconvert [--type <RAID type>] \
02:	      [-R/--regionsize <size>] \
03:	      [-i/--stripes <#>] [-I,--stripesize <size>] \
04:	      [-m/--mirrors <#>] \
05:	      [--splitmirrors <#>]
06:	      [--[min|max]_recovery_rate <kB/sec/disk>] \
07:	      [--stripe_cache <size>] \
08:	      [--write_mostly <devices>] \
09:	      [--max_write_behind <size>] \
10:	      vg/lv

lvconvert should work exactly as it does now when dealing with mirrors -
even if(when) we switch to MD RAID1.  Of course, there are no plans to
allow the presense of the metadata area to be configurable (e.g. --corelog).
It will be simple enough to detect if the LV being up/down-converted is
new or old-style mirroring.

If we choose to use MD RAID0 as well, it will be possible to change the
number of stripes and the stripesize.  It is therefore conceivable to see
something like, 'lvconvert -i +1 vg/lv'.

Line 01:
It is possible to change the RAID type of an LV - even if that LV is already
a RAID device of a different type.  For example, you could change from
RAID4 to RAID5 or RAID5 to RAID6.

Line 02/03/04:
These are familiar options - all of which would now be available as options
for change.  (However, it'd be nice if we didn't have regionsize in there.
It's simple on the kernel side, but is just an extra - often unecessary -
parameter to many functions in the LVM codebase.)

Line 06/07/08/09:
It should be possible to alter these parameters of a RAID device.  As with
lvcreate, however, I'm not entirely certain how to best define some of these.
We don't need all the capabilities at once though, so it isn't a pressing
issue.

Line 10:
The LV to operate on.


LVM RAID internal representation
--------------------------------
The internal representation is somewhat like mirroring, but with alterations
for the different metadata components.  LVM mirroring has a single log LV,
but RAID will have one for each data device.  Because of this, I've added a
new 'areas' list to the 'struct lv_segment' - 'meta_areas'.  There is exactly
a one-to-one relationship between 'areas' and 'meta_areas'.  The 'areas' array
still holds the data sub-lv's (similar to mirroring), while the 'meta_areas'
array holds the metadata sub-lv's (akin to the mirroring log device).

The sub_lvs will be named '%s_rimage_%d' instead of '%s_mimage_%d' as it is
for mirroring, and '%s_rmeta_%d' instead of '%s_mlog'.  Thus, you can imagine
an LV named 'foo' with the following layout:
foo
[foo's lv_segment]
|
|-> foo_rimage_0 (areas[0])
|   [foo_rimage_0's lv_segment]
|-> foo_rimage_1 (areas[1])
|   [foo_rimage_1's lv_segment]
|
|-> foo_rmeta_0 (meta_areas[0])
|   [foo_rmeta_0's lv_segment]
|-> foo_rmeta_1 (meta_areas[1])
|   [foo_rmeta_1's lv_segment]

LVM Meta-data format
--------------------
A new segment metadata format will be needed for RAID.  We will need to be
able to store parameters that are unique to RAID and unique to specific
RAID sub-devices.

For the most part, we can model the RAID format after that of mirroring.
Here is an example of the mirroring layout:
lv {
	id = "agL1vP-1B8Z-5vnB-41cS-lhBJ-Gcvz-dh3L3H"
	status = ["READ", "WRITE", "VISIBLE"]
	flags = []
	segment_count = 1

	segment1 {
		start_extent = 0
		extent_count = 125      # 500 Megabytes

		type = "mirror"
		mirror_count = 2
		mirror_log = "lv_mlog"
		region_size = 1024

		mirrors = [
			"lv_mimage_0", 0,
			"lv_mimage_1", 0
		]
	}
}

The real trick is dealing with the metadata devices.  Mirroring has an entry,
'mirror_log', in the top-level segment.  This won't work for RAID because there
is a one-to-one mapping between the data devices and the metadata devices.  The
mirror devices are layed-out in sub-device/le pairs.  The 'le' parameter is
redundant since it will always be zero.  So for RAID, I have simple put the
metadata and data devices in pairs without the 'le' parameter.

RAID metadata:
lv {
	id = "EnpqAM-5PEg-i9wB-5amn-P116-1T8k-nS3GfD"
	status = ["READ", "WRITE", "VISIBLE"]
	flags = []
	segment_count = 1

	segment1 {
		start_extent = 0
		extent_count = 125      # 500 Megabytes

		type = "raid1"
		device_count = 2
		region_size = 1024

		raids = [
			"lv_rmeta_0", "lv_rimage_0",
			"lv_rmeta_1", "lv_rimage_1",
		]
	}
}

The metadata also must be capable of representing the various tunables.  We
already have a good example for one from mirroring, region_size.
'max_write_behind', 'stripe_cache', and '[min|max]_recovery_rate' could also
be handled in this way.  However, 'write_mostly' cannot be handled in this
way, because it is a characteristic associated with the sub_lvs, not the
array as a whole.  In these cases, the status field of the sub-lv's themselves
will hold these flags - the meaning being only useful in the larger context.

Another important thing to mention is that we are running out of space for
'lv->status' additions.  We are /very/ close to having our 64 slots filled.
So, for RAID, RAID_IMAGE, and RAID_META, I am reusing some VG-only flag slots
for these LV status values.  I'm not sure if there are further slots for
"WRITE_MOSTLY" or other such values that would go in lv->status.  I may need to
reuse more flags, or expand the way flags are handled.

New Segment Type(s)
-------------------
I've created a new file 'lib/raid/raid.c' that will handle the various different
RAID types.  While there will be a unique segment type for each RAID variant,
they will all share a common backend - segtype_handler functions and
segtype->flags = SEG_RAID.

I'm also adding a new field to 'struct segment_type', parity_devs.  For every
segment_type except RAID4/5/6, this will be 0.  This field facilitates in
allocation and size calculations.  For example, the lvcreate for RAID5 would
look something like:
~> lvcreate --type raid5 -L 30G -i 3 -n my_raid5 my_vg
or
~> lvcreate --type raid5 -n my_raid5 my_vg /dev/sd[bcdef]1

In the former case, the stripe count (3) and device size are computed, and
then 'segtype->parity_devs' extra devices are allocated of the same size.  In
the latter case, the number of PVs is determined and 'segtype->parity_devs' is
subtracted off to determine the number of stripes.

This should also work in the case of RAID10 and doing things in this manor
should not affect the way size is calculated via the area_multiple.

Allocation
----------
Allocation is a tough bitch with many varying conditions.  I've written my
own simple/limited allocation code (_find_raid_space) for the time being.
When I can figure-out the allocation a little better to determine how best to
specify the additional number of parity drives (without altering the
extents_needed count), then I'll alter the current allocation code.

I added two fields to the 'struct alloc_handle':
        parity_count: This is the number of parity devices necessary.  Think
		      of this as adding to the 'area_count' field, but not
		      counting towards the size calculation.
	metadata_area_count: This is similar to log_area_count, but is only
			     used by RAID.  It should always be equal to the
			     number of devices being allocated for the RAID
			     array (there is a one-to-one mapping).
When allocating, we use our current computations to calculate the size needed
per device.  We must get that amount for each 'area_count' and now each
'parity_count' also.

Index: LVM2/lib/raid/raid.c
===================================================================
--- /dev/null
+++ LVM2/lib/raid/raid.c
@@ -0,0 +1,351 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "toolcontext.h"
+#include "segtype.h"
+#include "display.h"
+#include "text_export.h"
+#include "text_import.h"
+#include "config.h"
+#include "str_list.h"
+#include "targets.h"
+#include "lvm-string.h"
+#include "activate.h"
+#include "metadata.h"
+#include "lv_alloc.h"
+
+static const char *_raid_name(const struct lv_segment *seg)
+{
+	return seg->segtype->name;
+}
+
+static int _raid_text_import_area_count(const struct config_node *sn,
+					uint32_t *area_count)
+{
+	if (!get_config_uint32(sn, "device_count", area_count)) {
+		log_error("Couldn't read 'device_count' for "
+			  "segment '%s'.", config_parent_name(sn));
+		return 0;
+	}
+	return 1;
+}
+
+static int
+_raid_text_import_areas(struct lv_segment *seg, const struct config_node *sn,
+			const struct config_node *cn)
+{
+	unsigned int s;
+	const struct config_value *cv;
+	struct logical_volume *lv1;
+	const char *seg_name = config_parent_name(sn);
+
+	if (!seg->area_count) {
+		log_error("Zero areas not allowed for segment %s", seg_name);
+		return 0;
+	}
+
+	for (cv = cn->v, s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
+		if (cv->type != CFG_STRING) {
+			log_error("Bad volume name in areas array for segment %s.", seg_name);
+			return 0;
+		}
+
+		if (!cv->next) {
+			log_error("Missing data device in areas array for segment %s.", seg_name);
+			return 0;
+		}
+
+		/* Metadata device comes first */
+		if (!(lv1 = find_lv(seg->lv->vg, cv->v.str))) {
+			log_error("Couldn't find volume '%s' for segment '%s'.",
+				  cv->v.str ? : "NULL", seg_name);
+			return 0;
+		}
+		if (!set_lv_segment_area_lv(seg, s, lv1, 0, RAID_META))
+				return_0;
+
+		/* Data device comes second */
+		cv = cv->next;
+		if (!(lv1 = find_lv(seg->lv->vg, cv->v.str))) {
+			log_error("Couldn't find volume '%s' for segment '%s'.",
+				  cv->v.str ? : "NULL", seg_name);
+			return 0;
+		}
+		if (!set_lv_segment_area_lv(seg, s, lv1, 0, RAID_IMAGE))
+				return_0;
+	}
+
+	/*
+	 * Check we read the correct number of RAID data/meta pairs.
+	 */
+	if (cv || (s < seg->area_count)) {
+		log_error("Incorrect number of areas in area array "
+			  "for segment '%s'.", seg_name);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int
+_raid_text_import(struct lv_segment *seg, const struct config_node *sn,
+		  struct dm_hash_table *pv_hash)
+{
+	const struct config_node *cn;
+
+	if (find_config_node(sn, "region_size")) {
+		if (!get_config_uint32(sn, "region_size", &seg->region_size)) {
+			log_error("Couldn't read 'region_size' for "
+				  "segment %s of logical volume %s.",
+				  config_parent_name(sn), seg->lv->name);
+			return 0;
+		}
+	}
+	if (find_config_node(sn, "stripe_size")) {
+		if (!get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {
+			log_error("Couldn't read 'stripe_size' for "
+				  "segment %s of logical volume %s.",
+				  config_parent_name(sn), seg->lv->name);
+			return 0;
+		}
+	}
+	if (!(cn = find_config_node(sn, "raids"))) {
+		log_error("Couldn't find RAID array for "
+			  "segment %s of logical volume %s.",
+			  config_parent_name(sn), seg->lv->name);
+		return 0;
+	}
+
+	if (!_raid_text_import_areas(seg, sn, cn)) {
+		log_error("Failed to import RAID images");
+		return 0;
+	}
+
+	seg->status |= RAID;
+
+	return 1;
+}
+
+static int
+_raid_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	outf(f, "device_count = %u", seg->area_count);
+	if (seg->region_size)
+		outf(f, "region_size = %" PRIu32, seg->region_size);
+	if (seg->stripe_size)
+		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
+
+	return out_areas(f, seg, "raid");
+}
+
+static int
+_raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
+		      struct dm_pool *mem __attribute__((unused)),
+		      struct cmd_context *cmd __attribute__((unused)),
+		      void **target_state __attribute__((unused)),
+		      struct lv_segment *seg,
+		      struct dm_tree_node *node,uint64_t len,
+		      uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	if (!seg->area_count) {
+		log_error(INTERNAL_ERROR "_raid_add_target_line called "
+			  "with no areas for %s.", seg->lv->name);
+		return 0;
+	}
+
+	if (!seg->region_size) {
+		log_error("Missing region size for mirror segment.");
+		return 0;
+	}
+
+	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
+					  seg->region_size, seg->stripe_size,
+					  seg->area_count))
+		return_0;
+
+	return add_areas_line(dm, seg, node, 0u, seg->area_count);
+}
+
+static int _raid_target_status_compatible(const char *type)
+{
+	return (strstr(type, "raid") != NULL);
+}
+
+static int _raid_target_percent(void **target_state,
+				percent_t *percent,
+				struct dm_pool *mem,
+				struct cmd_context *cmd,
+				struct lv_segment *seg, char *params,
+				uint64_t *total_numerator,
+				uint64_t *total_denominator)
+{
+	int i;
+	uint64_t numerator, denominator;
+	char *pos = params;
+	/*
+	 * Status line:
+	 *    <raid_type> <#devs> <status_chars> <synced>/<total>
+	 * Example:
+	 *    raid1 2 AA 1024000/1024000
+	 */
+	for (i = 0; i < 3; i++) {
+		pos = strstr(pos, " ");
+		if (pos)
+			pos++;
+		else
+			break;
+	}
+	if (!pos || (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n",
+			    &numerator, &denominator, &i) != 2)) {
+		log_error("Failed to parse %s status fraction: %s",
+			  seg->segtype->name, params);
+		return 0;
+	}
+
+	*total_numerator += numerator;
+	*total_denominator += denominator;
+
+	if (seg)
+		seg->extents_copied = seg->area_len * numerator / denominator;
+
+	*percent = make_percent(numerator, denominator);
+
+	return 1;
+}
+
+
+static int
+_raid_target_present(struct cmd_context *cmd,
+		     const struct lv_segment *seg __attribute__((unused)),
+		     unsigned *attributes __attribute__((unused)))
+{
+	static int _raid_checked = 0;
+	static int _raid_present = 0;
+
+	if (!_raid_checked)
+		_raid_present = target_present(cmd, "raid", 1);
+
+	_raid_checked = 1;
+
+	return _raid_present;
+}
+
+static int
+_raid_modules_needed(struct dm_pool *mem,
+		     const struct lv_segment *seg __attribute__((unused)),
+		     struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, "raid")) {
+		log_error("raid module string list allocation failed");
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _raid_destroy(struct segment_type *segtype)
+{
+	dm_free((void *) segtype);
+}
+
+static struct segtype_handler _raid_ops = {
+	.name = _raid_name,
+	.text_import_area_count = _raid_text_import_area_count,
+	.text_import = _raid_text_import,
+	.text_export = _raid_text_export,
+	.add_target_line = _raid_add_target_line,
+	.target_status_compatible = _raid_target_status_compatible,
+	.target_percent = _raid_target_percent,
+	.target_present = _raid_target_present,
+	.modules_needed = _raid_modules_needed,
+	.destroy = _raid_destroy,
+};
+
+struct segment_type *init_raid_segtype(struct cmd_context *cmd,
+				       const char *raid_type)
+{
+	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+
+	if (!segtype)
+		return_NULL;
+
+	segtype->cmd = cmd;
+
+	segtype->flags = SEG_RAID;
+	segtype->parity_devs = strstr(raid_type, "raid6") ? 2 : 1;
+
+	segtype->ops = &_raid_ops;
+	segtype->name = raid_type;
+
+	segtype->private = NULL;
+
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return segtype;
+}
+
+struct segment_type *init_raid1_segtype(struct cmd_context *cmd)
+{
+	struct segment_type *segtype;
+
+	segtype = init_raid_segtype(cmd, "raid1");
+	if (!segtype)
+		return NULL;
+
+	segtype->flags |= SEG_AREAS_MIRRORED;
+	segtype->parity_devs = 0;
+
+	return segtype;
+}
+struct segment_type *init_raid4_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid4");
+}
+struct segment_type *init_raid5_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5");
+}
+struct segment_type *init_raid5_la_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5_la");
+}
+struct segment_type *init_raid5_ra_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5_ra");
+}
+struct segment_type *init_raid5_ls_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5_ls");
+}
+struct segment_type *init_raid5_rs_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid5_rs");
+}
+struct segment_type *init_raid6_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid6");
+}
+struct segment_type *init_raid6_zr_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid6_zr");
+}
+struct segment_type *init_raid6_nr_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid6_nr");
+}
+struct segment_type *init_raid6_nc_segtype(struct cmd_context *cmd)
+{
+	return init_raid_segtype(cmd, "raid6_nc");
+}
Index: LVM2/libdm/libdm-deptree.c
===================================================================
--- LVM2.orig/libdm/libdm-deptree.c
+++ LVM2/libdm/libdm-deptree.c
@@ -42,6 +42,16 @@ enum {
 	SEG_SNAPSHOT_MERGE,
 	SEG_STRIPED,
 	SEG_ZERO,
+	SEG_RAID1,
+	SEG_RAID4,
+	SEG_RAID5_LA,
+	SEG_RAID5_RA,
+	SEG_RAID5_LS,
+	SEG_RAID5_RS,
+	SEG_RAID6_ZR,
+	SEG_RAID6_NR,
+	SEG_RAID6_NC,
+	SEG_LAST,
 };
 
 /* FIXME Add crypt and multipath support */
@@ -61,6 +71,18 @@ struct {
 	{ SEG_SNAPSHOT_MERGE, "snapshot-merge" },
 	{ SEG_STRIPED, "striped" },
 	{ SEG_ZERO, "zero"},
+	{ SEG_RAID1, "raid1"},
+	{ SEG_RAID4, "raid4"},
+	{ SEG_RAID5_LA, "raid5_la"},
+	{ SEG_RAID5_RA, "raid5_ra"},
+	{ SEG_RAID5_LS, "raid5_ls"},
+	{ SEG_RAID5_RS, "raid5_rs"},
+	{ SEG_RAID6_ZR, "raid6_zr"},
+	{ SEG_RAID6_NR, "raid6_nr"},
+	{ SEG_RAID6_NC, "raid6_nc"},
+	{ SEG_RAID5_LS, "raid5"}, /* same as "raid5_ls" (default for MD also) */
+	{ SEG_RAID6_ZR, "raid6"}, /* same as "raid6_zr" */
+	{ SEG_LAST, NULL },
 };
 
 /* Some segment types have a list of areas of other devices attached */
@@ -100,7 +122,7 @@ struct load_segment {
 	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt + Replicator */
 	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt + Replicator */
 
-	uint32_t stripe_size;		/* Striped */
+	uint32_t stripe_size;		/* Striped + raid */
 
 	int persistent;			/* Snapshot */
 	uint32_t chunk_size;		/* Snapshot */
@@ -109,7 +131,7 @@ struct load_segment {
 	struct dm_tree_node *merge;	/* Snapshot */
 
 	struct dm_tree_node *log;	/* Mirror + Replicator */
-	uint32_t region_size;		/* Mirror */
+	uint32_t region_size;		/* Mirror + raid */
 	unsigned clustered;		/* Mirror */
 	unsigned mirror_area_count;	/* Mirror */
 	uint32_t flags;			/* Mirror log */
@@ -1484,6 +1506,17 @@ static int _emit_areas_line(struct dm_ta
 					EMIT_PARAMS(*pos, "%s", synctype);
 			}
 			break;
+		case SEG_RAID1:
+		case SEG_RAID4:
+		case SEG_RAID5_LA:
+		case SEG_RAID5_RA:
+		case SEG_RAID5_LS:
+		case SEG_RAID5_RS:
+		case SEG_RAID6_ZR:
+		case SEG_RAID6_NR:
+		case SEG_RAID6_NC:
+			EMIT_PARAMS(*pos, " %s", devbuf);
+			break;
 		default:
 			EMIT_PARAMS(*pos, "%s%s %" PRIu64, first_time ? "" : " ",
 				    devbuf, area->offset);
@@ -1654,6 +1687,48 @@ static int _mirror_emit_segment_line(str
 	return 1;
 }
 
+static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
+				   uint32_t minor, struct load_segment *seg,
+				   uint64_t *seg_start, char *params,
+				   size_t paramsize)
+{
+	int param_count = 0;
+	int pos = 0;
+
+	if ((seg->flags & DM_NOSYNC) || (seg->flags & DM_FORCESYNC))
+		param_count++;
+
+	if (seg->region_size)
+		param_count += 2;
+
+	if (seg->type != SEG_RAID1) {
+		/* stripe_size is required for RAID4/5/6 */
+		param_count += 1;
+
+		EMIT_PARAMS(pos, "%s %d %u", dm_segtypes[seg->type].target,
+			    /* FIXME: Figure out how to set stripe_size */
+			    param_count, seg->stripe_size);
+	} else
+		EMIT_PARAMS(pos, "%s %d", dm_segtypes[seg->type].target,
+			    param_count);
+
+	if (seg->flags & DM_NOSYNC)
+		EMIT_PARAMS(pos, " nosync");
+	else if (seg->flags & DM_FORCESYNC)
+		EMIT_PARAMS(pos, " sync");
+
+	if (seg->region_size)
+		EMIT_PARAMS(pos, " region_size %u", seg->region_size);
+
+	/* Print number of metadata/data device combos */
+	EMIT_PARAMS(pos, " %u", seg->area_count/2);
+
+	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
+		return_0;
+
+	return 1;
+}
+
 static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			      uint32_t minor, struct load_segment *seg,
 			      uint64_t *seg_start, char *params,
@@ -1661,6 +1736,7 @@ static int _emit_segment_line(struct dm_
 {
 	int pos = 0;
 	int r;
+	int target_type_is_raid = 0;
 	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
 
 	switch(seg->type) {
@@ -1714,6 +1790,22 @@ static int _emit_segment_line(struct dm_
 			    seg->iv_offset != DM_CRYPT_IV_DEFAULT ?
 			    seg->iv_offset : *seg_start);
 		break;
+	case SEG_RAID1:
+	case SEG_RAID4:
+	case SEG_RAID5_LA:
+	case SEG_RAID5_RA:
+	case SEG_RAID5_LS:
+	case SEG_RAID5_RS:
+	case SEG_RAID6_ZR:
+	case SEG_RAID6_NR:
+	case SEG_RAID6_NC:
+		target_type_is_raid = 1;
+		r = _raid_emit_segment_line(dmt, major, minor, seg, seg_start,
+					    params, paramsize);
+		if (!r)
+			return_0;
+
+		break;
 	}
 
 	switch(seg->type) {
@@ -1739,7 +1831,9 @@ static int _emit_segment_line(struct dm_
 		  " %" PRIu64 " %s %s", major, minor,
 		  *seg_start, seg->size, dm_segtypes[seg->type].target, params);
 
-	if (!dm_task_add_target(dmt, *seg_start, seg->size, dm_segtypes[seg->type].target, params))
+	if (!dm_task_add_target(dmt, *seg_start, seg->size,
+				target_type_is_raid ? "raid" :
+				dm_segtypes[seg->type].target, params))
 		return_0;
 
 	*seg_start += seg->size;
@@ -2206,6 +2300,29 @@ int dm_tree_node_add_mirror_target(struc
 	return 1;
 }
 
+int dm_tree_node_add_raid_target(struct dm_tree_node *node,
+				 uint64_t size,
+				 const char *raid_type,
+				 uint32_t region_size,
+				 uint32_t stripe_size,
+				 uint32_t area_count)
+{
+	int i;
+	struct load_segment *seg = NULL;
+
+	for (i = 0; dm_segtypes[i].target && !seg; i++)
+		if (!strcmp(raid_type, dm_segtypes[i].target))
+			if (!(seg = _add_segment(node,
+						 dm_segtypes[i].type, size)))
+				return_0;
+
+	seg->region_size = region_size;
+	seg->stripe_size = stripe_size;
+	seg->area_count = 0;
+
+	return 1;
+}
+
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,
Index: LVM2/tools/lvcreate.c
===================================================================
--- LVM2.orig/tools/lvcreate.c
+++ LVM2/tools/lvcreate.c
@@ -320,6 +320,50 @@ static int _read_mirror_params(struct lv
 	return 1;
 }
 
+static int _read_raid_params(struct lvcreate_params *lp,
+			     struct cmd_context *cmd)
+{
+	if (!segtype_is_raid(lp->segtype))
+		return 1;
+
+	if (arg_count(cmd, corelog_ARG) ||
+	    arg_count(cmd, mirrorlog_ARG)) {
+		log_error("Log options not applicable to %s segtype",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	/*
+	 * get_stripe_params is called before _read_raid_params
+	 * and already sets:
+	 *   lp->stripes
+	 *   lp->stripe_size
+	 *
+	 * For RAID 4/5/6, these values must be set.
+	 */
+	if (!segtype_is_mirrored(lp->segtype) && (lp->stripes < 2)) {
+		log_error("Number of stripes to %s not specified",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	/*
+	 * _read_mirror_params is called before _read_raid_params
+	 * and already sets:
+	 *   lp->nosync
+	 *   lp->region_size
+	 *
+	 * But let's ensure that programmers don't reorder
+	 * that by checking and warning if they aren't set.
+	 */
+	if (!lp->region_size) {
+		log_error("Programmer error: lp->region_size not set.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _lvcreate_params(struct lvcreate_params *lp,
 			    struct lvcreate_cmdline_params *lcp,
 			    struct cmd_context *cmd,
@@ -328,6 +372,7 @@ static int _lvcreate_params(struct lvcre
 	int contiguous;
 	unsigned pagesize;
 	struct arg_value_group_list *current_group;
+	const char *segtype_str;
 	const char *tag;
 
 	memset(lp, 0, sizeof(*lp));
@@ -337,7 +382,11 @@ static int _lvcreate_params(struct lvcre
 	/*
 	 * Check selected options are compatible and determine segtype
 	 */
-	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "striped"));
+	if (arg_count(cmd, mirrors_ARG))
+		segtype_str = "mirror";
+	else
+		segtype_str = "striped";
+	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, segtype_str));
 
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
 	    arg_count(cmd, virtualsize_ARG))
@@ -345,7 +394,7 @@ static int _lvcreate_params(struct lvcre
 
 	lp->mirrors = 1;
 
-	/* Default to 2 mirrored areas if --type mirror */
+	/* Default to 2 mirrored areas if '--type mirror|raid1' */
 	if (segtype_is_mirrored(lp->segtype))
 		lp->mirrors = 2;
 
@@ -386,15 +435,12 @@ static int _lvcreate_params(struct lvcre
 		}
 	}
 
-	if (lp->mirrors > 1) {
+	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
 		if (lp->snapshot) {
 			log_error("mirrors and snapshots are currently "
 				  "incompatible");
 			return 0;
 		}
-
-		if (!(lp->segtype = get_segtype_from_string(cmd, "striped")))
-			return_0;
 	} else {
 		if (arg_count(cmd, corelog_ARG)) {
 			log_error("--corelog is only available with mirrors");
@@ -426,7 +472,8 @@ static int _lvcreate_params(struct lvcre
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
-	    !_read_mirror_params(lp, cmd))
+	    !_read_mirror_params(lp, cmd) ||
+	    !_read_raid_params(lp, cmd))
 		return_0;
 
 	/*
Index: LVM2/lib/commands/toolcontext.c
===================================================================
--- LVM2.orig/lib/commands/toolcontext.c
+++ LVM2/lib/commands/toolcontext.c
@@ -949,6 +949,61 @@ static int _init_segtypes(struct cmd_con
 	segtype->library = NULL;
 	dm_list_add(&cmd->segtypes, &segtype->list);
 
+	if (!(segtype = init_raid1_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid4_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid5_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid5_la_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid5_ra_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid5_ls_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid5_rs_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid6_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid6_zr_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid6_nr_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
+	if (!(segtype = init_raid6_nc_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+
 #ifdef SNAPSHOT_INTERNAL
 	if (!(segtype = init_snapshot_segtype(cmd)))
 		return 0;
Index: LVM2/lib/metadata/segtype.h
===================================================================
--- LVM2.orig/lib/metadata/segtype.h
+++ LVM2/lib/metadata/segtype.h
@@ -37,6 +37,7 @@ struct dev_manager;
 #define SEG_MONITORED		0x00000080U
 #define SEG_REPLICATOR		0x00000100U
 #define SEG_REPLICATOR_DEV	0x00000200U
+#define SEG_RAID                0x00000400U
 #define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -45,6 +46,7 @@ struct dev_manager;
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
+#define seg_is_raid(seg)        ((seg)->segtype->flags & SEG_RAID ? 1 : 0)
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
@@ -52,14 +54,19 @@ struct dev_manager;
 
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
+#define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 
 struct segment_type {
 	struct dm_list list;		/* Internal */
 	struct cmd_context *cmd;	/* lvm_register_segtype() sets this. */
+
 	uint32_t flags;
+	uint32_t parity_devs;           /* Parity drives required by segtype */
+
 	struct segtype_handler *ops;
 	const char *name;
+
 	void *library;			/* lvm_register_segtype() sets this. */
 	void *private;			/* For the segtype handler to use. */
 };
@@ -114,7 +121,19 @@ struct segment_type *init_striped_segtyp
 struct segment_type *init_zero_segtype(struct cmd_context *cmd);
 struct segment_type *init_error_segtype(struct cmd_context *cmd);
 struct segment_type *init_free_segtype(struct cmd_context *cmd);
-struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *name);
+struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
+					  const char *name);
+struct segment_type *init_raid1_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid4_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_la_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_ra_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_ls_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid5_rs_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_zr_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_nr_segtype(struct cmd_context *cmd);
+struct segment_type *init_raid6_nc_segtype(struct cmd_context *cmd);
 
 #ifdef REPLICATOR_INTERNAL
 int init_replicator_segtype(struct segtype_library *seglib);
Index: LVM2/lib/Makefile.in
===================================================================
--- LVM2.orig/lib/Makefile.in
+++ LVM2/lib/Makefile.in
@@ -94,6 +94,7 @@ SOURCES =\
 	misc/lvm-percent.c \
 	misc/util.c \
 	mm/memlock.c \
+	raid/raid.c \
 	report/properties.c \
 	report/report.c \
 	striped/striped.c \
Index: LVM2/libdm/libdevmapper.h
===================================================================
--- LVM2.orig/libdm/libdevmapper.h
+++ LVM2/libdm/libdevmapper.h
@@ -456,6 +456,13 @@ int dm_tree_node_add_mirror_target_log(s
 					  unsigned area_count,
 					  uint32_t flags);
 
+int dm_tree_node_add_raid_target(struct dm_tree_node *node,
+				 uint64_t size,
+				 const char *raid_type,
+				 uint32_t region_size,
+				 uint32_t stripe_size,
+				 uint32_t area_count);
+
 /*
  * Replicator operation mode
  * Note: API for Replicator is not yet stable
Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -215,6 +215,11 @@ struct lv_segment *alloc_lv_segment(stru
 	struct lv_segment *seg;
 	uint32_t areas_sz = area_count * sizeof(*seg->areas);
 
+	if (!segtype) {
+		log_error("alloc_lv_segment: Missing segtype.");
+		return NULL;
+	}
+
 	if (!(seg = dm_pool_zalloc(mem, sizeof(*seg))))
 		return_NULL;
 
@@ -223,9 +228,10 @@ struct lv_segment *alloc_lv_segment(stru
 		return_NULL;
 	}
 
-	if (!segtype) {
-		log_error("alloc_lv_segment: Missing segtype.");
-		return NULL;
+	if (segtype_is_raid(segtype) &&
+	    !(seg->meta_areas = dm_pool_zalloc(mem, areas_sz))) {
+		dm_pool_free(mem, seg); /* frees everything alloced since seg */
+		return_NULL;
 	}
 
 	seg->segtype = segtype;
@@ -293,6 +299,27 @@ void release_lv_segment_area(struct lv_s
 		return;
 	}
 
+	if (seg_lv(seg, s)->status & RAID_IMAGE) {
+		/*
+		 * FIXME: Use lv_reduce not lv_remove
+		 *  We use lv_remove for now, because I haven't figured out
+		 *  why lv_reduce won't remove the LV.
+		lv_reduce(seg_lv(seg, s), area_reduction);
+		*/
+		if (area_reduction != seg->area_len) {
+			log_error("Unable to reduce RAID LV - operation not implemented.");
+			return;
+		} else
+			lv_remove(seg_lv(seg, s));
+
+		/* Remove metadata area if image has been removed */
+		if (area_reduction == seg->area_len) {
+			lv_reduce(seg_metalv(seg, s),
+				  seg_metalv(seg, s)->le_count);
+		}
+		return;
+	}
+
 	if (area_reduction == seg->area_len) {
 		log_very_verbose("Remove %s:%" PRIu32 "[%" PRIu32 "] from "
 				 "the top of LV %s:%" PRIu32,
@@ -375,9 +402,19 @@ int set_lv_segment_area_lv(struct lv_seg
 	log_very_verbose("Stack %s:%" PRIu32 "[%" PRIu32 "] on LV %s:%" PRIu32,
 			 seg->lv->name, seg->le, area_num, lv->name, le);
 
-	seg->areas[area_num].type = AREA_LV;
-	seg_lv(seg, area_num) = lv;
-	seg_le(seg, area_num) = le;
+	if (status & RAID_META) {
+		seg->meta_areas[area_num].type = AREA_LV;
+		seg_metalv(seg, area_num) = lv;
+		if (le) {
+			log_error(INTERNAL_ERROR "Meta le != 0");
+			return 0;
+		}
+		seg_metale(seg, area_num) = 0;
+	} else {
+		seg->areas[area_num].type = AREA_LV;
+		seg_lv(seg, area_num) = lv;
+		seg_le(seg, area_num) = le;
+	}
 	lv->status |= status;
 
 	if (!add_seg_to_segs_using_this_lv(lv, seg))
@@ -555,8 +592,10 @@ struct alloc_handle {
 	alloc_policy_t alloc;		/* Overall policy */
 	uint32_t new_extents;		/* Number of new extents required */
 	uint32_t area_count;		/* Number of parallel areas */
+	uint32_t parity_count;   /* Adds to area_count, but not area_multiple */
 	uint32_t area_multiple;		/* seg->len = area_len * area_multiple */
 	uint32_t log_area_count;	/* Number of parallel logs */
+	uint32_t metadata_area_count;   /* Number of parallel metadata areas */
 	uint32_t log_len;		/* Length of log */
 	uint32_t region_size;		/* Mirror region size */
 	uint32_t total_area_len;	/* Total number of parallel extents */
@@ -627,13 +666,14 @@ static struct alloc_handle *_alloc_init(
 					uint32_t new_extents,
 					uint32_t mirrors,
 					uint32_t stripes,
-					uint32_t log_area_count,
+					uint32_t metadata_area_count,
 					uint32_t extent_size,
 					uint32_t region_size,
 					struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
-	uint32_t s, area_count;
+	uint32_t s, area_count, alloc_count;
+	size_t size = 0;
 
 	/* FIXME Caller should ensure this */
 	if (mirrors && !stripes)
@@ -646,7 +686,11 @@ static struct alloc_handle *_alloc_init(
 	else
 		area_count = stripes;
 
-	if (!(ah = dm_pool_zalloc(mem, sizeof(*ah) + sizeof(ah->alloced_areas[0]) * (area_count + log_area_count)))) {
+	size = sizeof(*ah);
+	alloc_count = area_count + segtype->parity_devs + metadata_area_count;
+	size += sizeof(ah->alloced_areas[0]) * alloc_count;
+
+	if (!(ah = dm_pool_zalloc(mem, size))) {
 		log_error("allocation handle allocation failed");
 		return NULL;
 	}
@@ -656,7 +700,7 @@ static struct alloc_handle *_alloc_init(
 	if (segtype_is_virtual(segtype))
 		return ah;
 
-	if (!(area_count + log_area_count)) {
+	if (!(area_count + metadata_area_count)) {
 		log_error(INTERNAL_ERROR "_alloc_init called for non-virtual segment with no disk space.");
 		return NULL;
 	}
@@ -668,14 +712,22 @@ static struct alloc_handle *_alloc_init(
 
 	ah->new_extents = new_extents;
 	ah->area_count = area_count;
-	ah->log_area_count = log_area_count;
+	ah->parity_count = segtype->parity_devs;
 	ah->region_size = region_size;
 	ah->alloc = alloc;
 	ah->area_multiple = _calc_area_multiple(segtype, area_count, stripes);
 
-	ah->log_len = log_area_count ? mirror_log_extents(ah->region_size, extent_size, ah->new_extents / ah->area_multiple) : 0;
+	if (segtype_is_raid(segtype)) {
+		ah->metadata_area_count = area_count;
+		ah->log_len = 1;
+	} else {
+		ah->log_area_count = metadata_area_count;
+		ah->log_len = !metadata_area_count ? 0 :
+			mirror_log_extents(ah->region_size, extent_size,
+					   ah->new_extents / ah->area_multiple);
+	}
 
-	for (s = 0; s < ah->area_count + ah->log_area_count; s++)
+	for (s = 0; s < alloc_count; s++)
 		dm_list_init(&ah->alloced_areas[s]);
 
 	ah->parallel_areas = parallel_areas;
@@ -696,9 +748,13 @@ void alloc_destroy(struct alloc_handle *
 }
 
 /* Is there enough total space or should we give up immediately? */
-static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms, uint32_t allocated, uint32_t extents_still_needed)
+static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
+				uint32_t allocated, uint32_t extents_still_needed)
 {
-	uint32_t total_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
+	uint32_t area_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
+	uint32_t parity_extents_needed = (extents_still_needed - allocated) * ah->parity_count / ah->area_multiple;
+	uint32_t metadata_extents_needed = ah->metadata_area_count; /* One each */
+	uint32_t total_extents_needed = area_extents_needed + parity_extents_needed + metadata_extents_needed;
 	uint32_t free_pes = pv_maps_size(pvms);
 
 	if (total_extents_needed > free_pes) {
@@ -1402,6 +1458,105 @@ static void _clear_areas(struct alloc_st
 }
 
 /*
+ * FIXME:  Integrate _find_raid_space with _find_parallel_space...
+ * _find_parallel_space is complicated, for now we
+ * write our own (albeit simple) routine for raid...  :(
+ *
+ * We're going to make this really simple.  The conditions are:
+ *  - allocation policy can only be contiguous
+ *  - we get everything in one go, or we fail
+ *
+ * Method:
+ *  - We find space big enough for the metadata and data for each raid
+ *    component (so they can be together)
+ *  - We split the large allocation into the two needed for metadata
+ *    and data.
+ */
+static int _find_raid_space(struct alloc_handle *ah, struct dm_list *pvms)
+{
+	int i;
+	uint32_t s;
+	uint32_t free_pes;
+	struct pv_map *pvm;
+	struct pv_area *pva;
+	uint32_t devices_needed = ah->area_count + ah->parity_count;
+	uint32_t size_per_device = ah->new_extents / ah->area_multiple + ah->log_len;
+	struct alloced_area *aa;
+
+	if (!ah->metadata_area_count) {
+		log_error("_find_raid_space called but !ah->metadata_area_count");
+		return 0;
+	}
+
+	if (ah->metadata_area_count != ah->area_count) {
+		log_error("ah->metadata_area_count != ah->area_count");
+		return 0;
+	}
+
+	free_pes = pv_maps_size(pvms);
+	if (size_per_device * devices_needed > free_pes) {
+		log_error("Insufficient free space: %" PRIu32 " extents needed,"
+			  " but only %" PRIu32 " available",
+			  size_per_device * devices_needed, free_pes);
+		return 0;
+	}
+
+	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) * devices_needed * 2))) {
+		log_error("alloced_area allocation failed");
+		return 0;
+	}
+
+	s = 0;
+	dm_list_iterate_items(pvm, pvms) {
+		log_very_verbose("Checking device %s for %u extents of free space",
+				 dev_name(pvm->pv->dev), size_per_device);
+		if (dm_list_empty(&pvm->areas)) {
+			log_debug("  - no free space");
+			continue;       /* Next PV */
+		}
+		i = 0;
+		dm_list_iterate_items(pva, &pvm->areas) {
+			i++;
+			if (pva->count >= size_per_device) {
+				log_very_verbose("Area %d: %u extents (Match)",
+						 i, pva->count);
+				/*
+				 * Metadata goes at the front for now, but
+				 * could easily go at the end (or middle!).
+				 *
+				 * Even though we split these two from the
+				 * same allocation, we store the images at
+				 * the beginning of the array and the meta
+				 * at the end.
+				 */
+				s += ah->area_count + ah->parity_count;
+				aa[s].pv = pva->map->pv;
+				aa[s].pe = pva->start;
+				aa[s].len = ah->log_len;
+				consume_pv_area(pva, ah->log_len);
+				dm_list_add(&ah->alloced_areas[s], &aa[s].list);
+				s -= ah->area_count + ah->parity_count;
+
+				aa[s].pv = pva->map->pv;
+				aa[s].pe = pva->start;
+				aa[s].len = ah->new_extents / ah->area_multiple;
+				consume_pv_area(pva, ah->new_extents / ah->area_multiple);
+				dm_list_add(&ah->alloced_areas[s], &aa[s].list);
+				s++;
+				devices_needed--;
+				break; /* Now go on to next PV */
+			}
+			log_very_verbose("Area %d: %u extents", i, pva->count);
+		}
+		if (!devices_needed)
+			return 1;
+	}
+	return_0;
+}
+
+
+
+/*
  * Returns 1 regardless of whether any space was found, except on error.
  */
 static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc_parms *alloc_parms,
@@ -1730,14 +1885,15 @@ static int _allocate(struct alloc_handle
 		stack;
 
 	alloc_state.areas_size = dm_list_size(pvms);
-	if (alloc_state.areas_size && alloc_state.areas_size < (ah->area_count + ah->log_area_count)) {
+	if (alloc_state.areas_size &&
+	    alloc_state.areas_size < (ah->area_count + ah->parity_count + ah->log_area_count)) {
 		if (ah->alloc != ALLOC_ANYWHERE && ah->mirror_logs_separate) {
 			log_error("Not enough PVs with free space available "
 				  "for parallel allocation.");
 			log_error("Consider --alloc anywhere if desperate.");
 			return 0;
 		}
-		alloc_state.areas_size = ah->area_count + ah->log_area_count;
+		alloc_state.areas_size = ah->area_count + ah->parity_count + ah->log_area_count;
 	}
 
 	/* Upper bound if none of the PVs in prev_lvseg is in pvms */
@@ -1752,6 +1908,18 @@ static int _allocate(struct alloc_handle
 	}
 
 	/*
+	 * FIXME:
+	 * We are calling an simplified alternate allocation scheme for
+	 * RAID.  We can only detect if RAID is wanted by the
+	 * metadata_area_count... and that is only needed on create.  This
+	 * means we also won't be able to extend a RAID device for now.
+	 */
+	if (ah->metadata_area_count) {
+		r = _find_raid_space(ah, pvms);
+		goto out;
+	}
+
+	/*
 	 * cling includes implicit cling_by_tags
 	 * but it does nothing unless the lvm.conf setting is present.
 	 */
@@ -1769,7 +1937,9 @@ static int _allocate(struct alloc_handle
 		if (!_sufficient_pes_free(ah, pvms, alloc_state.allocated, ah->new_extents))
 			goto_out;
 
-		_init_alloc_parms(ah, &alloc_parms, alloc, prev_lvseg, can_split, alloc_state.allocated, ah->new_extents);
+		_init_alloc_parms(ah, &alloc_parms, alloc, prev_lvseg,
+				  can_split, alloc_state.allocated,
+				  ah->new_extents);
 
 		if (!_find_max_parallel_space_for_one_policy(ah, &alloc_parms, pvms, &alloc_state))
 			goto_out;
@@ -2108,12 +2278,13 @@ int lv_add_log_segment(struct alloc_hand
 
 static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 				   const struct segment_type *segtype,
-				   uint32_t region_size,
+				   uint32_t stripe_size, uint32_t region_size,
 				   uint32_t devices)
 {
 	struct logical_volume *sub_lv;
 	uint32_t i;
 	uint64_t status = 0;
+	const char *layer_name;
 	size_t len = strlen(lv->name) + 32;
 	char img_name[len];
 	struct lv_segment *mapseg;
@@ -2124,15 +2295,22 @@ static int _lv_insert_empty_sublvs(struc
 		return 0;
 	}
 
-	if (!segtype_is_mirrored(segtype))
+	if (segtype_is_raid(segtype)) {
+		lv->status |= RAID;
+		status = RAID_IMAGE;
+		layer_name = "rimage";
+	} else if (segtype_is_mirrored(segtype)) {
+		lv->status |= MIRRORED;
+		status = MIRROR_IMAGE;
+		layer_name = "mimage";
+	} else
 		return_0;
-	lv->status |= MIRRORED;
 
 	/*
 	 * First, create our top-level segment for our top-level LV
 	 */
 	if (!(mapseg = alloc_lv_segment(lv->vg->cmd->mem, segtype,
-					lv, 0, 0, lv->status, 0, NULL,
+					lv, 0, 0, lv->status, stripe_size, NULL,
 					devices, 0, 0, region_size, 0, NULL))) {
 		log_error("Failed to create mapping segment for %s", lv->name);
 		return 0;
@@ -2141,16 +2319,31 @@ static int _lv_insert_empty_sublvs(struc
 	/*
 	 * Next, create all of our sub_lv's and link them in.
 	 */
-	if (dm_snprintf(img_name, len, "%s%s", lv->name, "_mimage_%d") < 0)
-		return_0;
-
 	for (i = 0; i < devices; i++) {
-		sub_lv = lv_create_empty(img_name, NULL,
-					 MIRROR_IMAGE, lv->alloc, lv->vg);
+		/* Data LVs */
+		if (dm_snprintf(img_name, len, "%s_%s_%u",
+				lv->name, layer_name, i) < 0)
+			return_0;
+
+		sub_lv = lv_create_empty(img_name, NULL, status,
+					 lv->alloc, lv->vg);
 		if (!sub_lv)
 			return_0;
 		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, status))
 			return_0;
+		if (!segtype_is_raid(segtype))
+			continue;
+
+		/* RAID meta LVs */
+		if (dm_snprintf(img_name, len, "%s_rmeta_%u", lv->name, i) < 0)
+			return_0;
+
+		sub_lv = lv_create_empty(img_name, NULL, RAID_META,
+					 lv->alloc, lv->vg);
+		if (!sub_lv)
+			return_0;
+		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, RAID_META))
+			return_0;
 	}
 	dm_list_add(&lv->segments, &mapseg->list);
 
@@ -2162,30 +2355,91 @@ static int _lv_extend_layered_lv(struct 
 				 uint32_t extents, uint32_t first_area,
 				 uint32_t stripes, uint32_t stripe_size)
 {
-	struct logical_volume *sub_lv;
+	const struct segment_type *segtype;
+	struct logical_volume *sub_lv, *meta_lv;
 	struct lv_segment *seg;
-	uint32_t m, s;
+	uint32_t fa, s;
+
+	segtype = get_segtype_from_string(lv->vg->cmd, "striped");
+
+	/*
+	 * The component devices of a "striped" LV all go in the same
+	 * LV.  However, RAID has an LV for each device - making the
+	 * 'stripes' and 'stripe_size' parameters meaningless.
+	 */
+	if (seg_is_raid(first_seg(lv))) {
+		stripes = 1;
+		stripe_size = 0;
+	}
 
 	seg = first_seg(lv);
-	for (m = first_area, s = 0; s < seg->area_count; s++) {
+	for (fa = first_area, s = 0; s < seg->area_count; s++) {
 		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
 			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents,
-						   m, stripes, stripe_size))
+						   fa, stripes, stripe_size))
 				return_0;
-			m += lv_mirror_count(seg_lv(seg, s));
+			fa += lv_mirror_count(seg_lv(seg, s));
 			continue;
 		}
 
 		sub_lv = seg_lv(seg, s);
-		if (!lv_add_segment(ah, m, stripes, sub_lv,
-				    get_segtype_from_string(lv->vg->cmd,
-							    "striped"),
+		if (!lv_add_segment(ah, fa, stripes, sub_lv, segtype,
 				    stripe_size, sub_lv->status, 0)) {
 			log_error("Aborting. Failed to extend %s in %s.",
 				  sub_lv->name, lv->name);
 			return 0;
 		}
-		m += stripes;
+
+		/* Extend metadata LVs only on initial creation */
+		if (seg_is_raid(seg) && !lv->le_count) {
+			if (!seg->meta_areas) {
+				log_error("No meta_areas for RAID type");
+				return 0;
+			}
+
+			meta_lv = seg_metalv(seg, s);
+			if (!lv_add_segment(ah, fa + seg->area_count, 1,
+					    meta_lv, segtype, 0,
+					    meta_lv->status, 0)) {
+				log_error("Failed to extend %s in %s.",
+					  meta_lv->name, lv->name);
+				return 0;
+			}
+
+			/*
+			 * We must clear the metadata areas upon creation.
+			 */
+			lv_set_visible(meta_lv);
+			meta_lv->status |= LVM_WRITE;
+			if (!vg_write(meta_lv->vg) ||
+			    !vg_commit(meta_lv->vg) ||
+			    !activate_lv(meta_lv->vg->cmd, meta_lv)) {
+				log_error("Failed to activate %s for clearing",
+					  meta_lv->name);
+				return 0;
+			}
+
+			log_verbose("Clearing metadata area of %s/%s",
+				    meta_lv->vg->name, meta_lv->name);
+			/*
+			 * Rather than wiping meta_lv->size, we can simply
+			 * wipe '1' to remove the superblock of any previous
+			 * RAID devices.  It is much quicker.
+			 */
+			if (!set_lv(meta_lv->vg->cmd, meta_lv, 1, 0)) {
+				log_error("Failed to zero %s", meta_lv->name);
+				return 0;
+			}
+
+			if (!deactivate_lv(meta_lv->vg->cmd, meta_lv)) {
+				log_error("Failed to deactivate %s",
+					  meta_lv->name);
+				return 0;
+			}
+			lv_set_hidden(meta_lv);
+		}
+
+		fa += stripes;
 	}
 	seg->area_len += extents;
 	seg->len += extents;
@@ -2206,22 +2460,40 @@ int lv_extend(struct logical_volume *lv,
 	      struct dm_list *allocatable_pvs, alloc_policy_t alloc)
 {
 	int r = 1;
+	int allocate_raid_logs = 0;
 	struct alloc_handle *ah;
+	uint32_t dev_count = mirrors * stripes + segtype->parity_devs;
+
+	log_very_verbose("Extending segment type, %s", segtype->name);
 
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, 0u, extents, segtype);
 
-	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0, 0,
+	if (segtype_is_raid(segtype) && !lv->le_count)
+		allocate_raid_logs = dev_count;
+
+	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
+				    allocate_raid_logs, region_size,
 				    extents, allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (!segtype_is_mirrored(segtype))
+	if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype))
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
 				   stripe_size, 0u, 0);
 	else {
+		/*
+		 * For RAID, all the devices are AREA_LV.
+		 * However, for 'mirror on stripe' using non-RAID targets,
+		 * the mirror legs are AREA_LV while the stripes underneath
+		 * are AREA_PV.  So if this is not RAID, reset dev_count to
+		 * just 'mirrors' - the necessary sub_lv count.
+		 */
+		if (!segtype_is_raid(segtype))
+			dev_count = mirrors;
+
 		if (!lv->le_count &&
-		    !_lv_insert_empty_sublvs(lv, segtype,
-					     region_size, mirrors)) {
+		    !_lv_insert_empty_sublvs(lv, segtype, stripe_size,
+					     region_size, dev_count)) {
 			log_error("Failed to insert layer for %s", lv->name);
 			alloc_destroy(ah);
 			return 0;
@@ -2697,6 +2969,12 @@ int lv_remove_single(struct cmd_context 
 		return 0;
 	}
 
+	if (lv->status & (RAID_META | RAID_IMAGE)) {
+		log_error("Can't remove logical volume %s used as RAID device",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
@@ -3485,8 +3763,11 @@ int lv_create_single(struct volume_group
 		return 0;
 	}
 
-	if (lp->mirrors > 1 && !(vg->fid->fmt->features & FMT_SEGMENTS)) {
-		log_error("Metadata does not support mirroring.");
+	if ((segtype_is_mirrored(lp->segtype) ||
+	     segtype_is_raid(lp->segtype)) &&
+	    !(vg->fid->fmt->features & FMT_SEGMENTS)) {
+		log_error("Metadata does not support %s.",
+			  segtype_is_raid(lp->segtype) ? "RAID" : "mirroring");
 		return 0;
 	}
 
@@ -3619,9 +3900,12 @@ int lv_create_single(struct volume_group
 		return 0;
 	}
 
-	if (lp->mirrors > 1 && !activation()) {
-		log_error("Can't create mirror without using "
-			  "device-mapper kernel driver.");
+	if ((segtype_is_mirrored(lp->segtype) ||
+	     segtype_is_raid(lp->segtype)) && !activation()) {
+		log_error("Can't create %s without using "
+			  "device-mapper kernel driver.",
+			  segtype_is_raid(lp->segtype) ? lp->segtype->name :
+			  "mirror");
 		return 0;
 	}
 
@@ -3641,18 +3925,16 @@ int lv_create_single(struct volume_group
 		}
 	}
 
-	if (lp->mirrors > 1) {
+	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
 		init_mirror_in_sync(lp->nosync);
 
 		if (lp->nosync) {
-			log_warn("WARNING: New mirror won't be synchronised. "
-				  "Don't read what you didn't write!");
+			log_warn("WARNING: New %s won't be synchronised. "
+				 "Don't read what you didn't write!",
+				 segtype_is_raid(lp->segtype) ?
+				 lp->segtype->name : "mirror");
 			status |= LV_NOTSYNCED;
 		}
-
-		lp->segtype = get_segtype_from_string(cmd, "mirror");
-		if (!lp->segtype)
-			return_0;
 	}
 
 	if (!(lv = lv_create_empty(lp->lv_name ? lp->lv_name : "lvol%d", NULL,
@@ -3675,15 +3957,18 @@ int lv_create_single(struct volume_group
 	if (!dm_list_empty(&lp->tags))
 		dm_list_splice(&lv->tags, &lp->tags);
 
-	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       lp->mirrors,
-		       adjusted_mirror_region_size(vg->extent_size,
-						   lp->extents,
-						   lp->region_size),
+	lp->region_size = adjusted_mirror_region_size(vg->extent_size,
+						      lp->extents,
+						      lp->region_size);
+
+	if (!lv_extend(lv, lp->segtype,
+		       lp->stripes, lp->stripe_size,
+		       lp->mirrors, lp->region_size,
 		       lp->extents, lp->pvh, lp->alloc))
 		return_0;
 
-	if ((lp->mirrors > 1) && lp->log_count) {
+	if (lp->log_count &&
+	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
 		if (!add_mirror_log(cmd, lv, lp->log_count,
 				    first_seg(lv)->region_size,
 				    lp->pvh, lp->alloc)) {
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -46,6 +46,15 @@
 #define EXPORTED_VG          	0x00000002U	/* VG PV */
 #define RESIZEABLE_VG        	0x00000004U	/* VG */
 
+/*
+ * We only have a few open flag spots left, 0x00000?00U for example.
+ * Since the RAID flags are LV (and seg) only and the above three
+ * are VG/PV only, I will reuse those flags.
+ */
+#define RAID                    0x00000001U	/* LV */
+#define RAID_META               0x00000002U	/* LV */
+#define RAID_IMAGE              0x00000004U	/* LV */
+
 /* May any free extents on this PV be used or must they be left free? */
 #define ALLOCATABLE_PV         	0x00000008U	/* PV */
 
@@ -293,7 +302,7 @@ struct lv_segment {
 	uint64_t status;
 
 	/* FIXME Fields depend on segment type */
-	uint32_t stripe_size;
+	uint32_t stripe_size;   /* For stripe and RAID - in sectors */
 	uint32_t area_count;
 	uint32_t area_len;
 	uint32_t chunk_size;	/* For snapshots - in sectors */
@@ -309,6 +318,7 @@ struct lv_segment {
 	struct dm_list tags;
 
 	struct lv_segment_area *areas;
+	struct lv_segment_area *meta_areas; /* For RAID */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
 	struct logical_volume *rlog_lv;	/* For replicators */
@@ -320,6 +330,7 @@ struct lv_segment {
 #define seg_type(seg, s)	(seg)->areas[(s)].type
 #define seg_pv(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv
 #define seg_lv(seg, s)		(seg)->areas[(s)].u.lv.lv
+#define seg_metalv(seg, s)	(seg)->meta_areas[(s)].u.lv.lv
 
 struct pe_range {
 	struct dm_list list;
Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c
+++ LVM2/lib/activate/dev_manager.c
@@ -737,6 +737,7 @@ int dev_manager_mirror_percent(struct de
 {
 	char *name;
 	const char *dlid;
+	const char *target_type = first_seg(lv)->segtype->name;
 	const char *layer = (lv_is_origin(lv)) ? "real" : NULL;
 
 	/*
@@ -752,8 +753,9 @@ int dev_manager_mirror_percent(struct de
 		return 0;
 	}
 
-	log_debug("Getting device mirror status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
+	log_debug("Getting device %s status percentage for %s",
+		  target_type, name);
+	if (!(_percent(dm, name, dlid, target_type, wait, lv, percent,
 		       event_nr, 0)))
 		return_0;
 
@@ -1177,17 +1179,26 @@ int add_areas_line(struct dev_manager *d
 				return_0;
 		} else if (seg_type(seg, s) == AREA_PV)
 			dm_tree_node_add_target_area(node,
-							dev_name(seg_dev(seg, s)),
-							NULL,
-							(seg_pv(seg, s)->pe_start +
-							 (extent_size * seg_pe(seg, s))));
+						     dev_name(seg_dev(seg, s)),
+						     NULL,
+						     (seg_pv(seg, s)->pe_start +
+						      (extent_size * seg_pe(seg, s))));
 		else if (seg_type(seg, s) == AREA_LV) {
+			if (seg_is_raid(seg)) {
+				dlid = build_dm_uuid(dm->mem,
+						     seg_metalv(seg, s)->lvid.s,
+						     NULL);
+				if (!dlid)
+					return_0;
+				dm_tree_node_add_target_area(node, NULL, dlid,
+							     extent_size * seg_metale(seg, s));
+			}
 			if (!(dlid = build_dm_uuid(dm->mem,
 						   seg_lv(seg, s)->lvid.s,
 						   NULL)))
 				return_0;
 			dm_tree_node_add_target_area(node, NULL, dlid,
-							extent_size * seg_le(seg, s));
+						     extent_size * seg_le(seg, s));
 		} else {
 			log_error(INTERNAL_ERROR "Unassigned area found in LV %s.",
 				  seg->lv->name);
@@ -1404,11 +1415,16 @@ static int _add_segment_to_dtree(struct 
 			return_0;
 	} else {
 		/* Add any LVs used by this segment */
-		for (s = 0; s < seg->area_count; s++)
+		for (s = 0; s < seg->area_count; s++) {
 			if ((seg_type(seg, s) == AREA_LV) &&
 			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
 						   NULL)))
 				return_0;
+			if (seg_is_raid(seg) &&
+			    !_add_new_lv_to_dtree(dm, dtree,
+						  seg_metalv(seg, s), NULL))
+				return_0;
+		}
 	}
 
 	/* Now we've added its dependencies, we can add the target itself */
Index: LVM2/lib/format_text/flags.c
===================================================================
--- LVM2.orig/lib/format_text/flags.c
+++ LVM2/lib/format_text/flags.c
@@ -56,6 +56,9 @@ static const struct flag _lv_flags[] = {
 	{PVMOVE, "PVMOVE", STATUS_FLAG},
 	{LOCKED, "LOCKED", STATUS_FLAG},
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
+	{RAID, NULL, 0},
+	{RAID_META, NULL, 0},
+	{RAID_IMAGE, NULL, 0},
 	{MIRROR_IMAGE, NULL, 0},
 	{MIRROR_LOG, NULL, 0},
 	{MIRRORED, NULL, 0},
Index: LVM2/lib/format_text/import_vsn1.c
===================================================================
--- LVM2.orig/lib/format_text/import_vsn1.c
+++ LVM2/lib/format_text/import_vsn1.c
@@ -362,10 +362,13 @@ static int _read_segment(struct dm_pool 
 	if (seg_is_mirrored(seg))
 		lv->status |= MIRRORED;
 
+	if (seg_is_raid(seg))
+		lv->status |= RAID;
+
 	if (seg_is_virtual(seg))
 		lv->status |= VIRTUAL;
 
-	if (_is_converting(lv))
+	if (!seg_is_raid(seg) && _is_converting(lv))
 		lv->status |= CONVERTING;
 
 	return 1;
Index: LVM2/lib/metadata/merge.c
===================================================================
--- LVM2.orig/lib/metadata/merge.c
+++ LVM2/lib/metadata/merge.c
@@ -68,7 +68,7 @@ int check_lv_segments(struct logical_vol
 {
 	struct lv_segment *seg, *seg2;
 	uint32_t le = 0;
-	unsigned seg_count = 0, seg_found;
+	unsigned seg_count = 0, seg_found, seg_not_found;
 	uint32_t area_multiplier, s;
 	struct seg_list *sl;
 	int error_count = 0;
@@ -94,18 +94,22 @@ int check_lv_segments(struct logical_vol
 			inc_error_count;
 		}
 
-		if (complete_vg && seg->log_lv) {
-			if (!seg_is_mirrored(seg)) {
-				log_error("LV %s: segment %u has log LV but "
-					  "is not mirrored",
-					  lv->name, seg_count);
-				inc_error_count;
-			}
+		if (complete_vg && seg->log_lv &&
+		    !seg_is_mirrored(seg) && !(seg->status & RAID_IMAGE)) {
+			log_error("LV %s: segment %u log LV %s is not a "
+				  "mirror log or a RAID image",
+				  lv->name, seg_count, seg->log_lv->name);
+			inc_error_count;
+		}
 
+		/*
+		 * Check mirror log - which is attached to the mirrored seg
+		 */
+		if (complete_vg && seg->log_lv && seg_is_mirrored(seg)) {
 			if (!(seg->log_lv->status & MIRROR_LOG)) {
 				log_error("LV %s: segment %u log LV %s is not "
 					  "a mirror log",
-					   lv->name, seg_count, seg->log_lv->name);
+					  lv->name, seg_count, seg->log_lv->name);
 				inc_error_count;
 			}
 
@@ -113,7 +117,7 @@ int check_lv_segments(struct logical_vol
 			    find_mirror_seg(seg2) != seg) {
 				log_error("LV %s: segment %u log LV does not "
 					  "point back to mirror segment",
-					   lv->name, seg_count);
+					  lv->name, seg_count);
 				inc_error_count;
 			}
 		}
@@ -186,9 +190,15 @@ int check_lv_segments(struct logical_vol
 				}
  */
 				seg_found = 0;
-				dm_list_iterate_items(sl, &seg_lv(seg, s)->segs_using_this_lv)
+				seg_not_found = 0;
+				dm_list_iterate_items(sl, &seg_lv(seg, s)->segs_using_this_lv) {
 					if (sl->seg == seg)
 						seg_found++;
+					else if (++seg_not_found > 100) {
+						log_error("Corrupted segs_using_this_lv list in %s", seg_lv(seg, s)->name);
+						break;
+					}
+				}
 				if (!seg_found) {
 					log_error("LV %s segment %d uses LV %s,"
 						  " but missing ptr from %s to %s",
@@ -217,6 +227,8 @@ int check_lv_segments(struct logical_vol
 				continue;
 			if (lv == seg_lv(seg, s))
 				seg_found++;
+			if (seg_is_raid(seg) && (lv == seg_metalv(seg, s)))
+				seg_found++;
 		}
 		if (seg_is_replicator_dev(seg)) {
 			dm_list_iterate_items(rsite, &seg->replicator->rsites) {
Index: LVM2/lib/format_text/export.c
===================================================================
--- LVM2.orig/lib/format_text/export.c
+++ LVM2/lib/format_text/export.c
@@ -544,10 +544,25 @@ int out_areas(struct formatter *f, const
 			     (s == seg->area_count - 1) ? "" : ",");
 			break;
 		case AREA_LV:
-			outf(f, "\"%s\", %u%s",
-			     seg_lv(seg, s)->name,
-			     seg_le(seg, s),
+			if (!(seg->status & RAID)) {
+				outf(f, "\"%s\", %u%s",
+				     seg_lv(seg, s)->name,
+				     seg_le(seg, s),
+				     (s == seg->area_count - 1) ? "" : ",");
+				continue;
+			}
+
+			/* RAID devices are laid-out in metadata/data pairs */
+			if (!(seg_lv(seg, s)->status & RAID_IMAGE) ||
+			    !(seg_metalv(seg, s)->status & RAID_META)) {
+				log_error("RAID segment has non-RAID areas");
+				return 0;
+			}
+
+			outf(f, "\"%s\", \"%s\"%s",
+			     seg_metalv(seg, s)->name, seg_lv(seg, s)->name,
 			     (s == seg->area_count - 1) ? "" : ",");
+
 			break;
 		case AREA_UNASSIGNED:
 			return 0;
Index: LVM2/lib/metadata/metadata.h
===================================================================
--- LVM2.orig/lib/metadata/metadata.h
+++ LVM2/lib/metadata/metadata.h
@@ -230,6 +230,7 @@ int mdas_empty_or_ignored(struct dm_list
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
 #define seg_pe(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pe
 #define seg_le(seg, s)		(seg)->areas[(s)].u.lv.le
+#define seg_metale(seg, s)	(seg)->meta_areas[(s)].u.lv.le
 
 struct name_list {
 	struct dm_list list;


