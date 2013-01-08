From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 08 Jan 2013 11:44:09 +0100
Subject: [PATCH 2/3] lvm2app: Implementation of lv resize (v1)
In-Reply-To: <1357592534-14672-2-git-send-email-tasleson@redhat.com>
References: <1357592534-14672-1-git-send-email-tasleson@redhat.com>
	<1357592534-14672-2-git-send-email-tasleson@redhat.com>
Message-ID: <50EBF879.7080201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.1.2013 22:02, Tony Asleson napsal(a):
> When re-sizing a LV with the command line, after the re-size
> occurs the code used to do a vg_write and then a number of
> operations before and after the commit.  As the API requires
> the ability to have the re-size done independantly of the
> write and commit a flag was added so that when we go through
> vg_commit we will do the same required steps to commit the
> lv size change regardless if it was done through the command
> line or the API.
>
> The core functionality was moved to lv_manip so that the
> command line and the API could call it.  To make this work
> all the argument parsing functions are being done in
> tools/lv_resize.c and all the parameters are expected to be
> passed in with the struct lvresize_params.
>

I'd prefer here to see separate patches which are
just moving code and then new patches for changes
of moved code.



> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>   lib/format_text/flags.c          |   1 +
>   lib/metadata/lv_manip.c          | 665 ++++++++++++++++++++++++++++++++
>   lib/metadata/metadata-exported.h |  76 +++-
>   lib/metadata/metadata.c          |  91 ++++-
>   lib/misc/lvm-percent.c           |   5 +
>   lib/misc/lvm-percent.h           |   2 +
>   liblvm/lvm2app.h                 |   2 -
>   liblvm/lvm_lv.c                  |  19 +-
>   tools/lvresize.c                 | 811 +++------------------------------------
>   tools/toollib.c                  |   6 -
>   tools/tools.h                    |  17 -
>   11 files changed, 906 insertions(+), 789 deletions(-)
>
> diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
> index a3a3d0e..4edf7e1 100644
> --- a/lib/format_text/flags.c
> +++ b/lib/format_text/flags.c
> @@ -77,6 +77,7 @@ static const struct flag _lv_flags[] = {
>   	{THIN_POOL, NULL, 0},
>   	{THIN_POOL_DATA, NULL, 0},
>   	{THIN_POOL_METADATA, NULL, 0},
> +	{LV_RESIZE, NULL, 0},
>   	{0, NULL, 0}
>   };
>
> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
> index 35a75ff..6fcf6f2 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> @@ -27,6 +27,7 @@
>   #include "activate.h"
>   #include "str_list.h"
>   #include "defaults.h"
> +#include "lvm-exec.h"
>
>   typedef enum {
>   	PREFERRED,
> @@ -3041,6 +3042,670 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
>   	return lv_rename_update(cmd, lv, new_name, 1);
>   }
>
> +static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)

After moving code - try to add  '_' prefixes to internal 'static' functions.



> +			/* We could have been called after an error has occurred, in that
> +			   case we will not do the next step */
> +			if (ok) {
> +
> +				/*
> +				* Update lvm pool metadata (drop messages) if the pool has been
> +				* resumed and do a pool active/deactivate in other case.
> +				*
> +				* Note: Active thin pool can be waiting for resize.
> +				*
> +				* FIXME: Activate only when thin volume is active
> +				*/
> +				if (lv_is_thin_pool(lvl->lv) &&
> +					!update_pool_lv(lvl->lv, !lv_is_active(lvl->lv))) {

alignment

> +					stack;
> +					return 0;

we have macro shortcut - return_0;

> +				}
> +			}
> +		}
> +	}
> +
> +	return 1;
> +}
> +
> +
>   /* Commit pending changes */
>   int vg_commit(struct volume_group *vg)
>   {
> @@ -2714,9 +2788,15 @@ int vg_commit(struct volume_group *vg)
>   		return cache_updated;
>   	}
>
> +	if (!_pre_lv_resize(vg))
> +		return_0;
> +
>   	/* Skip if we already did this in vg_write */
>   	if ((vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
> -		return_0;
> +	{
> +		cache_updated = 0;
> +		goto out;
> +	}

goto_out


>
>   	cache_updated = _vg_commit_mdas(vg);
>
> @@ -2736,6 +2816,15 @@ int vg_commit(struct volume_group *vg)
>   		log_error("Attempt to drop cached metadata failed "
>   			  "after commit for VG %s.", vg->name);
>
> +out:
> +	if (!_post_lv_resize(vg, cache_updated)) {
> +		cache_updated = 0;
> +	}
> +
> +	if (!cache_updated) {
> +		stack;
> +	}

{} around single commands unneeded

Zdenek



