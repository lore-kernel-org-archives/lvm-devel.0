From: Petr Rockai <prockai@redhat.com>
Date: Fri, 28 Jan 2011 17:39:56 +0100
Subject: [PATCH 10/17] Add pe_start_locked parameter to pv_create fn.
In-Reply-To: <1295867048-21558-11-git-send-email-prajnoha@redhat.com> (Peter
	Rajnoha's message of "Mon, 24 Jan 2011 12:04:01 +0100")
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
	<1295867048-21558-11-git-send-email-prajnoha@redhat.com>
Message-ID: <87k4hpoucj.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha <prajnoha@redhat.com> writes:

> So we can define and hint the metadata area handling code that the
> pe_start is supposed to be firmly set to a certain value and it should
> not be changed during calculations.

All clear. However, it adds another parameter to an already huge
list. Please consider other options. Also, not using int as a bool would
help in lots of places, but I guess we are stuck with that. (You could
for example create a structure for the parameters, so at least at the
call site, we have know which parameter means what... having a 10-tuple
of integers is not exactly informative.)

> Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
Reviewed-by: Petr Rockai <prockai@redhat.com>

> ---
>  lib/metadata/metadata-exported.h |    1 +
>  lib/metadata/metadata.c          |    4 +++-
>  tools/vgconvert.c                |    2 +-
>  3 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
> index da62764..627d098 100644
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -394,6 +394,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
>  				  unsigned long data_alignment,
>  				  unsigned long data_alignment_offset,
>  				  uint64_t pe_start,
> +				  int pe_start_locked,
>  				  uint32_t existing_extent_count,
>  				  uint32_t existing_extent_size,
>  				  int pvmetadatacopies, uint64_t pvmetadatasize,
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 591f7b5..419dcfc 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -1486,7 +1486,8 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
>  	dm_list_init(&mdas);
>  	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
>  			     pp->data_alignment, pp->data_alignment_offset,
> -			     pp->pe_start, pp->extent_count, pp->extent_size,
> +			     pp->pe_start, pp->pe_start ? 1 : 0,
> +			     pp->extent_count, pp->extent_size,
>  			     pp->pvmetadatacopies, pp->pvmetadatasize,
>  			     pp->metadataignore, &mdas))) {
>  		log_error("Failed to setup physical volume \"%s\"", pv_name);
> @@ -1591,6 +1592,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
>  				  unsigned long data_alignment,
>  				  unsigned long data_alignment_offset,
>  				  uint64_t pe_start,
> +				  int pe_start_locked,
>  				  uint32_t existing_extent_count,
>  				  uint32_t existing_extent_size,
>  				  int pvmetadatacopies, uint64_t pvmetadatasize,
> diff --git a/tools/vgconvert.c b/tools/vgconvert.c
> index acae0fc..81ff616 100644
> --- a/tools/vgconvert.c
> +++ b/tools/vgconvert.c
> @@ -125,7 +125,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
>  		dm_list_init(&mdas);
>  		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
>  				     &existing_pv->id, size, 0, 0,
> -				     pe_start, pv_pe_count(existing_pv),
> +				     pe_start, 1, pv_pe_count(existing_pv),
>  				     pv_pe_size(existing_pv), pvmetadatacopies,
>  				     pvmetadatasize, 0, &mdas))) {
>  			log_error("Failed to setup physical volume \"%s\"",


