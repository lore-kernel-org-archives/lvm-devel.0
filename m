From: Petr Rockai <prockai@redhat.com>
Date: Fri, 26 Nov 2010 08:37:52 +0100
Subject: [PATCH 08/29] Fix memory leak in error path
In-Reply-To: <fe9b9e08dfad635aff060d826257f24ce49dd23b.1290682013.git.zkabelac@redhat.com>
	(Zdenek Kabelac's message of "Thu, 25 Nov 2010 11:55:12 +0100")
References: <cover.1290682013.git.zkabelac@redhat.com>
	<cover.1290682013.git.zkabelac@redhat.com>
	<fe9b9e08dfad635aff060d826257f24ce49dd23b.1290682013.git.zkabelac@redhat.com>
Message-ID: <87pqtslelr.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> Nicely hidden memory leak in error path.
> outf() is macro which uses out_text() and does automagical return_0.
> This would leak tag_buffer.
>
> As there was a repeating code for tags output - create _out_tags().
>
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
Ack.

(I haven't tried the patch, but as long as it compiles and passes
testsuite, it should be good to go.)

> --- a/lib/format_text/export.c
> +++ b/lib/format_text/export.c
> @@ -363,10 +363,27 @@ static int _print_flag_config(struct formatter *f, uint64_t status, int type)
>  	return 1;
>  }
>  
> +
> +static int _out_tags(struct formatter *f, struct dm_list *tags)
> +{
> +	char *tag_buffer;
> +
> +	if (!dm_list_empty(tags)) {
> +		if (!(tag_buffer = alloc_printed_tags(tags)))
> +			return_0;
> +		if (!out_text(f, "tags = %s", tag_buffer)) {
> +			dm_free(tag_buffer);
> +			return_0;
> +		}
> +		dm_free(tag_buffer);
> +	}
> +
> +	return 1;
> +}
> +
>  static int _print_vg(struct formatter *f, struct volume_group *vg)
>  {
>  	char buffer[4096];
> -	char *tag_buffer = NULL;
>  
>  	if (!id_write_format(&vg->id, buffer, sizeof(buffer)))
>  		return_0;
> @@ -378,12 +395,8 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
>  	if (!_print_flag_config(f, vg->status, VG_FLAGS))
>  		return_0;
>  
> -	if (!dm_list_empty(&vg->tags)) {
> -		if (!(tag_buffer = alloc_printed_tags(&vg->tags)))
> -			return_0;
> -		outf(f, "tags = %s", tag_buffer);
> -		dm_free(tag_buffer);
> -	}
> +	if (!_out_tags(f, &vg->tags))
> +		return_0;
>  
>  	if (vg->system_id && *vg->system_id)
>  		outf(f, "system_id = \"%s\"", vg->system_id);
> @@ -428,7 +441,7 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
>  	struct pv_list *pvl;
>  	struct physical_volume *pv;
>  	char buffer[4096];
> -	char *buf, *tag_buffer = NULL;
> +	char *buf;
>  	const char *name;
>  
>  	outf(f, "physical_volumes {");
> @@ -462,12 +475,8 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
>  		if (!_print_flag_config(f, pv->status, PV_FLAGS))
>  			return_0;
>  
> -		if (!dm_list_empty(&pv->tags)) {
> -			if (!(tag_buffer = alloc_printed_tags(&pv->tags)))
> -				return_0;
> -			outf(f, "tags = %s", tag_buffer);
> -			dm_free(tag_buffer);
> -		}
> +		if (!_out_tags(f, &pv->tags))
> +			return_0;
>  
>  		outsize(f, pv->size, "dev_size = %" PRIu64, pv->size);
>  
> @@ -487,8 +496,6 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
>  static int _print_segment(struct formatter *f, struct volume_group *vg,
>  			  int count, struct lv_segment *seg)
>  {
> -	char *tag_buffer = NULL;
> -
>  	outf(f, "segment%u {", count);
>  	_inc_indent(f);
>  
> @@ -499,12 +506,8 @@ static int _print_segment(struct formatter *f, struct volume_group *vg,
>  	outnl(f);
>  	outf(f, "type = \"%s\"", seg->segtype->name);
>  
> -	if (!dm_list_empty(&seg->tags)) {
> -		if (!(tag_buffer = alloc_printed_tags(&seg->tags)))
> -			return_0;
> -		outf(f, "tags = %s", tag_buffer);
> -		dm_free(tag_buffer);
> -	}
> +	if (!_out_tags(f, &seg->tags))
> +		return_0;
>  
>  	if (seg->segtype->ops->text_export &&
>  	    !seg->segtype->ops->text_export(seg, f))
> @@ -557,7 +560,6 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
>  {
>  	struct lv_segment *seg;
>  	char buffer[4096];
> -	char *tag_buffer = NULL;
>  	int seg_count;
>  
>  	outnl(f);
> @@ -573,12 +575,8 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
>  	if (!_print_flag_config(f, lv->status, LV_FLAGS))
>  		return_0;
>  
> -	if (!dm_list_empty(&lv->tags)) {
> -		if (!(tag_buffer = alloc_printed_tags(&lv->tags)))
> -			return_0;
> -		outf(f, "tags = %s", tag_buffer);
> -		dm_free(tag_buffer);
> -	}
> +	if (!_out_tags(f, &lv->tags))
> +		return_0;
>  
>  	if (lv->alloc != ALLOC_INHERIT)
>  		outf(f, "allocation_policy = \"%s\"",


