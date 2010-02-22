From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 22 Feb 2010 01:08:02 -0500
Subject: [PATCH 8 of 13] LVM: add logic to allow mirrored log
In-Reply-To: <201002171756.o1HHuw4H004907@hydrogen.msp.redhat.com>
References: <201002171756.o1HHuw4H004907@hydrogen.msp.redhat.com>
Message-ID: <4B821F42.8000200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote:
>  static int _lv_update_log_type(struct cmd_context *cmd,
> @@ -657,21 +672,48 @@ static int _lv_update_log_type(struct cm
>  			       struct logical_volume *lv,
>  			       int log_count)
>  {
...
> +	log_lv = first_seg(original_lv)->log_lv;
> +
> +	/* Adding redundancy to the log */
> +	if (old_log_count < log_count) {
> +		log_error("Adding log redundancy not supported yet.");
> +		log_error("Try converting the log to 'core' first.");
> +		return_0;
>  	}
> -	return 1;
> +
> +	/* Reducing redundancy of the log */
> +	return remove_mirror_images(log_lv, log_count,
> +				    lp->pv_count ? lp->pvh : NULL, 1U);
>  }

Should we pass lp->pvh even if lp->pv_count is 0?

+	return remove_mirror_images(log_lv, log_count, lp->pvh, 1U);

Looking at remove_mirror_images(), the third agrument, removable_pvs,
is used to decide which mirror leg should be removed. When lp->pv_count
is 0, lp->pvh has the list of PVs in the VG (see lvconvert_single())
and the PV list needs to be passed to remove_mirror_images().

This issue is found during tests. When the primary leg of the mirrored
log (e.g. vg00-lv00_mlog_mimage_0) failed, lvconvert --repair vg00/lv00
didn't recover the vg00/lv00.

With the above fix, lvconvert --repair vg00/lv00 worked well when
the primary leg of the mirrored log failed.

Thanks,
Taka


