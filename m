From: Petr Rockai <prockai@redhat.com>
Date: Wed, 20 Oct 2010 23:41:40 +0200
Subject: [PATCH 2/8] Refactor and add code for (lv) 'lv_origin' get function.
In-Reply-To: <1287487975-26572-3-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Tue, 19 Oct 2010 07:32:49 -0400")
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
	<1287487975-26572-3-git-send-email-dwysocha@redhat.com>
Message-ID: <8762wwa6ej.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:

> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

> --- a/lib/metadata/lv.c
> +++ b/lib/metadata/lv.c
> @@ -20,6 +20,13 @@
>  #include "segtype.h"
>  #include "str_list.h"
>  
> +char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
> +{
> +	if (lv_is_cow(lv))
> +		return lv_name_dup(mem, origin_from_cow(lv));
> +	return NULL;
> +}
> +
>  char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
>  {
>  	return dm_pool_strdup(mem, lv->name);

> --- a/lib/metadata/lv.h
> +++ b/lib/metadata/lv.h
> @@ -61,5 +61,6 @@ int lv_kernel_minor(const struct logical_volume *lv);
>  char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
>  char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
>  char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
> +char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
>  
>  #endif
> diff --git a/lib/report/properties.c b/lib/report/properties.c
> index 8228193..250c7c9 100644
> --- a/lib/report/properties.c
> +++ b/lib/report/properties.c
> @@ -121,7 +121,7 @@ GET_LV_NUM_PROPERTY_FN(lv_size, lv->size * SECTOR_SIZE)
>  #define _lv_size_set _not_implemented_set
>  GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
>  #define _seg_count_set _not_implemented_set
> -#define _origin_get _not_implemented_get
> +GET_LV_STR_PROPERTY_FN(origin, lv_origin_dup(lv->vg->vgmem, lv))
>  #define _origin_set _not_implemented_set
>  GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
>  #define _origin_size_set _not_implemented_set

> --- a/lib/report/report.c
> +++ b/lib/report/report.c
> @@ -356,9 +356,10 @@ static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
>  			const void *data, void *private)
>  {
>  	const struct logical_volume *lv = (const struct logical_volume *) data;
> +	const char *name;
>  
> -	if (lv_is_cow(lv))
> -		return _lvname_disp(rh, mem, field, origin_from_cow(lv), private);
> +	if ((name = lv_origin_dup(mem, lv)))
> +		return dm_report_field_string(rh, field, &name);
>  
>  	dm_report_field_set_value(field, "", NULL);
>  	return 1;

Now, this code is not equivalent for those cases where the origin is not
visible. I am not sure that can ever happen, though. I am also not sure
which behaviour is better. But it's something worth double-checking.

Other than this, looks OK.

Reviewed-by: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


