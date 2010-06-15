From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 15 Jun 2010 07:43:40 -0400
Subject: Allow use headers in C++.
In-Reply-To: <1276532407-15147-1-git-send-email-mbroz@redhat.com>
References: <1276532407-15147-1-git-send-email-mbroz@redhat.com>
Message-ID: <20100615114339.GA17838@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jun 14 2010 at 12:20pm -0400,
Milan Broz <mbroz@redhat.com> wrote:

> Remove C++ private keyword from header.
...
> diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
> index e13115a..2b044b5 100644
> --- a/libdm/libdm-report.c
> +++ b/libdm/libdm-report.c
> @@ -566,7 +566,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
>  				 const char *output_separator,
>  				 uint32_t output_flags,
>  				 const char *sort_keys,
> -				 void *private)
> +				 void *private_data)
>  {
>  	struct dm_report *rh;
>  	const struct dm_report_object_type *type;
> @@ -588,7 +588,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
>  	rh->separator = output_separator;
>  	rh->fields = fields;
>  	rh->types = types;
> -	rh->private = private;
> +	rh->private = private_data;
>  
>  	rh->flags |= output_flags & DM_REPORT_OUTPUT_MASK;

Should struct dm_report's "private" be renamed too?


