From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 15 Jan 2008 11:39:13 -0500
Subject: [PATCH 2/11] Add upward link from underlying LV to stacked seg
In-Reply-To: <20080114225345.GG8075@agk.fab.redhat.com>
References: <4787FA27.8050300@ce.jp.nec.com> <4787FF72.9000400@ce.jp.nec.com>
	<20080114225345.GG8075@agk.fab.redhat.com>
Message-ID: <478CE1B1.4070004@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair,

thanks for the comments.

Alasdair G Kergon wrote:
>  /*
> + * Add/remove upward link from underlying LV to the segment using it
> + */
> +int lv_add_user_seg(struct logical_volume *lv, struct lv_segment *seg);
> +int lv_remove_user_seg(struct logical_volume *lv, struct lv_segment *seg);
> 
> need to rename - too ambiguous

How about this?
  add_seg_to_segs_using_this_lv(lv, seg)
  remove_seg_from_segs_using_this_lv(lv, seg)

Or this?
  add_parent_seg(lv, seg)
  remove_parent_seg(lv, seg)

> +/*
> + * This is a function specialized for the common case where there is
> + * only one segment which uses the LV.
> + * e.g. the LV is a layer inserted by insert_layer_for_lv().
> + *
> + * In general, walk through lv->segs_using_this_lv.
> + */
> +struct lv_segment *seg_using_lv(struct logical_volume *lv)
> +{
> +	struct seg_list *sl;
> +
> +	if (list_size(&lv->segs_using_this_lv) != 1)
> +		return NULL;
> 
> Is it ever valid to return here and not have an error?

Returning NULL is valid if the list is empty.
But it should print error if the list has more than 1 items.

> @@ -110,8 +110,8 @@ int check_lv_segments(struct logical_vol
>  		}
>  
> Where is this new list validated?

Some validation were included in the tests using find_mirror_seg().
I'll add generic ones.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


