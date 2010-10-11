From: Petr Rockai <prockai@redhat.com>
Date: Mon, 11 Oct 2010 20:29:50 +0200
Subject: [PATCH 07/14] Refactor and add code for (lv) 'mirror_log' get function.
In-Reply-To: <1286810078-25769-8-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 11 Oct 2010 11:14:31 -0400")
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-8-git-send-email-dwysocha@redhat.com>
Message-ID: <8762x837mp.fsf@twilight.int.mornfall.net.>
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
> @@ -17,6 +17,22 @@
>  #include "metadata.h"
>  #include "activate.h"
>  #include "toolcontext.h"
> +#include "segtype.h"
> +
> +char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
> +{
> +	struct lv_segment *seg;
> +	const char *name = NULL;
> +
> +	dm_list_iterate_items(seg, &lv->segments) {
> +		if (!seg_is_mirrored(seg) || !seg->log_lv)
> +			continue;
> +		name = seg->log_lv->name;
> +	}
> +	if (name)
> +		return dm_pool_strndup(mem, name, strlen(name) + 1);
> +	return NULL;
> +}
strndup & unnecessary temporary again

> --- a/lib/report/properties.c
> +++ b/lib/report/properties.c
> @@ -135,7 +135,7 @@ GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
>  #define _convert_lv_set _not_implemented_set
>  GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
>  #define _lv_tags_set _not_implemented_set
> -#define _mirror_log_get _not_implemented_get
> +GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
>  #define _mirror_log_set _not_implemented_set
>  #define _modules_get _not_implemented_get
>  #define _modules_set _not_implemented_set

> --- a/lib/report/report.c
> +++ b/lib/report/report.c
> @@ -297,14 +297,11 @@ static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((
>  		       const void *data, void *private __attribute__((unused)))
>  {
>  	const struct logical_volume *lv = (const struct logical_volume *) data;
> -	struct lv_segment *seg;
> +	const char *name;
>  
> -	dm_list_iterate_items(seg, &lv->segments) {
> -		if (!seg_is_mirrored(seg) || !seg->log_lv)
> -			continue;
> -		return dm_report_field_string(rh, field,
> -					      (const char **) &seg->log_lv->name);
> -	}
> +	name = lv_mirror_log_dup(mem, lv);
> +	if (name)
> +		return dm_report_field_string(rh, field, &name);
>  
>  	dm_report_field_set_value(field, "", NULL);
>  	return 1;

OK. Your other patches use if ((name = ...)) style, maybe use it here as
well? (Or change the others to use this style instead?)

Yours,
   Petr.


