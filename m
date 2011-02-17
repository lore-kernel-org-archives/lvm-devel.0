From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 17 Feb 2011 14:55:24 -0600
Subject: [PATCH 1 of 1] LVM: 2 preserve exclusive target table loading
In-Reply-To: <201102172020.p1HKKpo3024705@hydrogen.msp.redhat.com>
References: <201102172020.p1HKKpo3024705@hydrogen.msp.redhat.com>
Message-ID: <3498DD6C-233C-4417-9B30-FE76DCFDCE61@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is perhaps a simpler way of doing this....  Simply check  
'lv_is_active_exclusive_locally' inside '_lv_resume'.  If so, then 'lv- 
 >status |= ACTIVATE_EXCL'.  However, there is a bug preventing this  
approach from working.

The function 'remote_lock_held' immediately calls  
'locking_is_clustered'.  This function doesn't work in clvmd because  
the '_locking' structure is never initialized.  Should it be?  This  
would cause clvmd to try to communicate with itself - perhaps this is  
a bad idea(?).

The below solution works well, but I don't want to overlook a more  
obvious/trivial solution.
  brassow


On Feb 17, 2011, at 2:20 PM, Jonathan Brassow wrote:

> Patch name: lvm2-preserve-exclusive-target-table-loading.patch
>
> Fix for bug 677739: removing final exclusive cmirror snapshot,
> 		    results in clvmd deadlock
>
> When a logical volume is activated exclusively in a cluster, the
> local (non-cluster-aware) target is used.  However, when creating
> a snapshot on the exclusive LV, the resulting suspend/resume fails
> to load the appropriate device-mapper table - instead loading the
> cluster-aware target.
>
> This patch adds an 'exclusive' parameter to the pertinent resume
> functions to allow for the right target type to be loaded.
>
>
> Index: LVM2/daemons/clvmd/lvm-functions.c
> ===================================================================
> --- LVM2.orig/daemons/clvmd/lvm-functions.c
> +++ LVM2/daemons/clvmd/lvm-functions.c
> @@ -399,7 +399,7 @@ error:
> /* Resume the LV if it was active */
> static int do_resume_lv(char *resource, unsigned char lock_flags)
> {
> -	int oldmode;
> +	int oldmode, origin_only, exclusive;
>
> 	/* Is it open ? */
> 	oldmode = get_current_lock(resource);
> @@ -407,8 +407,10 @@ static int do_resume_lv(char *resource,
> 		DEBUGLOG("do_resume_lv, lock not already held\n");
> 		return 0;	/* We don't need to do anything */
> 	}
> +	origin_only = (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0;
> +	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
>
> -	if (!lv_resume_if_active(cmd, resource, (lock_flags &  
> LCK_ORIGIN_ONLY_MODE) ? 1 : 0))
> +	if (!lv_resume_if_active(cmd, resource, origin_only, exclusive))
> 		return EIO;
>
> 	return 0;
> Index: LVM2/lib/activate/activate.c
> ===================================================================
> --- LVM2.orig/lib/activate/activate.c
> +++ LVM2/lib/activate/activate.c
> @@ -1157,7 +1157,7 @@ int lv_suspend(struct cmd_context *cmd,
> ***********/
>
> static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
> -		      unsigned origin_only,
> +		      unsigned origin_only, unsigned exclusive,
> 		      int error_if_not_active)
> {
> 	struct logical_volume *lv;
> @@ -1189,6 +1189,9 @@ static int _lv_resume(struct cmd_context
> 		goto out;
> 	}
>
> +	if (exclusive)
> +		lv->status |= ACTIVATE_EXCL;
> +
> 	if (!_lv_activate_lv(lv, origin_only))
> 		goto_out;
>
> @@ -1206,14 +1209,15 @@ out:
> }
>
> /* Returns success if the device is not active */
> -int lv_resume_if_active(struct cmd_context *cmd, const char  
> *lvid_s, unsigned origin_only)
> +int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
> +			unsigned origin_only, unsigned exclusive)
> {
> -	return _lv_resume(cmd, lvid_s, origin_only, 0);
> +	return _lv_resume(cmd, lvid_s, origin_only, exclusive, 0);
> }
>
> int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned  
> origin_only)
> {
> -	return _lv_resume(cmd, lvid_s, origin_only, 1);
> +	return _lv_resume(cmd, lvid_s, origin_only, 0, 1);
> }
>
> static int _lv_has_open_snapshots(struct logical_volume *lv)
> Index: LVM2/lib/activate/activate.h
> ===================================================================
> --- LVM2.orig/lib/activate/activate.h
> +++ LVM2/lib/activate/activate.h
> @@ -56,7 +56,8 @@ void activation_exit(void);
> /* int lv_suspend(struct cmd_context *cmd, const char *lvid_s); */
> int lv_suspend_if_active(struct cmd_context *cmd, const char  
> *lvid_s, unsigned origin_only);
> int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned  
> origin_only);
> -int lv_resume_if_active(struct cmd_context *cmd, const char  
> *lvid_s, unsigned origin_only);
> +int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
> +			unsigned origin_only, unsigned exclusive);
> int lv_activate(struct cmd_context *cmd, const char *lvid_s, int  
> exclusive);
> int lv_activate_with_filter(struct cmd_context *cmd, const char  
> *lvid_s,
> 			    int exclusive);
> Index: LVM2/lib/locking/file_locking.c
> ===================================================================
> --- LVM2.orig/lib/locking/file_locking.c
> +++ LVM2/lib/locking/file_locking.c
> @@ -293,7 +293,7 @@ static int _file_lock_resource(struct cm
> 		switch (flags & LCK_TYPE_MASK) {
> 		case LCK_UNLOCK:
> 			log_very_verbose("Unlocking LV %s%s", resource, origin_only ? "  
> without snapshots" : "");
> -			if (!lv_resume_if_active(cmd, resource, origin_only))
> +			if (!lv_resume_if_active(cmd, resource, origin_only, 0))
> 				return 0;
> 			break;
> 		case LCK_NULL:
> Index: LVM2/lib/locking/no_locking.c
> ===================================================================
> --- LVM2.orig/lib/locking/no_locking.c
> +++ LVM2/lib/locking/no_locking.c
> @@ -46,7 +46,7 @@ static int _no_lock_resource(struct cmd_
> 		case LCK_NULL:
> 			return lv_deactivate(cmd, resource);
> 		case LCK_UNLOCK:
> -			return lv_resume_if_active(cmd, resource, (flags &  
> LCK_ORIGIN_ONLY) ? 1: 0);
> +			return lv_resume_if_active(cmd, resource, (flags &  
> LCK_ORIGIN_ONLY) ? 1: 0, 0);
> 		case LCK_READ:
> 			return lv_activate_with_filter(cmd, resource, 0);
> 		case LCK_WRITE:
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


