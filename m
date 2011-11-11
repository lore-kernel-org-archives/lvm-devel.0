From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Nov 2011 16:39:31 +0100
Subject: [PATCH] LVM: New lvconvert option, '--replace'
In-Reply-To: <1320964626.7209.3.camel@f14.redhat.com>
References: <1320964626.7209.3.camel@f14.redhat.com>
Message-ID: <4EBD41B3.7040000@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10.11.2011 23:37, Jonathan Brassow napsal(a):
>  brassow
> 
> Support the ability to replace specific devices in a RAID array.
> 
> RAID is not like traditional LVM mirroring.  LVM mirroring required failed
> devices to be removed or the logical volume would simply hang.  RAID arrays can
> keep on running with failed devices.  In fact, for RAID types other than RAID1,
> removing a device would mean substituting an error target or converting to a
> lower level RAID (e.g. RAID6 -> RAID5, or RAID4/5 to RAID0).  Therefore, rather
> than removing a failed device unconditionally and potentially allocating a
> replacement, RAID allows the user to "replace" a device with a new one.  This
> approach is a 1-step solution vs the current 2-step solution.
> 
> example> lvconvert --replace <dev_to_remove> vg/lv [possible_replacement_PVs]
> 
> '--replace' can be specified more than once.
> 
> eg> lvconvert --replace /dev/sdb1 --replace /dev/sdc1 vg/lv
> 
> +			sprintf(tmp_names[s], "%s_rmeta_%u", lv->name, s);

if (dm_snprintf() < 0) error

> +			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,
> +						    lvl->lv->status)) {
> +				log_error("Failed to add %s to %s",
> +					  lvl->lv->name, lv->name);
> +				return 0;
> +			}
> +			lv_set_hidden(lvl->lv);
> +
> +			/* Adjust the new data LV name */
> +			lvl = dm_list_item(dm_list_first(&new_data_lvs),
> +					   struct lv_list);
> +			dm_list_del(&lvl->list);
> +			tmp_names[sd] = dm_pool_alloc(lv->vg->vgmem,
> +						     strlen(lvl->lv->name) + 1);
> +			if (!tmp_names[sd])
> +				return_0;
> +			sprintf(tmp_names[sd], "%s_rimage_%u", lv->name, s);
> +			if (!set_lv_segment_area_lv(raid_seg, s, lvl->lv, 0,
> +						    lvl->lv->status)) {
> +				log_error("Failed to add %s to %s",
> +					  lvl->lv->name, lv->name);
> +				return 0;
> +			}
> +			lv_set_hidden(lvl->lv);
> +		}
> +	}
> +
> +	if (!vg_write(lv->vg)) {
> +		log_error("Failed to write changes to %s in %s",
> +			  lv->name, lv->vg->name);
> +		return 0;
> +	}
> +
> +	if (!suspend_lv(lv->vg->cmd, lv)) {
> +		log_error("Failed to suspend %s/%s before committing changes",
> +			  lv->vg->name, lv->name);
> +		return 0;
> +	}
> +
> +	if (!vg_commit(lv->vg)) {
> +		log_error("Failed to commit changes to %s in %s",
> +			  lv->name, lv->vg->name);
> +		return 0;
> +	}
> +
> +	if (!resume_lv(lv->vg->cmd, lv)) {
> +		log_error("Failed to resume %s/%s after committing changes",
> +			  lv->vg->name, lv->name);
> +		return 0;
> +	}


I think its about the time to finaly make this sequence a common function :)
(vg_write(), suspend(), vg_commit(), resume_lv())



> +
> +	sync_local_dev_names(lv->vg->cmd);

Hmm - you shouldn't need to do this
(It's been bug before, where it has not been
implicitely used in deactivate_lv())

So for now - unless you have trace which shows,
there is still a problem - do not add them.
(In fact some of those added, should be removed,
since call of  deactivate_lv() is doing approriate
synchronization at the right place (i.e. on clmvd
in clustered case).

> +	dm_list_iterate_items(lvl, &old_meta_lvs) {
> +		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
> +			return_0;
> +		if (!lv_remove(lvl->lv))
> +			return_0;
> +	}
> +	dm_list_iterate_items(lvl, &old_data_lvs) {
> +		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
> +			return_0;
> +		if (!lv_remove(lvl->lv))
> +			return_0;
> +	}


Zdenek


