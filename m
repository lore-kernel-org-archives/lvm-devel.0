From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Wed, 16 Feb 2011 15:42:00 +0100
Subject: [PATCH] make vg_mark_partial_lvs more robust and export it
In-Reply-To: <36088.72482223$1297846647@news.gmane.org>
References: <877hd0v0ht.fsf@twilight.int.mornfall.net.>
	<36088.72482223$1297846647@news.gmane.org>
Message-ID: <4D5BE238.9070806@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 16.2.2011 09:57, Petr Rockai napsal(a):
> Hey again,
> 
> Petr Rockai <prockai@redhat.com> writes:
>> > the following patch makes vg_mark_partial_lvs also clear existing
>> > PARTIAL_LV flags, so it can be issued repeatedly on the same VG, keeping
>> > the PARTIAL_LV flags up to date.
>> >
>> > The patch is simple and straightforward.
> scratch that. It introduces a bug nevertheless. Attaching a fixed
> version.
> 
> 
> 
> vg-mark-partial.diff
> 
> 
> -int vg_mark_partial_lvs(struct volume_group *vg)
> +int vg_mark_partial_lvs(struct volume_group *vg, int clear)
>  {
> -	struct logical_volume *lv;
>  	struct lv_list *lvl;
>  
> -	dm_list_iterate_items(lvl, &vg->lvs) {
> -		lv = lvl->lv;
> -		if (!_lv_mark_if_partial(lv))
> +	if (clear)
> +		dm_list_iterate_items(lvl, &vg->lvs)
> +			lvl->lv->status &= ~PARTIAL_LV;
> +
> +	dm_list_iterate_items(lvl, &vg->lvs)
> +		if (!_lv_mark_if_partial(lvl->lv))
>  			return_0;
> -	}
> +
>  	return 1;

Probably nothing against the patch itself - but maybe we can we find a better
solution for this list scanning?

We are often going through the whole list to find the information we could
comfortable store in other places - like list of partial lvs maybe,
or we may already know there is not partial LV in the whole VG (vg flag ?)

This kind of code adds O(n) complexity for lots of operations.
(When you have 10000LVs it has some measurable impact).

I think similar is the 'unknown' segment which requires full scan.

Zdenek


