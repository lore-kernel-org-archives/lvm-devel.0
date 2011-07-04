From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 4 Jul 2011 15:55:46 +0100
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
In-Reply-To: <20110617141423.32545.qmail@sourceware.org>
References: <20110617141423.32545.qmail@sourceware.org>
Message-ID: <20110704145546.GD5448@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 17, 2011 at 02:14:23PM -0000, zkabelac at sourceware.org wrote:
> +++ LVM2/lib/activate/dev_manager.c	2011/06/17 14:14:19	1.218

> @@ -1758,19 +1768,24 @@

>  /* origin_only may only be set if we are resuming (not activating) an origin LV */
>  int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
> -			unsigned origin_only, int *flush_required)
> +			struct lv_activate_opts *laopts, int *flush_required)
>  {
> -	if (!_tree_action(dm, lv, origin_only, PRELOAD))
> +	/* FIXME Update the pvmove implementation! */
> +	if ((lv->status & PVMOVE) || (lv->status & LOCKED))
> +		return 1;
> +
> +	if (!_tree_action(dm, lv, laopts, PRELOAD))
>  		return 0;
>  
>  	*flush_required = dm->flush_required;

Which reinstates the pvmove bug:)

Alasdair


