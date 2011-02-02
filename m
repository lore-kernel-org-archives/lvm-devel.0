From: Milan Broz <mbroz@redhat.com>
Date: Wed, 02 Feb 2011 13:27:27 +0100
Subject: [PATCH 2 of 2] LVM: allow exclusive snapshots in cluster
In-Reply-To: <201102011600.p11G0KIF019338@hydrogen.msp.redhat.com>
References: <201102011600.p11G0KIF019338@hydrogen.msp.redhat.com>
Message-ID: <4D494DAF.3020201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On 02/01/2011 05:00 PM, Jonathan Brassow wrote:
> Patch name: lvm-allow-exclusive-snapshots-in-cluster.patch
> 
> Allow snapshots in a cluster as long as they are exclusively
> activated.
> 
> In order to achieve this, we need to be able to query whether
> the origin is active exclusively (a condition of being able to
> add an exclusive snapshot).  'lv_is_active' currently only
> returns 0 or 1.  This patch will cause 'lv_is_active' to return
> '2' if the LV is active exclusively on the calling node.  None
> of the callers of 'lv_is_active' are affected by this change.

Yes the remote lock query was intended to do exlusive lock query,
no idea why I didn't add it there...

pvmove already should do something similar - if there is no cluster
mirror, it should be able to use local mirror code (with exclusively
activated LVs).

IMHO we should modify code to behave the same here.
(query for exclusive)

> Once we are able to query the exclusive activation of an LV, we
> can safely create/activate the snapshot.

You cannot activate LV without snapshot, so making snapshot in clustered
VG causes that this volume can be activated only exclusively now.

It will cause some new situations - cluster restart will fails
to activate some LVs with snapshot (because it is not exclusive).

Should we modify clvmd initscript to ignore this?
 
> Index: LVM2/lib/activate/activate.c
> ===================================================================
> --- LVM2.orig/lib/activate/activate.c
> +++ LVM2/lib/activate/activate.c
> @@ -701,20 +701,22 @@ int lvs_in_vg_opened(const struct volume
>   * Returns:
>   * 0 - not active locally or on any node in cluster
>   * 1 - active either locally or some node in the cluster
> + * 2 - active exclusively on this node
>   */
>  int lv_is_active(struct logical_volume *lv)

Can we make it return some defines or enums?

{ LV_INACTIVE = 0, LV_ACTIVE = 1, LV_ACTIVE_EXCLUSIVE = 2,
maybe LV_ACTIVE_REMOTE_ONLY = 3 } ?

>  {
> -	int ret;
> +	int r;
> +	int ret = 0;
>  
>  	if (_lv_active(lv->vg->cmd, lv))
> -		return 1;
> +		ret++;
>  
>  	if (!vg_is_clustered(lv->vg))
> -		return 0;
> -
> -	if ((ret = remote_lock_held(lv->lvid.s)) >= 0)
>  		return ret;

This will generate cluster network requests even when not needed...
What about adding

int lv_is_active(struct logical_volume *lv, int query_exclusive)

  	if (_lv_active(lv->vg->cmd, lv))
		ret++;

	if (ret && !query_exclusive)
		return ret;

or all users of lv_is_active have no problems with that?

>  
> +	if ((r = remote_lock_held(lv->lvid.s, ret)) >= 0)
> +		return ret + r;
> +
>  	/*

> -int remote_lock_held(const char *vol)
> +int remote_lock_held(const char *vol, int exclusive)
>  {
> -	int mode = LCK_NULL;
> +	int m;
>  
>  	if (!locking_is_clustered())
>  		return 0;
> @@ -558,10 +558,13 @@ int remote_lock_held(const char *vol)
>  	/*
>  	 * If an error occured, expect that volume is active
>  	 */
> -	if (!_locking.query_resource(vol, &mode)) {
> +	if (!_locking.query_resource(vol, &m)) {

why rename? and you will get gcc unitialised warning, I guess...


Milan


