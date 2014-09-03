From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 03 Sep 2014 11:14:56 +0200
Subject: [PATCH] lvconvert: limit lv types for cache use
In-Reply-To: <20140902205600.GF374@redhat.com>
References: <20140902205600.GF374@redhat.com>
Message-ID: <5406DC10.9020108@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.9.2014 v 22:56 David Teigland napsal(a):
> Cache data and metadata lvs can be only linear, striped or raid.
> Origin lvs must be either linear, striped or raid to be converted
> to a cache lv.
> ---
>   lib/metadata/metadata-exported.h |   8 ++
>   lib/metadata/snapshot_manip.c    |   5 ++
>   tools/lvconvert.c                | 173 ++++++++++++++++++++++++++++++++-------
>   3 files changed, 157 insertions(+), 29 deletions(-)
>
> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
> index 0db43348dca2..7e29bb6e3307 100644
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -180,6 +180,13 @@
>   #define lv_is_raid_metadata(lv)	(((lv)->status & (RAID_META)) ? 1 : 0)
>   #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
>
> +/*
> + * Unfortunately, raid1 and raid10 end up being reported as MIRRORED,
> + * so lv_is_mirror_type() is true for them... add this test until that
> + * can be untangled.
> + */
> +#define lv_is_really_mirror_type(lv) (lv_is_mirror_type((lv)) && !lv_is_raid((lv)))
> +

In fact - there should be rather fixed the problem of using  mirror_type for
raids.   These to targets are quite different and should not share internal
flags - since it leads to many other internal bugs where code tries to
run mirror repair operations on raid devices.

So instead we should separate and fix usage of  lv_is_mirror_type purely for
old mirrors to avoid confusion.



>   /* Test if given LV is visible from user's perspective */
>   int lv_is_visible(const struct logical_volume *lv);
> +int lv_is_invisible(const struct logical_volume *lv);

!lv_is_visible   is common way for code - so I would avoid to add new func for 
this.


> +static const char *lv_is_name(struct logical_volume *lv)
> +{
> +	if (lv_is_external_origin(lv))
> +		return "external_origin";
> +

There is already a reporting function for this with new Petr's patches.


);
> +		if (lv_is_external_origin(metadata_lv) ||
> +		    lv_is_thin_type(metadata_lv) ||
> +		    lv_is_external_origin(metadata_lv) ||
> +		    lv_is_really_mirror_type(metadata_lv) ||
> +		    lv_is_raid_image(metadata_lv) ||
> +		    lv_is_raid_metadata(metadata_lv) ||
> +		    lv_is_cache_type(metadata_lv) ||
> +		    lv_is_virtual(metadata_lv) ||

Many of those types are already skipped because they are invisible.
So I think this list should be much shorter.

> @@ -2716,12 +2824,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
>   				  display_lvname(metadata_lv));
>   			return 0;
>   		}
> -		if (lv_is_thin_type(metadata_lv) ||
> -		    lv_is_cache_type(metadata_lv)) {
> -			log_error("Can't use thin or cache type LV %s for pool metadata.",
> -				  display_lvname(metadata_lv));
> -			return 0;
> -		}

don't remove


>
>   		if (!lv_is_pool(pool_lv)) {
>   			if (!_lvconvert_update_pool_params(pool_lv, lp))
> @@ -2735,17 +2837,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
>   		}
>   	}
>
> -	if (!lv_is_visible(pool_lv)) {
> -		log_error("Can't convert internal LV %s.", display_lvname(pool_lv));
> -		return 0;
> -	}
> -
> -	if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
> -		log_error("Mirror logical volumes cannot be used as pools.\n"
> -			  "Try \"raid1\" segment type instead.");
> -		return 0;
> -	}
> -

Don't remove


>   	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",
>   			 pool_lv->name,
>   			 (segtype_is_cache_pool(lp->segtype)) ?
> @@ -3032,6 +3123,10 @@ revert_new_lv:
>   #endif
>   }
>
> +/*
> + * convert an origin lv into a cache lv by attaching a cache pool to the origin
> + */
> +
>   static int _lvconvert_cache(struct cmd_context *cmd,
>   			    struct logical_volume *origin,
>   			    struct lvconvert_params *lp)
> @@ -3045,9 +3140,29 @@ static int _lvconvert_cache(struct cmd_context *cmd,
>   		return 0;
>   	}
>
> -	if (lv_is_pool(origin) || lv_is_cache_type(origin)) {
> -		log_error("Can't cache pool or cache type volume %s.",
> -			  display_lvname(origin));

don't remove

I'll look at those func myself and improving missing cases.

Zdenek



