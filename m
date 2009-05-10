From: Petr Rockai <prockai@redhat.com>
Date: Sun, 10 May 2009 21:23:20 +0200
Subject: [PATCH 5/7] Introduce lv_set_visible & lv_set_hidden and use lv_is_visible always.
In-Reply-To: <a69d7e8ab6e48759349210e94d8f96495af3f660.1241620083.git.mbroz@redhat.com>
	(Milan Broz's message of "Wed, 6 May 2009 16:43:02 +0200")
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<a69d7e8ab6e48759349210e94d8f96495af3f660.1241620083.git.mbroz@redhat.com>
Message-ID: <878wl4u5hz.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch does improve upon the previous one with regards to the consistency
of lv_count handling (to the point of addressing most of my concerns with
previous).

Milan Broz <mbroz@redhat.com> writes:
> The vg->lv_count parameter now includes always number of visible logical
> volumes.
The patch does as advertised.

> Note that virtual snapshot volume (snapshotX) is never visible,
> but it is stored in metadata with visible flag, so code
> use exception here.
The & SNAPSHOT logic is a little dubious, but seems to be a sufficient solution
to the issue at hand.

Overall, seems good enough to me,

Acked-By: Petr Rockai <prockai@redhat.com>

> diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
> index cc57aeb..852ad76 100644
> --- a/lib/metadata/snapshot_manip.c
> +++ b/lib/metadata/snapshot_manip.c
> @@ -30,8 +30,11 @@ int lv_is_cow(const struct logical_volume *lv)
>  
>  int lv_is_visible(const struct logical_volume *lv)
>  {
> +	if (lv->status & SNAPSHOT)
> +		return 0;
> +
>  	if (lv_is_cow(lv))
> -		return lv_is_visible(find_cow(lv)->lv);
> +		return lv_is_visible(origin_from_cow(lv));
>  
>  	return lv->status & VISIBLE_LV ? 1 : 0;
>  }
Why is the latter change included here? Doesn't seem to be directly related to
the rest of the patch (although I might just be missing something).

>          /* FIXME Assumes an invisible origin belongs to a sparse device */
> -        if (!lv_is_visible(origin))
> +        if (!lv_is_visible(origin)) {
> +		origin->vg->lv_count--;
>                  origin->status |= VIRTUAL_ORIGIN;
> +	}
>  
>  	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
>  
> @@ -130,10 +133,15 @@ int vg_remove_snapshot(struct logical_volume *cow)
>  		return 0;
>  	}
>  
> -	cow->snapshot = NULL;
> +	/*
> +	 * Virtual snapshot volume was removed
> +	 * LV count must be fixed...
> +	 */
> +        if (!lv_is_virtual_origin(cow->snapshot->origin))
> +		cow->vg->lv_count--;
These two are ugly hacks again, and spill the lv_count manipulation (and
knowledge) out of the supposed keeper functions (set visible/hidden, vg
add/remove). Nevertheless, it's hard to tell how to fix this more cleanly.

> diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
> index ad5d158..4dc7111 100644
> --- a/lib/snapshot/snapshot.c
> +++ b/lib/snapshot/snapshot.c
> @@ -78,17 +78,14 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
>  	seg->origin = org;
>  	seg->cow = cow;
>  
> -	// FIXME: direct count manipulation to be removed later
> -	cow->status &= ~VISIBLE_LV;
> -	cow->vg->lv_count--;
>  	cow->snapshot = seg;
> -
>  	org->origin_count++;
> -	org->vg->lv_count--;
>  
>          /* FIXME Assumes an invisible origin belongs to a sparse device */
> -        if (!lv_is_visible(org))
> +        if (!lv_is_visible(org)) {
> +		org->vg->lv_count--;
Same as above.

>                  org->status |= VIRTUAL_ORIGIN;
> +	}

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


