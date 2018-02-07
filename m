From: Eric Ren <zren@suse.com>
Date: Wed, 7 Feb 2018 15:17:00 +0800
Subject: master - pvmove: reinstantiate clustered pvmove
In-Reply-To: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
References: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
Message-ID: <5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Zdenek,

I've tried this patch with clvmd and cmirrord running, and all LVs in 
clustered VG being activated
on both nodes. But, pvmove still cannot work as expect - move data on 
underlying PV of the the
non-exclusive activated LV.

==========
tw1:~ # pgrep -a mirrord
11931 cmirrord
tw1:~ # pgrep -a clvmd
11748 /usr/sbin/clvmd -T90 -d0

tw1:~ # vgs -o+vg_clustered vgtest2
 ??? VG????? #PV #LV #SN Attr?? VSize VFree Clustered
 ??? vgtest2?? 2?? 2?? 0 wz--nc 9.30g 6.30g? clustered
tw1:~ # lvs -o+lv_active_exclusively,lv_active_locally vgtest2
 ??? LV?? VG????? Attr?????? LSize Pool Origin Data%? Meta%? Move Log 
Cpy%Sync Convert ActExcl??? ActLocal
 ??? lv1? vgtest2 -wi-a----- 2.00g active locally
 ??? lv2? vgtest2 -wi-a----- 1.00g active locally
tw1:~ # pvs -S vg_name=vgtest2
 ??? PV???????? VG????? Fmt? Attr PSize PFree
 ??? /dev/vdb1? vgtest2 lvm2 a--? 4.65g 4.65g
 ??? /dev/vdb2? vgtest2 lvm2 a--? 4.65g 1.65g

tw1:~ # pvmove /dev/vdb2
 ??? Cannot move in clustered VG vgtest2, clustered mirror (cmirror) not 
detected and LVs are activated non-exclusively.
============


GDB it a little bit. The problem seems because:

_pvmove_target_present(cmd, 1)


will always return 0 - "not found".

During one pvmove command, the _pvmove_target_present() is invoked 
twice. At first call,
"segtype->ops->target_present()", i.e _mirrored_target_present() will 
set "_mirrored_checked = 0".

At the second call, _mirrored_target_present() will not go through the 
following code to get the
"_mirror_attributes":

"""
400 static int _mirrored_target_present(struct cmd_context *cmd,
401???????????????????????????????????? const struct lv_segment *seg,
402???????????????????????????????????? unsigned *attributes)
...
442 #ifdef CMIRRORD_PIDFILE
443???????????????? /*
444????????????????? * The cluster mirror log daemon must be running,
445????????????????? * otherwise, the kernel module will fail to make
446????????????????? * contact.
447????????????????? */
448???????????????? if (cmirrord_is_running()) {
449???????????????????????? struct utsname uts;
450???????????????????????? unsigned kmaj, kmin, krel;
451???????????????????????? /*
452????????????????????????? * The dm-log-userspace module was added to the
453????????????????????????? * 2.6.31 kernel.
454????????????????????????? */
455???????????????????????? if (!uname(&uts) &&
456???????????????????????????? (sscanf(uts.release, "%u.%u.%u", &kmaj, 
&kmin, &krel) == 3) &&
457???????????????????????????? KERNEL_VERSION(kmaj, kmin, krel) < 
KERNEL_VERSION(2, 6, 31)) {
458???????????????????????????????? if (module_present(cmd, 
MODULE_NAME_LOG_CLUSTERED))
459???????????????????????????????? _mirror_attributes |= 
MIRROR_LOG_CLUSTERED;
460???????????????????????? } else if (module_present(cmd, 
MODULE_NAME_LOG_USERSPACE))
461???????????????????????????????? _mirror_attributes |= 
MIRROR_LOG_CLUSTERED;
462
463???????????????????????? if (!(_mirror_attributes & 
MIRROR_LOG_CLUSTERED))
464???????????????????????????????? log_verbose("Cluster mirror log 
module is not available.");
465???????????????? } else
466???????????????????????? log_verbose("Cluster mirror log daemon is 
not running.");
467 #else
468???????????????? log_verbose("Cluster mirror log daemon not included 
in build.");
469 #endif
...
"""

even if it is asked to back the "target attributes" by 
_pvmove_target_present(cmd, 1).
As result, _pvmove_target_present(cmd, 1) will always return "0", 
because the "attributes"
is empty.

"""
 ?40 static int _pvmove_target_present(struct cmd_context *cmd, int 
clustered)
 ?41 {
 ?42???????? const struct segment_type *segtype;
 ?43???????? unsigned attr = 0;
 ?44???????? int found = 1;
 ?45???????? static int _clustered_found = -1;
 ?46
 ?47???????? if (clustered && _clustered_found >= 0)
 ?48???????????????? return _clustered_found;
 ?49
 ?50???????? if (!(segtype = get_segtype_from_string(cmd, 
SEG_TYPE_NAME_MIRROR)))
 ?51???????????????? return_0;
 ?52
 ?53???????? if (activation() && segtype->ops->target_present &&
 ?54???????????? !segtype->ops->target_present(cmd, NULL, clustered ? 
&attr : NULL))
 ?55???????????????? found = 0;
 ?56
 ?57???????? if (activation() && clustered) {
 ?58???????????????? if (found && (attr & MIRROR_LOG_CLUSTERED))
 ?59???????????????????????? _clustered_found = found = 1;
 ?60???????????????? else
 ?61???????????????????????? _clustered_found = found = 0;
 ?62???????? }
 ?63
 ?64???????? return found;
 ?65 }
"""

Could you take a look at this?

Thanks!
Eric



On 02/02/2018 04:58 AM, Zdenek Kabelac wrote:
> Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=083c221cbebccd8ea893e87f17c69fba378d8645
> Commit:        083c221cbebccd8ea893e87f17c69fba378d8645
> Parent:        34fb5202bdb3172a44fb3d957e184df4fb0412d8
> Author:        Zdenek Kabelac <zkabelac@redhat.com>
> AuthorDate:    Wed Jan 31 10:53:09 2018 +0100
> Committer:     Zdenek Kabelac <zkabelac@redhat.com>
> CommitterDate: Thu Feb 1 21:55:20 2018 +0100
>
> pvmove: reinstantiate clustered pvmove
>
> In fact  pvmove does support  'clustered-core' target for clustered
> pvmove of LVs activated on multiple nodes.
>
> This patch restores support for activation of pvmove on all nodes
> for LVs that are also activate on all nodes.
> ---
>   WHATS_NEW               |    1 +
>   lib/activate/activate.c |    1 -
>   lib/locking/locking.c   |   12 +++--
>   lib/locking/locking.h   |    2 +-
>   tools/pvmove.c          |  109 +++++++++++++++++++++++++++++++++++-----------
>   5 files changed, 93 insertions(+), 32 deletions(-)
>
> diff --git a/WHATS_NEW b/WHATS_NEW
> index bc73cd7..75a147b 100644
> --- a/WHATS_NEW
> +++ b/WHATS_NEW
> @@ -1,5 +1,6 @@
>   Version 2.02.178 -
>   =====================================
> +  Restore pvmove support for wide-clustered active volumes (2.02.177).
>     Avoid non-exclusive activation of exclusive segment types.
>     Fix trimming sibling PVs when doing a pvmove of raid subLVs.
>     Preserve exclusive activation during thin snaphost merge.
> diff --git a/lib/activate/activate.c b/lib/activate/activate.c
> index 18cc7cf..7a37130 100644
> --- a/lib/activate/activate.c
> +++ b/lib/activate/activate.c
> @@ -2576,7 +2576,6 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
>   
>   	if (!laopts->exclusive &&
>   	    (lv_is_origin(lv) ||
> -	     lv_is_pvmove(lv) ||
>   	     seg_only_exclusive(first_seg(lv))))  {
>   		log_error(INTERNAL_ERROR "Trying non-exlusive activation of %s with "
>   			  "a volume type %s requiring exclusive activation.",
> diff --git a/lib/locking/locking.c b/lib/locking/locking.c
> index 8daa61e..1a3ce9d 100644
> --- a/lib/locking/locking.c
> +++ b/lib/locking/locking.c
> @@ -399,15 +399,19 @@ int activate_lv_excl(struct cmd_context *cmd, const struct logical_volume *lv)
>   }
>   
>   /* Lock a list of LVs */
> -int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs)
> +int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive)
>   {
>   	struct dm_list *lvh;
>   	struct lv_list *lvl;
>   
>   	dm_list_iterate_items(lvl, lvs) {
> -		if (!activate_lv_excl_local(cmd, lvl->lv)) {
> -			log_error("Failed to locally exclusively activate %s.",
> -				  display_lvname(lvl->lv));
> +		if (!exclusive && !lv_is_active_exclusive(lvl->lv)) {
> +			if (!activate_lv(cmd, lvl->lv)) {
> +				log_error("Failed to activate %s", display_lvname(lvl->lv));
> +				return 0;
> +			}
> +		} else if (!activate_lv_excl(cmd, lvl->lv)) {
> +			log_error("Failed to activate %s", display_lvname(lvl->lv));
>   			dm_list_uniterate(lvh, lvs, &lvl->list) {
>   				lvl = dm_list_item(lvh, struct lv_list);
>   				if (!deactivate_lv(cmd, lvl->lv))
> diff --git a/lib/locking/locking.h b/lib/locking/locking.h
> index 47841ed..f2fbb00 100644
> --- a/lib/locking/locking.h
> +++ b/lib/locking/locking.h
> @@ -262,6 +262,6 @@ int sync_dev_names(struct cmd_context* cmd);
>   
>   /* Process list of LVs */
>   struct volume_group;
> -int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs);
> +int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive);
>   
>   #endif
> diff --git a/tools/pvmove.c b/tools/pvmove.c
> index b3d1d89..cbd5cb8 100644
> --- a/tools/pvmove.c
> +++ b/tools/pvmove.c
> @@ -64,6 +64,16 @@ static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
>   	return found;
>   }
>   
> +static unsigned _pvmove_is_exclusive(struct cmd_context *cmd,
> +				     struct volume_group *vg)
> +{
> +	if (vg_is_clustered(vg))
> +		if (!_pvmove_target_present(cmd, 1))
> +			return 1;
> +
> +	return 0;
> +}
> +
>   /* Allow /dev/vgname/lvname, vgname/lvname or lvname */
>   static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
>   				   const char *arg)
> @@ -320,7 +330,8 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
>   						const char *lv_name,
>   						struct dm_list *allocatable_pvs,
>   						alloc_policy_t alloc,
> -						struct dm_list **lvs_changed)
> +						struct dm_list **lvs_changed,
> +						unsigned *exclusive)
>   {
>   	struct logical_volume *lv_mirr, *lv;
>   	struct lv_segment *seg;
> @@ -329,6 +340,8 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
>   	uint32_t log_count = 0;
>   	int lv_found = 0;
>   	int lv_skipped = 0;
> +	int lv_active_count = 0;
> +	int lv_exclusive_count = 0;
>   
>   	/* FIXME Cope with non-contiguous => splitting existing segments */
>   	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
> @@ -422,33 +435,54 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
>   		if (!lv_is_on_pvs(lv, source_pvl))
>   			continue;
>   
> -		seg = first_seg(lv);
> -		if (seg_is_raid(seg) || seg_is_mirrored(seg) ||
> -		    lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {
> -			/*
> -			 * Pass over top-level LVs - they were handled.
> -			 * Allow sub-LVs to proceed.
> -			 */
> -			continue;
> -		}
> -
>   		if (lv_is_locked(lv)) {
>   			lv_skipped = 1;
>   			log_print_unless_silent("Skipping locked LV %s.", display_lvname(lv));
>   			continue;
>   		}
>   
> -		if (vg_is_clustered(vg) &&
> -		    lv_is_visible(lv) &&
> -		    lv_is_active(lv) &&
> -		    !lv_is_active_exclusive_locally(lv)) {
> -			lv_skipped = 1;
> -			log_print_unless_silent("Skipping LV %s which is active, "
> -						"but not locally exclusively.",
> -						display_lvname(lv));
> -			continue;
> +		if (vg_is_clustered(vg) && lv_is_visible(lv)) {
> +			if (lv_is_active_exclusive_locally(lv)) {
> +				if (lv_active_count) {
> +					log_error("Cannot move in clustered VG %s "
> +						  "if some LVs are activated "
> +						  "exclusively while others don't.",
> +						  vg->name);
> +					return NULL;
> +				}
> +
> +				lv_exclusive_count++;
> +			} else if (lv_is_active(lv)) {
> +				if (seg_only_exclusive(first_seg(lv))) {
> +					lv_skipped = 1;
> +					log_print_unless_silent("Skipping LV %s which is active, "
> +								"but not locally exclusively.",
> +							display_lvname(lv));
> +					continue;
> +				}
> +
> +				if (*exclusive) {
> +					log_error("Cannot move in clustered VG %s, "
> +						  "clustered mirror (cmirror) not detected "
> +						  "and LVs are activated non-exclusively.",
> +						  vg->name);
> +					return NULL;
> +				}
> +
> +				lv_active_count++;
> +			}
>   		}
>   
> +		seg = first_seg(lv);
> +		if (seg_is_raid(seg) || seg_is_mirrored(seg) ||
> +		    seg_is_cache(seg) || seg_is_cache_pool(seg) ||
> +		    seg_is_thin(seg) || seg_is_thin_pool(seg))
> +			/*
> +			 * Pass over top-level LVs - they were handled.
> +			 * Allow sub-LVs to proceed.
> +			 */
> +			continue;
> +
>   		if (!_insert_pvmove_mirrors(cmd, lv_mirr, source_pvl, lv,
>   					    *lvs_changed))
>   			return_NULL;
> @@ -483,15 +517,35 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
>   		return NULL;
>   	}
>   
> +	if (lv_exclusive_count)
> +		*exclusive = 1;
> +
>   	return lv_mirr;
>   }
>   
> +static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
> +			unsigned exclusive)
> +{
> +	int r = 0;
> +
> +	if (exclusive || lv_is_active_exclusive(lv_mirr))
> +		r = activate_lv_excl(cmd, lv_mirr);
> +	else
> +		r = activate_lv(cmd, lv_mirr);
> +
> +	if (!r)
> +		stack;
> +
> +	return r;
> +}
> +
>   /*
>    * Called to set up initial pvmove LV only.
>    * (Not called after first or any other section completes.)
>    */
>   static int _update_metadata(struct logical_volume *lv_mirr,
> -			    struct dm_list *lvs_changed)
> +			    struct dm_list *lvs_changed,
> +			    unsigned exclusive)
>   {
>   	struct lv_list *lvl;
>   	struct logical_volume *lv = lv_mirr;
> @@ -505,7 +559,7 @@ static int _update_metadata(struct logical_volume *lv_mirr,
>                   return_0;
>   
>   	/* Ensure mirror LV is active */
> -	if (!activate_lv_excl_local(lv_mirr->vg->cmd, lv_mirr)) {
> +	if (!_activate_lv(lv_mirr->vg->cmd, lv_mirr, exclusive)) {
>   		if (test_mode())
>   			return 1;
>   
> @@ -548,6 +602,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
>   	struct logical_volume *lv = NULL;
>   	const char *pv_name = pv_dev_name(pv);
>   	unsigned flags = PVMOVE_FIRST_TIME;
> +	unsigned exclusive;
>   	int r = ECMD_FAILED;
>   
>   	pp->found_pv = 1;
> @@ -594,6 +649,8 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
>   		}
>   	}
>   
> +	exclusive = _pvmove_is_exclusive(cmd, vg);
> +
>   	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
>   		log_print_unless_silent("Detected pvmove in progress for %s.", pv_name);
>   		if (pp->pv_count || lv_name)
> @@ -605,7 +662,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
>   		}
>   
>   		/* Ensure mirror LV is active */
> -		if (!activate_lv_excl_local(cmd, lv_mirr)) {
> +		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
>   			log_error("ABORTING: Temporary mirror activation failed.");
>   			goto out;
>   		}
> @@ -630,12 +687,12 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
>   
>   		if (!(lv_mirr = _set_up_pvmove_lv(cmd, vg, source_pvl, lv_name,
>   						  allocatable_pvs, pp->alloc,
> -						  &lvs_changed)))
> +						  &lvs_changed, &exclusive)))
>   			goto_out;
>   	}
>   
>   	/* Lock lvs_changed and activate (with old metadata) */
> -	if (!activate_lvs(cmd, lvs_changed))
> +	if (!activate_lvs(cmd, lvs_changed, exclusive))
>   		goto_out;
>   
>   	/* FIXME Presence of a mirror once set PVMOVE - now remove associated logic */
> @@ -646,7 +703,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
>   		goto out;
>   
>   	if (flags & PVMOVE_FIRST_TIME)
> -		if (!_update_metadata(lv_mirr, lvs_changed))
> +		if (!_update_metadata(lv_mirr, lvs_changed, exclusive))
>   			goto_out;
>   
>   	/* LVs are all in status LOCKED */
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


