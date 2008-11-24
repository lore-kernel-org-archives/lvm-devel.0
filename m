From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 23 Nov 2008 22:56:45 -0500
Subject: [PATCH] (7/11) API improvements
In-Reply-To: <873aie3q69.fsf@eriador.mornfall.net>
References: <873aie3q69.fsf@eriador.mornfall.net>
Message-ID: <1227499005.6608.16.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-10-30 at 19:15 +0100, Petr Rockai wrote:
>         if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
> {
> -               vg = _vg_read_failure(cmd, 0);
>                 if (consistent_in && !consistent) {
>                         log_error("Volume group \"%s\" inconsistent.",
> vg_name);
> -                       vg->failed |= FAILED_INCONSISTENT;
> +                       failure |= FAILED_INCONSISTENT;
>                         goto_bad;
>                 }
>                 if (!(misc_flags & EXISTENCE_CHECK))
>                         log_error("Volume group \"%s\" not found",
> vg_name);
> -               vg->failed |= FAILED_NOTFOUND;
> +               failure |= FAILED_NOTFOUND | (misc_flags &
> EXISTENCE_CHECK);
>                 goto_bad;
>         }
>  
> -       vg->failed |= _vg_check_status(vg, status_flags);
> +       /* consistent == 0 when VG is not found, but failed ==
> FAILED_NOTFOUND */
> +       if (!consistent && !vg->read_failed) {

I believe this should be:
	if (!consistent && !failure) {


> +               log_error("Volume group \"%s\" inconsistent.",
> vg_name);
> +               failure |= FAILED_INCONSISTENT;
> +               goto_bad;
> +       }
>  
> 


