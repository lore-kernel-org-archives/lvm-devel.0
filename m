From: Petr Rockai <prockai@redhat.com>
Date: Wed, 20 Oct 2010 23:31:32 +0200
Subject: [PATCH 1/8] Refactor and add code for (lv) 'lv_name' get function.
In-Reply-To: <1287487975-26572-2-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Tue, 19 Oct 2010 07:32:48 -0400")
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
	<1287487975-26572-2-git-send-email-dwysocha@redhat.com>
Message-ID: <87aam8a6vf.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:

> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
Reviewed-by: Petr Rockai <prockai@redhat.com>

This can go straight in.

> diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
> index f379c3e..bbaeb64 100644
> --- a/lib/metadata/lv.c
> +++ b/lib/metadata/lv.c
> @@ -20,6 +20,11 @@
>  #include "segtype.h"
>  #include "str_list.h"
>  
> +char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
> +{
> +	return dm_pool_strdup(mem, lv->name);
> +}
> +
>  char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
>  {
>  	struct dm_list *modules;
> diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
> index 2f0ebee..f80d2d5 100644
> --- a/lib/metadata/lv.h
> +++ b/lib/metadata/lv.h
> @@ -60,5 +60,6 @@ int lv_kernel_major(const struct logical_volume *lv);
>  int lv_kernel_minor(const struct logical_volume *lv);
>  char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
>  char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
> +char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
>  
>  #endif
> diff --git a/lib/report/properties.c b/lib/report/properties.c
> index ce1d2f7..8228193 100644
> --- a/lib/report/properties.c
> +++ b/lib/report/properties.c
> @@ -99,7 +99,7 @@ GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
>  /* LV */
>  GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
>  #define _lv_uuid_set _not_implemented_set
> -#define _lv_name_get _not_implemented_get
> +GET_LV_STR_PROPERTY_FN(lv_name, lv_name_dup(lv->vg->vgmem, lv))
>  #define _lv_name_set _not_implemented_set
>  GET_LV_STR_PROPERTY_FN(lv_path, lv_path_dup(lv->vg->vgmem, lv))
>  #define _lv_path_set _not_implemented_set


