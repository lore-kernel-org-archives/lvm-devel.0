From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Feb 2013 20:45:47 +0100
Subject: [PATCH 1/2] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <1360689876-13552-2-git-send-email-mohan@in.ibm.com>
References: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
	<1360689876-13552-2-git-send-email-mohan@in.ibm.com>
Message-ID: <512BBF6B.3060004@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.2.2013 18:24, M. Mohan Kumar napsal(a):
> From: "M. Mohan Kumar" <mohan@in.ibm.com>
>
> Add thin and thin pool lv creation support to lvm library
>
> Signed-off-by: M. Mohan Kumar <mohan@in.ibm.com>
> ---
>   lib/metadata/lv_manip.c          |   2 +-
>   lib/metadata/metadata-exported.h |   1 +
>   liblvm/lvm2app.h                 |  57 +++++++++++++++++++
>   liblvm/lvm_lv.c                  | 116 +++++++++++++++++++++++++++++++++++++++
>   4 files changed, 175 insertions(+), 1 deletion(-)
>
> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
> index c1437eb..4dd5ebf 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> @@ -4518,7 +4518,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
>   		first_seg(lv)->chunk_size = lp->chunk_size;
>   		first_seg(lv)->discards = lp->discards;
>   		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
> -		first_seg(lv)->low_water_mark = 0;
> +		first_seg(lv)->low_water_mark = lp->low_water_mark;

low_water_mark is not supported yet in the lvm2 stack,
and there is not yet clear definition how is it going to be used.

For now dmeventd is based on 10sec polling interval.

However there needs to be made clean definition for various error path,
and we have to also support 'clean' shutdown for those paths according
to defined policy.


> +	  threshold specified in percentage, convert that into
> +	  number of blocks
> +	*/
> +	lp.low_water_mark = size / chunk_size * threshold / 100;
> +	if (!lp.segtype)
> +		return_NULL;
> +	if (!lv_create_single(vg, &lp))
> +		return_NULL;
> +	if (!(lvl = find_lv_in_vg(vg, pool)))
> +		return NULL;
> +	return (lv_t) lvl->lv;
> +}
> +
> +/* Set defaults for thin LV specific parameters */
> +static void _lv_set_thin_params(struct lvcreate_params *lp,
> +				vg_t vg, const char *pool,
> +				const char *lvname,
> +				uint64_t extents)
> +{
> +	_lv_set_default_params(lp, vg, lvname, extents);
> +
> +	lp->thin = 1;
> +	lp->pool = pool;
> +	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
> +
> +	lp->voriginsize = extents * vg->extent_size;
> +	lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
> +						   vg->extent_size);
> +
> +	lp->stripes = 1;
> +}
> +
> +lv_t lvm_lv_thin(const vg_t vg, const char *pool,
> +		 const char *lvname, uint64_t size)
> +{
> +	struct lvcreate_params lp = { 0 };

I think the lvm2app needs some extension here and rather
make the 'lvcreate_params' structure a visible object with some methods,
and use just one universal function call to create all types
of LVs - so we can better match the internal lvm2 processing.
i.e. there is going to be support for creation of thin
lvs with external origins - so adding  lvm API call for every
possible use case of thin pool is IMHO less clean then maintenance
of 'lvcreate_params' object separately from lvm_lv_create() call.

Similar abstraction needs to be made for i.e. lvconvert command,
which has an internal  lvconvert_params.

Zdenek


