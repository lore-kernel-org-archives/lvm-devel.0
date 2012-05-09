From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 May 2012 12:17:09 -0000
Subject: LVM2 ./WHATS_NEW man/lvconvert.8.in tools/comm ...
Message-ID: <20120509121709.29532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-05-09 12:17:08

Modified files:
	.              : WHATS_NEW 
	man            : lvconvert.8.in 
	tools          : commands.h lvconvert.c 

Log message:
	Initial support for lvconvert for thin pool volumes.
	
	Support has many limitations and lots of FIXMEs inside,
	however it makes initial task when user creates a separate LV for
	thin pool data and thin metadata already usable, so let's enable
	it for testing.
	
	Easiest API:
	
	lvconvert --chunksize XX --thinpool data_lv  metadata_lv
	
	More functionality extensions will follow up.
	
	TODO: Code needs some rework since a lot of same code is getting copied.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2398&r2=1.2399
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.190&r2=1.191

--- LVM2/WHATS_NEW	2012/05/09 12:12:21	1.2398
+++ LVM2/WHATS_NEW	2012/05/09 12:17:06	1.2399
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Add initial support for thin pool lvconvert.
   Fix lvrename for thin volumes (regression in for_each_sub_lv() 2.02.89).
   Fix up-convert when mirror activation is controled by volume_list and tags.
   Disallow snapshots of mirror segment type.
--- LVM2/man/lvconvert.8.in	2012/04/11 12:42:10	1.25
+++ LVM2/man/lvconvert.8.in	2012/05/09 12:17:06	1.26
@@ -59,6 +59,21 @@
 .RB [ \-\-version ]
 .IR LogicalVolume [ Path ]...
 .sp
+.B lvconvert \-\-thinpool
+.IR ThinPoolLogicalVolume { Name | Path }
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
+.RB [[ \-\-poolmetadatasize
+.IR MetadataSize [ bBsSkKmMgG ]
+.RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]]
+|
+.IR ThinMetadataLogicalVolume { Name | Path }]
+.RB [ \-Z | \-\-zero
+.RI { y | n }]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.sp
 .B lvconvert \-\-repair
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
--- LVM2/tools/commands.h	2012/03/27 11:04:47	1.175
+++ LVM2/tools/commands.h	2012/05/09 12:17:07	1.176
@@ -138,12 +138,20 @@
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-v|--verbose]\n"
-   "\tLogicalVolume[Path]\n",
+   "\tLogicalVolume[Path]\n\n"
+
+   "lvconvert "
+   "--thinpool ThinPoolLogicalVolume[Path]\n"
+   "\t[--chunksize size]\n"
+   "\t[[--poolmetadatasize size] | ThinMetadataLogicalVolume[Path]]\n"
+   "\t[-z|--zero {y|n}]\n"
+   "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
    regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
    trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
+   chunksize_ARG, poolmetadatasize_ARG, thinpool_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
--- LVM2/tools/lvconvert.c	2012/04/19 21:50:37	1.190
+++ LVM2/tools/lvconvert.c	2012/05/09 12:17:07	1.191
@@ -53,6 +53,10 @@
 	struct dm_list *replace_pvh;
 
 	struct logical_volume *lv_to_poll;
+
+	uint64_t poolmetadata_size; /* thin pool */
+	const char *pool_data_lv_name;
+	/* pool_metadata_lv_name is lv_name */
 };
 
 static int _lvconvert_name_params(struct lvconvert_params *lp,
@@ -85,6 +89,15 @@
 			lp->origin = ptr + 1;
 	}
 
+	if (!*pargc && lp->pool_data_lv_name) {
+		if (!lp->vg_name || !validate_name(lp->vg_name)) {
+			log_error("Please provide a valid volume group name.");
+			return 0;
+		}
+		lp->lv_name = lp->pool_data_lv_name;
+		return 1; /* Create metadata LV on it's own */
+	}
+
 	if (!*pargc) {
 		log_error("Please provide logical volume path");
 		return 0;
@@ -120,6 +133,11 @@
 		return 0;
 	}
 
+	if (lp->pool_data_lv_name && lp->lv_name && lp->poolmetadata_size) {
+		log_error("Please specify either metadata logical volume or its size.");
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -159,6 +177,29 @@
 		return 0;
 	}
 
+	if (arg_count(cmd, thinpool_ARG)) {
+		if (arg_count(cmd, merge_ARG)) {
+			log_error("--thinpool and --merge are mutually exlusive.");
+			return 0;
+		}
+		if (arg_count(cmd, mirrors_ARG)) {
+			log_error("--thinpool and --mirrors are mutually exlusive.");
+			return 0;
+		}
+		if (arg_count(cmd, repair_ARG)) {
+			log_error("--thinpool and --repair are mutually exlusive.");
+			return 0;
+		}
+		if (arg_count(cmd, snapshot_ARG)) {
+			log_error("--thinpool and --snapshot are mutually exlusive.");
+			return 0;
+		}
+		if (arg_count(cmd, splitmirrors_ARG)) {
+			log_error("--thinpool and --splitmirrors are mutually exlusive.");
+			return 0;
+		}
+	}
+
 	/*
 	 * The '--splitmirrors n' argument is equivalent to '--mirrors -n'
 	 * (note the minus sign), except that it signifies the additional
@@ -280,6 +321,67 @@
 								    tmp_str)))
 				return_0;
 		}
+	} else if (arg_count(cmd, thinpool_ARG)) {
+		if (!(lp->pool_data_lv_name = arg_str_value(cmd, thinpool_ARG, NULL))) {
+			log_error("Missing pool logical volume name.");
+			return 0;
+		}
+
+		if (arg_count(cmd, poolmetadatasize_ARG)) {
+			if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+				log_error("Negative pool metadata size is invalid.");
+				return 0;
+			}
+			lp->poolmetadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
+
+			if (lp->poolmetadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+				if (arg_count(cmd, poolmetadatasize_ARG))
+					log_warn("WARNING: Maximum supported pool metadata size is 16GB.");
+				lp->poolmetadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+			} else if (lp->poolmetadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+				if (arg_count(cmd, poolmetadatasize_ARG))
+					log_warn("WARNING: Minimum supported pool metadata size is 2M.");
+				lp->poolmetadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
+			}
+
+			log_verbose("Setting pool metadata size to %" PRIu64 " sectors.",
+				    lp->poolmetadata_size);
+		}
+
+		if (arg_count(cmd, chunksize_ARG)) {
+			if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
+				log_error("Negative chunk size is invalid.");
+				return 0;
+			}
+			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG,
+							DM_THIN_MIN_DATA_BLOCK_SIZE);
+
+			if ((lp->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+			    (lp->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+				log_error("Chunk size must be in the range %uK to %uK.",
+					  (DM_THIN_MIN_DATA_BLOCK_SIZE / 2),
+					  (DM_THIN_MAX_DATA_BLOCK_SIZE / 2));
+				return 0;
+			}
+		} else
+			lp->chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+		log_verbose("Setting pool metadata chunk size to %u sectors.",
+			    lp->chunk_size);
+
+		if (arg_count(cmd, zero_ARG))
+			lp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+
+		/* If --thinpool contains VG name, extract it. */
+		if ((tmp_str = strchr(lp->pool_data_lv_name, (int) '/'))) {
+			if (!(lp->vg_name = extract_vgname(cmd, lp->pool_data_lv_name)))
+				return 0;
+			/* Strip VG from pool */
+			lp->pool_data_lv_name = tmp_str + 1;
+		}
+
+		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "thin-pool"));
+		if (!lp->segtype)
+			return_0;
 	} else { /* Mirrors (and some RAID functions) */
 		if (arg_count(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with "
@@ -1723,6 +1825,116 @@
 	return r;
 }
 
+static int _lvconvert_thinpool(struct cmd_context *cmd,
+			       struct logical_volume *metadata_lv,
+			       struct lvconvert_params *lp)
+{
+	int r = 0;
+	char *name;
+	int len;
+	int was_active;
+	struct lv_segment *seg;
+	struct logical_volume *data_lv;
+	struct logical_volume *pool_lv =
+		(lp->pool_data_lv_name == lp->lv_name) ?
+		metadata_lv : find_lv(metadata_lv->vg,
+				      lp->pool_data_lv_name);
+
+	if (!pool_lv) {
+		log_error("Can't find pool logical volume %s.", pool_lv->name);
+		goto_out;
+	}
+
+	if ((pool_lv != metadata_lv)) {
+		if (!lv_is_visible(metadata_lv)) {
+			log_error("Can't use hidden logical volume %s/%s for thin pool metadata.",
+				  metadata_lv->vg->name, metadata_lv->name);
+			goto out;
+		}
+		if (lv_is_thin_pool(metadata_lv)) {
+			log_error("Can't use thin pool logical volume %s/%s for thin pool metadata.",
+				  metadata_lv->vg->name, metadata_lv->name);
+			goto out;
+		}
+		/* FIXME: any more types prohibited here ? */
+		if (!deactivate_lv(cmd, metadata_lv)) {
+			log_error("Can't deactivate logical volume %s/%s.",
+				  metadata_lv->vg->name, metadata_lv->name);
+			goto out;
+		}
+		/* FIXME: initialize metadata LV! */
+	} else {
+		/* FIXME: add creation of metadata LV */
+	}
+
+	if (!lv_is_visible(pool_lv)) {
+		log_error("Can't use hidden logical volume %s/%s for thin pool data.",
+			  metadata_lv->vg->name, metadata_lv->name);
+		goto out;
+	}
+	if (lv_is_thin_pool(pool_lv)) {
+		log_error("Can't use thin pool logical volume %s/%s for thin pool data.",
+			  metadata_lv->vg->name, metadata_lv->name);
+		goto out;
+	}
+	/* FIXME: any more types prohibited here ? */
+	if ((was_active = lv_is_active(pool_lv))) {
+		if (!deactivate_lv(cmd, pool_lv)) {
+			log_error("Can't deactivate logical volume %s/%s.",
+				  pool_lv->vg->name, pool_lv->name);
+			goto out;
+		}
+	}
+
+	/* FIXME: common code with metadata/thin_manip.c  extend_pool() */
+	if (!(data_lv = insert_layer_for_lv(pool_lv->vg->cmd, pool_lv,
+					    pool_lv->status, "_tdata")))
+		return_0;
+
+	seg = first_seg(pool_lv);
+	seg->segtype = lp->segtype;
+	seg->lv->status |= THIN_POOL;
+
+	seg->chunk_size = lp->chunk_size;
+	seg->zero_new_blocks = lp->zero ? 1 : 0;
+	seg->low_water_mark = 0;
+
+	len = strlen(pool_lv->name) + 16;
+	if (!(name = dm_pool_alloc(pool_lv->vg->vgmem, len))) {
+		log_error("Cannot allocate new name.");
+		return 0;
+	}
+
+	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
+		return_0;
+	metadata_lv->name = name;
+
+	if (!attach_pool_metadata_lv(seg, metadata_lv))
+		return_0;
+
+	/* Drop reference as attach_pool_data_lv() takes it again */
+	remove_seg_from_segs_using_this_lv(data_lv, seg);
+	if (!attach_pool_data_lv(seg, data_lv))
+		return_0;
+
+	/* store vg on disk(s) */
+	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
+		return_0;
+
+	log_print("Converted %s/%s to thin pool.",
+		  pool_lv->vg->name, pool_lv->name);
+	if (was_active && !activate_lv(cmd, pool_lv)) {
+		log_error("Failed to activate pool logical volume %s/%s.",
+			  pool_lv->vg->name, pool_lv->name);
+		goto out;
+	}
+
+	r = 1;
+out:
+	backup(pool_lv->vg);
+	return r;
+}
+
 static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle)
 {
@@ -1831,6 +2043,15 @@
 		/* If repairing and using policies, remove missing PVs from VG */
 		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
+	} else if (arg_count(cmd, thinpool_ARG)) {
+		if (!archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		if (!_lvconvert_thinpool(cmd, lv, lp)) {
+			stack;
+			return ECMD_FAILED;
+		}
 	}
 
 	return ECMD_PROCESSED;


