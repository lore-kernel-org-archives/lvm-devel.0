From: David Teigland <teigland@redhat.com>
Date: Wed, 28 Apr 2021 14:39:27 -0500
Subject: [LVM2 RFCv1 4/5] lib: locking: Parse PV list for IDM locking
In-Reply-To: <20210425022241.5055-5-leo.yan@linaro.org>
References: <20210425022241.5055-1-leo.yan@linaro.org>
	<20210425022241.5055-5-leo.yan@linaro.org>
Message-ID: <20210428193927.GE9566@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Apr 25, 2021 at 10:22:40AM +0800, Leo Yan wrote:
> +static void _lockd_retrive_lv_pv_list(struct volume_group *vg,
> +				      const char *lv_name,
> +				      struct lvmlockd_pvs *lock_pvs)
> +{

It looks like this wants a list of PVs (names) used by the LV.  Try
iterating through all PVs in the VG and using the existing lv_is_on_pv()
function to check if the LV is using that PV, e.g.

for each pv in vg->pvs,
	if (lv_is_on_pv(lv, pv))
		copy the pv name;

You could pass the lv struct through to here, or use find_lv(vg, lv_name)
to get it again here.

> @@ -251,7 +485,16 @@ static int _lockd_request(struct cmd_context *cmd,
>  	if (vg_name && lv_name) {
> -		reply = _lockd_send(req_name,
> +		/*
> +		 * For LV operation, the PV list must be passed for idm,
> +		 * otherwise, IDM lock manager has no idea to send locking
> +		 * request to which drives, so return failure.
> +		 */
> +		if (!lock_pvs)
> +			return 1;
> +
> +		reply = _lockd_send_with_pvs(req_name,

Requires other lock managers to include lock_pvs?

> +	/*
> +	 * Create the VG's PV list when start the VG, the PV list
> +	 * is passed to lvmlockd, and the the PVs path will be used
> +	 * to send SCSI commands for idm locking scheme.
> +	 */

if vg->lock_type is IDM before creating pv_list?

> +	_lockd_retrive_vg_pv_list(vg, &lock_pvs);
> +
> +	reply = _lockd_send_with_pvs("start_vg",
> +				&lock_pvs,

and probably NULL instead of &lock_pvs for non-IDM.

Dave


