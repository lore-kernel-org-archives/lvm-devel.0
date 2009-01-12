From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 12 Jan 2009 22:08:17 +0000
Subject: [PATCH 3/11] Replace implementation of vg_check_status with a call to _vg_check_status.
In-Reply-To: <1231769286-15534-4-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
	<1231769286-15534-4-git-send-email-prockai@redhat.com>
Message-ID: <20090112220817.GL1804@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jan 12, 2009 at 03:07:58PM +0100, Peter Rockai wrote:
>   * Replace implementation of vg_check_status with a call to _vg_check_status.

> -int vg_check_status(const struct volume_group *vg, uint32_t status)
> +static uint32_t _vg_check_status(const struct volume_group *vg, uint32_t status)

typedef for the return value?

>  {
> +	uint32_t ret = 0;

This is more than a simple yes/no return value, call it the same as whatever
you decide to call it elsewhere e.g. 'failure'.

>  	if ((status & CLUSTERED) &&
>  	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
>  	    !lockingfailed()) {
>  		log_error("Skipping clustered volume group %s", vg->name);
> -		return 0;
> +		ret |= FAILED_CLUSTERED;
>  	}

If we're skipping the VG, why do we want to perform the other checks now?

Alasdair
-- 
agk at redhat.com


