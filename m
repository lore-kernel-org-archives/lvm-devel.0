From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Oct 2010 13:53:19 +0200
Subject: [PATCH 2/4] Add lvseg 'get' functions.
In-Reply-To: <1287494696-18310-3-git-send-email-dwysocha@redhat.com>
References: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
	<1287494696-18310-3-git-send-email-dwysocha@redhat.com>
Message-ID: <4CBED82F.7020702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 19.10.2010 15:24, Dave Wysochanski napsal(a):
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
> index b7a8700..eca046f 100644
> --- a/lib/metadata/lv.c
> +++ b/lib/metadata/lv.c
> @@ -20,6 +20,41 @@
>  #include "segtype.h"
>  #include "str_list.h"
>  
> +char *lvseg_tags_dup(const struct lv_segment *seg)
> +{
> +	return tags_format_and_copy(seg->lv->vg->vgmem, &seg->tags);
> +}
> +
> +char *lvseg_segtype_dup(const struct lv_segment *seg)
> +{
> +	if (seg->area_count == 1) {
> +		return (char *)"linear";

NACK!

> +	}
> +
> +	return dm_pool_strdup(seg->lv->vg->vgmem, seg->segtype->ops->name(seg));
> +}
> +
> +uint64_t lvseg_chunksize(const struct lv_segment *seg)
> +{
> +	uint64_t size;
> +
> +	if (lv_is_cow(seg->lv))
> +		size = (uint64_t) find_cow(seg->lv)->chunk_size;
> +	else
> +		size = UINT64_C(0);

if (lv_is_cow())
       return ...

return 0;


> diff --git a/lib/report/report.c b/lib/report/report.c
> index dbeef21..c7f141f 100644
> --- a/lib/report/report.c
> +++ b/lib/report/report.c
> @@ -279,12 +279,9 @@ static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
>  {
>  	const struct lv_segment *seg = (const struct lv_segment *) data;
>  
> -	if (seg->area_count == 1) {
> -		dm_report_field_set_value(field, "linear", NULL);
> -		return 1;
> -	}
> -
> -	dm_report_field_set_value(field, seg->segtype->ops->name(seg), NULL);
> +	char *name;
> +	name = lvseg_segtype_dup(seg);
> +	dm_report_field_set_value(field, name, NULL);
>  	return 1;
>  }

I really think this API is wrong somewhere - there is way too many duplication
- this isn't going to be very efficient....
I do like the beauty of const strings....


Zdenek


