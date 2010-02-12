From: Petr Rockai <prockai@redhat.com>
Date: Fri, 12 Feb 2010 09:42:56 +0100
Subject: [PATCH] Add mirror log to dependency tree using its UUID.
In-Reply-To: <1265021478-17029-1-git-send-email-mbroz@redhat.com> (Milan
	Broz's message of "Mon, 1 Feb 2010 11:51:18 +0100")
References: <1265021478-17029-1-git-send-email-mbroz@redhat.com>
Message-ID: <8763624zfz.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Milan Broz <mbroz@redhat.com> writes:
> Now depencecy tree calculation tries to add log device using
> "_mlog" layer. It is wrong because log device do not use layering
> (it has its own UUID without layer suffix).
> It currently works because query is done only by name.
>
> Because I plan to change all kernel dm info queries to use UUID only,
> it must be rewritten to use proper UUID.

> In ideal world we can use log_lv directly. Unfortunately the lvconvert
> code is currently broken, so code must search for log_lv according to name
> (it doesn't provide log_lv when it should).
I have double-checked and this is not true. See below.

> (mornfall: please can we fix lvconvert to use proper LV struct
> with log lv prepared? See _lv_update_log_type() confusion where
> new log_lv get lost...)

If I was a little more careful to check the patch, this could have been
easy... You have moved the _mlog from _add_lv_to_dtree to
_create_partial_dtree -- but this is not correct! The following patch
works:

(The problem with the proposed patch is that when a nested mirror is
created -- which happens upon lvconvert -m+1, for example, the partial
tree will only contain the toplevel (temporary) mirror and the two
images -- one regular and one mirrored... the mirrored one will however
not get any of its dependencies in the tree, hence *partial*... this
breaks lvconvert since the suspend/resume cycle leaves the _mlog device,
which is not included in the partial trees, in the wrong state.)

diff -rN -u -p old-upstream/lib/activate/dev_manager.c new-upstream/lib/activate/dev_manager.c
--- old-upstream/lib/activate/dev_manager.c	2010-02-12 09:35:07.000000000 +0100
+++ new-upstream/lib/activate/dev_manager.c	2010-02-12 09:35:12.000000000 +0100
@@ -823,7 +823,8 @@ static int _add_lv_to_dtree(struct dev_m
 	if (!_add_dev_to_dtree(dm, dtree, lv, "cow"))
 		return_0;
 
-	if (!_add_dev_to_dtree(dm, dtree, lv, "_mlog"))
+	if ((lv->status & MIRRORED) && first_seg(lv)->log_lv &&
+	    !_add_dev_to_dtree(dm, dtree, first_seg(lv)->log_lv, NULL))
 		return_0;
 
 	return 1;

(the original patch):
> --- a/lib/activate/dev_manager.c
> +++ b/lib/activate/dev_manager.c
> @@ -823,8 +823,32 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struc
>  	if (!_add_dev_to_dtree(dm, dtree, lv, "cow"))
>  		return_0;
>  
> -	if (!_add_dev_to_dtree(dm, dtree, lv, "_mlog"))
> -		return_0;
> +	return 1;
> +}
> +
> +static int _add_mirrored_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
> +				     struct logical_volume *lv)
> +{
> +	struct lv_segment *seg = first_seg(lv);
> +	struct lv_list *lvl;
> +	char log_name[NAME_LEN];
> +
> +	if (seg->log_lv) {
> +		if (!_add_dev_to_dtree(dm, dtree, seg->log_lv, NULL))
> +			return_0;
> +	} else {
> +		/*
> +		 * FIXME: This should not be needed at all!
> +		 * Mirrored LV should have log_lv always updated, unfortunately
> +		 * some convert operations use old LV struct here.
> +		 * For now, try to find log LV using its reserved name.
> +		 */
> +		if (dm_snprintf(log_name, NAME_LEN, "%s_mlog", lv->name) < 0)
> +			return_0;
> +		if ((lvl = find_lv_in_vg(lv->vg, log_name)) &&
> +		    !_add_dev_to_dtree(dm, dtree, lvl->lv, NULL))
> +			return_0;
> +	}
>  
>  	return 1;
>  }
> @@ -849,6 +873,9 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
>  		if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow))
>  			goto_bad;
>  
> +	if ((lv->status & MIRRORED) && !_add_mirrored_lv_to_dtree(dm, dtree, lv))
> +		goto_bad;
> +
>  	/* Add any LVs used by segments in this LV */
>  	dm_list_iterate_items(seg, &lv->segments)
>  		for (s = 0; s < seg->area_count; s++)

Yours,
   Petr.

PS: Yes, it took me a few hours to track this down : - ( ... Next time I
should read more carefully.


