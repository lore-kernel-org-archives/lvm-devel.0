From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 22 Jan 2009 13:17:03 -0500
Subject: [PATCH 3/14] Properly enforce cluster locking in _vg_lock_and_read.
In-Reply-To: <1232619010-4858-4-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
Message-ID: <1232648223.8897.9.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2009-01-22 at 11:09 +0100, Petr Rockai wrote:
> Wed Jan 21 15:52:36 CET 2009  Petr Rockai <me@mornfall.net>
>   * Properly enforce cluster locking in _vg_lock_and_read.
> diff -rN -u -p old-temp.4430/lib/metadata/metadata.c new-temp.4430/lib/metadata/metadata.c
> --- old-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:36.870777955 +0100
> +++ new-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:36.918780355 +0100
> @@ -2595,6 +2595,12 @@ static vg_t *_vg_lock_and_read(struct cm
>  		goto_bad;
>  	}
>  
> +	if (vg_is_clustered(vg) && !locking_is_clustered()) {
> +		log_error("Skipping clustered volume group %s", vg->name);
> +		failure |= FAILED_CLUSTERED;
> +		goto_bad;
> +	}
> +
>  	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
>  	if (!consistent && !failure) {
>  		if (!(vg = _recover_vg(cmd, lock, vg_name, vgid, lock_flags))) {
> @@ -2605,7 +2611,7 @@ static vg_t *_vg_lock_and_read(struct cm
>  		}
>  	}
>  
> -	failure |= _vg_check_status(vg, status_flags);
> +	failure |= _vg_check_status(vg, status_flags & ~CLUSTERED);
>  	if (failure)
>  		goto_bad;
>  
> 


With this patch, is there any point in leaving that CLUSTERED flag check
in _vg_check_status()?  The clustered flag set in vg_read() is not
needed either (check is mandatory now - flag doesn't mean anything).


