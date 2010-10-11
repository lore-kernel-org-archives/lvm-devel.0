From: Petr Rockai <prockai@redhat.com>
Date: Mon, 11 Oct 2010 20:27:32 +0200
Subject: [PATCH 06/14] Refactor and add code for (lv) 'lv_kernel_{major|minor}' get functions.
In-Reply-To: <1286810078-25769-7-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 11 Oct 2010 11:14:30 -0400")
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-7-git-send-email-dwysocha@redhat.com>
Message-ID: <87d3rg37qj.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:

> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
Reviewed-By: Petr Rockai <prockai@redhat.com>

> --- a/lib/metadata/lv.c
> +++ b/lib/metadata/lv.c
> @@ -18,6 +18,23 @@
>  #include "activate.h"
>  #include "toolcontext.h"
>  
> +int lv_kernel_minor(const struct logical_volume *lv)
> +{
> +	struct lvinfo info;
> +
> +	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
> +		return info.minor;
> +	return -1;
> +}
> +
> +int lv_kernel_major(const struct logical_volume *lv)
> +{
> +	struct lvinfo info;
> +	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
> +		return info.major;
> +	return -1;
> +}
> +

> --- a/lib/report/report.c
> +++ b/lib/report/report.c
> @@ -212,10 +212,10 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
>  			const void *data, void *private __attribute__((unused)))
>  {
>  	const struct logical_volume *lv = (const struct logical_volume *) data;
> -	struct lvinfo info;
> +	int major;
>  
> -	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
> -		return dm_report_field_int(rh, field, &info.major);
> +	if ((major = lv_kernel_major(lv)) >= 0)
> +		return dm_report_field_int(rh, field, &major);
>  
>  	return dm_report_field_int32(rh, field, &_minusone32);
>  }
> @@ -225,10 +225,10 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
>  			const void *data, void *private __attribute__((unused)))
>  {
>  	const struct logical_volume *lv = (const struct logical_volume *) data;
> -	struct lvinfo info;
> +	int minor;
>  
> -	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
> -		return dm_report_field_int(rh, field, &info.minor);
> +	if ((minor = lv_kernel_minor(lv)) >= 0)
> +		return dm_report_field_int(rh, field, &minor);
>  
>  	return dm_report_field_int32(rh, field, &_minusone32);
>  }

OK.

Yours,
   Petr.


