From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 28 Sep 2009 18:40:08 +0100
Subject: Re: [PATCH]: unify logical volume structure initialization
In-Reply-To: <Pine.LNX.4.64.0909240857590.7388@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.0909240857590.7388@hs20-bc2-1.build.redhat.com>
Message-ID: <20090928174008.GI5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Sep 24, 2009 at 08:59:45AM -0400, Mikulas Patocka wrote:

> -	lv->snapshot = NULL;
> -	dm_list_init(&lv->snapshot_segs);
> -	dm_list_init(&lv->segments);
> -	dm_list_init(&lv->tags);
> -	dm_list_init(&lv->segs_using_this_lv);
> +	lv_init(lv);
  
I prefer including these with the allocation in an alloc_lv().

> -					     lvd->lv_chunk_size)) {
> +					     lvd->lv_chunk_size, 0)) {

<Deleting hunk>

> +++ LVM2-msnitzer/lib/format_pool/import_export.c	2009-09-24 14:57:03.000000000 +0200

> @@ -99,10 +95,7 @@ int import_pool_lvs(struct volume_group 
>  		} else {
>  			lv->minor = -1;
>  		}
> -		lv->snapshot = NULL;
> -		dm_list_init(&lv->snapshot_segs);
> -		dm_list_init(&lv->segments);
> -		dm_list_init(&lv->tags);
> +		lv_init(lv);

Already initialised AFAICT.

Alasdair


