From: Milan Broz <mbroz@redhat.com>
Date: Wed, 02 Feb 2011 13:48:38 +0100
Subject: [PATCHv2 2 of 2]LVM: allow exclusive snapshots in cluster
In-Reply-To: <1296596900.24585.3.camel@hydrogen.msp.redhat.com>
References: <1296596900.24585.3.camel@hydrogen.msp.redhat.com>
Message-ID: <4D4952A6.5040905@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/01/2011 10:48 PM, Jonathan Brassow wrote:
> Allow snapshots in a cluster as long as they are exclusively
> activated.
> 
> In order to achieve this, we need to be able to query whether
> the origin is active exclusively (a condition of being able to
> add an exclusive snapshot).
> 
> Index: LVM2/lib/activate/activate.c
> ===================================================================
> --- LVM2.orig/lib/activate/activate.c
> +++ LVM2/lib/activate/activate.c
> @@ -696,23 +696,43 @@ int lvs_in_vg_opened(const struct volume
>  }
>  
>  /*
> + * _lv_is_active
> + * @lv:        logical volume being queried
> + * @locally:   set if active locally
> + * @exclusive: set if active exclusively
> + *
>   * Determine whether an LV is active locally or in a cluster.
> - * Assumes vg lock held.
> - * Returns:
> - * 0 - not active locally or on any node in cluster
> - * 1 - active either locally or some node in the cluster
> + * In addition to the return code which indicates whether or
> + * not the LV is active somewhere, two other values are set
> + * to yield more information about the status of the activation:
> + *	return	locally	exclusively	status
> + *	======	=======	===========	======
> + *	   0	   0	    0		not active
> + *	   0	   0	    1		N/A (not active)
> + *	   0	   1	    0		N/A (not active)
> + *	   0	   1	    1		N/A (not active)
> + *	   1	   0	    0		active remotely
> + *	   1	   0	    1		exclusive remotely
> + *	   1	   1	    0		active locally and possibly remotely
> + *	   1	   1	    1		exclusive locally (or local && !cluster)

isn't enum better here?
{ LV_INACTIVE = 0, LV_ACTIVE (== somewhere), LV_ACTIVE_EXCLUSIVE (locally),
LV_ACTIVE_EXCLUSIVE_REMOTE, LV_ACTIVE_REMOTE (==somewhere but not locally))

dunno, just idea.

> + * The VG lock must be held to call this function.
> + *
> + * Returns: 0 or 1
>   */
> -int lv_is_active(struct logical_volume *lv)
> +static int _lv_is_active(struct logical_volume *lv,
> +			 int *locally, int *exclusive)
>  {
>  	int ret;
>  
>  	if (_lv_active(lv->vg->cmd, lv))
> -		return 1;
> +		*locally = 1;
>  
> -	if (!vg_is_clustered(lv->vg))
> -		return 0;
> +	if (!vg_is_clustered(lv->vg)) {
> +		*exclusive = 1;  /* by definition */
> +		return *locally;
> +	}
>  
> -	if ((ret = remote_lock_held(lv->lvid.s)) >= 0)
> +	if ((ret = remote_lock_held(lv->lvid.s, exclusive)) >= 0)
>  		return ret;

again, I think we are generating network request here, not needed for
local checks... 

> +int lv_is_active(struct logical_volume *lv)
> +{
> +	int l, e;
> +	return _lv_is_active(lv, &l, &e);

no gcc warnings? (maybe gcc is clever enough now:-)

Milan


