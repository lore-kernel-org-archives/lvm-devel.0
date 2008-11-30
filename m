From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 30 Nov 2008 09:39:37 -0500
Subject: Re: [PATCH 4/4] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <1227992553-4381-4-git-send-email-dwysocha@redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-2-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-3-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1228055977.3315.21.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Sat, 2008-11-29 at 16:02 -0500, Dave Wysochanski wrote:

> Modify pvcreate_single() to first check whether the VG_ORPHANS lock is
> held before trying to obtain it.  This is necessary for the vgexten
> code path, which must obtain VG_ORPHANS before obtaining the appropriate
> VG lock, and befroe calling vg_extend().  The other paths calling
> pvcreate_single() are pvcreate() and vgcreate(), and neither of these
> paths hold VG_ORPHANS.  Without this modification vgextend() will hang
> trying to obtain VG_ORPHANS which it already holds.
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  WHATS_NEW               |    1 +
>  lib/metadata/metadata.c |   32 ++++++++++++++++++++++++++++----
>  man/vgcreate.8.in       |   15 +++++++++------
>  man/vgextend.8.in       |    6 ++++++
>  4 files changed, 44 insertions(+), 10 deletions(-)
> 
> diff --git a/WHATS_NEW b/WHATS_NEW
> index 459533a..03ec238 100644
> --- a/WHATS_NEW
> +++ b/WHATS_NEW
> @@ -1,5 +1,6 @@
>  Version 2.02.44 - 
>  ====================================
> +  Update vgcreate and vgextend to allow uninitialized devices as input.
>    Don't skip updating pvid hash when lvmcache_info struct got swapped.
>    Add tinfo to termcap search path for pld-linux.
>    Fix startup race in clvmd.
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 4b231d3..4e375f5 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -422,9 +422,22 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
>  	/* attach each pv */
>  	for (i = 0; i < pv_count; i++) {
>  		if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
> -			log_error("%s not identified as an existing "
> -				  "physical volume", pv_names[i]);
> -			goto bad;
> +			if (yes_no_prompt("%s not identified as an existing "
> +					  "physical volume.\nInitialize "
> +					  "device and add to volume "
> +					  "group %s? [y/n]: ", pv_names[i],
> +					  vg->name) == 'n') {
> +				goto bad;
> +			} else {
> +				pv = pvcreate_single(vg->cmd, pv_names[i],
> +						     NULL);
> +				if (!pv) {
> +					log_error("Failed to setup physical "
> +						  "volume \"%s\"",
> +						  pv_names[i]);
> +					goto bad;
> +				}
> +			}
>  		}
>  		
>  		if (!add_pv_to_vg(vg, pv_names[i], pv))
> @@ -990,6 +1003,16 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
>  	return 1;
>  }
>  
> +/*
> + * pvcreate_single() - initialize a device with PV label and metadata
> + *
> + * Locking: Ok (but not required) for caller to hold VG_ORPHAN lock
> + * before calling
> + *
> + * Parameters:
> + * - pv_name: device path to initialize
> + * - handle: options to pass to pv_create; NULL indicates use defaults
> + */
>  pv_t *pvcreate_single(struct cmd_context *cmd, const char *pv_name,
>  		      void *handle)
>  {
> @@ -1025,7 +1048,8 @@ pv_t *pvcreate_single(struct cmd_context *cmd, const char *pv_name,
>  		}
>  	}
>  
> -	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
> +	if (!vgname_is_locked(VG_ORPHANS) &&
> +	    (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE))) {
>  		log_error("Can't get lock for orphan PVs");
>  		return NULL;
>  	}

Upon further consideration, I'm not sure putting the pvcreate_single()
calls into vg_extend() is the best way to do this since it causes
complications with VG_ORPHANS lock in pvcreate_single().  Even with the
above code to check the lock before obtaining, pvcreate_single() will
release VG_ORPHANS lock in a different sequence than was obtained (in
vgextend case).  Might be better to place this logic higher up in
vgcreate() and vgextend(), or try to refactor.  I will work on another
patch.


