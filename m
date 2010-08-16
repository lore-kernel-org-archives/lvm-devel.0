From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 16 Aug 2010 16:29:56 +0100
Subject: [PATCH 1 of 3] Handle failures of mirror devices while under snapshot origin (bug 613829)
In-Reply-To: <1281911325.30206.3.camel@hydrogen.msp.redhat.com>
References: <1281911325.30206.3.camel@hydrogen.msp.redhat.com>
Message-ID: <20100816152955.GB11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Aug 15, 2010 at 05:28:45PM -0500, Jon Brassow wrote:
> Index: LVM2/lib/activate/activate.c
> ===================================================================
> --- LVM2.orig/lib/activate/activate.c
> +++ LVM2/lib/activate/activate.c
> @@ -772,7 +772,8 @@ int monitor_dev_for_events(struct cmd_co
>  			if (!monitor_dev_for_events(cmd, dm_list_struct_base(snh,
>  				    struct lv_segment, origin_list)->cow, monitor))
>  				r = 0;
> -		return r;
> +		if (!lv_is_mirrored(lv))
> +			return r;
>  	}

Please update the comment above this function too.

> Index: LVM2/lib/mirror/mirrored.c
> ===================================================================
> --- LVM2.orig/lib/mirror/mirrored.c
> +++ LVM2/lib/mirror/mirrored.c
> @@ -631,18 +631,16 @@ static int _target_set_events(struct lv_
>  			      int evmask __attribute__((unused)), int set)

> -	if (!(uuid = build_dm_uuid(vg->cmd->mem, lv->lvid.s, NULL)))
> +	if (!(uuid = build_dm_uuid(vg->cmd->mem, lv->lvid.s, suffix)))
>  		return_0;

Does the other instance of build_dm_uuid() in _target_monitored() need a similar change?

Alasdair



