From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 14:21:28 +0100
Subject: [PATCH 04/11] Add pv_remove_metadata_area to format_handler interface.
In-Reply-To: <1290115945-27419-5-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
	<1290115945-27419-5-git-send-email-prajnoha@redhat.com>
Message-ID: <4CEE62D8.6010506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.11.2010 22:32, Peter Rajnoha napsal(a):
> The same as for pv_add_metadata_area, but removing...
> 
> Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
> ---
>  lib/format_text/format-text.c |   50 +++++++++++++++++++++++++++++++++++++++++
>  lib/format_text/format-text.h |    3 ++
>  lib/metadata/metadata.h       |    7 +++++
>  3 files changed, 60 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
> index 0c1c4c7..db39c80 100644
> --- a/lib/format_text/format-text.c
> +++ b/lib/format_text/format-text.c
> @@ -2157,6 +2157,55 @@ bad:
>  	return 0;
>  }
>  
> +int remove_metadata_area_from_cache(struct lvmcache_info *info,
> +					    unsigned mda_index)
> +{
> +	struct metadata_area *mda;
> +
> +	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
> +		log_error(INTERNAL_ERROR "can't remove metadata with index %u "
> +					 "from cache for PV %s. Metadata layout "
> +					 "not supported by %s format.",
> +					  mda_index, dev_name(info->dev),
> +					  info->fmt->name);

align text on '(' - no reason to keep INTERNAL_ERROR as extra indent level.



Zdenek


