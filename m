From: Petr Rockai <prockai@redhat.com>
Date: Mon, 11 Oct 2010 20:00:01 +0200
Subject: [PATCH 01/14] Add some lv 'get' functions that require no refactoring.
In-Reply-To: <1286810078-25769-2-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 11 Oct 2010 11:14:25 -0400")
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-2-git-send-email-dwysocha@redhat.com>
Message-ID: <87y6a4390e.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:

> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
Adds lv_uuid, lv_attr, lv_major, lv_minor, lv_size, (assumed lv_)
seg_count, pv_mda_used_count, lv_tags.

Straightforward enough.

Reviewed-By: Petr Rockai <prockai@redhat.com>

> -#define _lv_uuid_get _not_implemented_get
> +GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
>  #define _lv_uuid_set _not_implemented_set
>  #define _lv_name_get _not_implemented_get
>  #define _lv_name_set _not_implemented_set
>  #define _lv_path_get _not_implemented_get
>  #define _lv_path_set _not_implemented_set
> -#define _lv_attr_get _not_implemented_get
> +GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
>  #define _lv_attr_set _not_implemented_set
> -#define _lv_major_get _not_implemented_get
> +GET_LV_NUM_PROPERTY_FN(lv_major, lv->major)
>  #define _lv_major_set _not_implemented_set
> -#define _lv_minor_get _not_implemented_get
> +GET_LV_NUM_PROPERTY_FN(lv_minor, lv->minor)
>  #define _lv_minor_set _not_implemented_set
>  #define _lv_read_ahead_get _not_implemented_get
>  #define _lv_read_ahead_set _not_implemented_set
> @@ -117,9 +117,9 @@ GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
>  #define _lv_kernel_minor_set _not_implemented_set
>  #define _lv_kernel_read_ahead_get _not_implemented_get
>  #define _lv_kernel_read_ahead_set _not_implemented_set
> -#define _lv_size_get _not_implemented_get
> +GET_LV_NUM_PROPERTY_FN(lv_size, lv->size * SECTOR_SIZE)
>  #define _lv_size_set _not_implemented_set
> -#define _seg_count_get _not_implemented_get
> +GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
>  #define _seg_count_set _not_implemented_set
>  #define _origin_get _not_implemented_get
>  #define _origin_set _not_implemented_set
> @@ -133,7 +133,7 @@ GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
>  #define _move_pv_set _not_implemented_set
>  #define _convert_lv_get _not_implemented_get
>  #define _convert_lv_set _not_implemented_set
> -#define _lv_tags_get _not_implemented_get
> +GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
>  #define _lv_tags_set _not_implemented_set
>  #define _mirror_log_get _not_implemented_get
>  #define _mirror_log_set _not_implemented_set


