From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 16 Jul 2009 16:11:53 +0100
Subject: [PATCH 1/6] Add --dataalignmentoffset to pvcreate to pad aligned data area
In-Reply-To: <1247515882-13736-2-git-send-email-snitzer@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
	<1247515882-13736-2-git-send-email-snitzer@redhat.com>
Message-ID: <20090716151153.GD32757@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jul 13, 2009 at 04:11:17PM -0400, Mike Snitzer wrote:
> When setting up the first mda, format-text.c:_mda_setup now sets the
> pe_start to immediately follow the first mda (which ends at a pe_align
> boundry).  data_alignment_offset will be added to pe_start if
> --dataalignmentoffset was used.
 
The reason this cannot be reviewed easily is this:

> Index: LVM2/lib/format_text/format-text.c
> ===================================================================
> --- LVM2.orig/lib/format_text/format-text.c
> +++ LVM2/lib/format_text/format-text.c
> @@ -1175,6 +1175,7 @@ static int _text_scan(const struct forma
>     Always have an mda between end-of-label and pe_align() boundary */
>  static int _mda_setup(const struct format_type *fmt,
>  		      uint64_t pe_start, uint64_t pe_end,
> +		      unsigned long data_alignment_offset,
>  		      int pvmetadatacopies,
>  		      uint64_t pvmetadatasize, struct dm_list *mdas,
>  		      struct physical_volume *pv,
> @@ -1251,6 +1252,16 @@ static int _mda_setup(const struct forma
>  			return 0;
>  		}
>  
> +		if (!pe_start && !pe_end) {
> +			/*
> +			 * Set PV's pe_start to immediately follow the
> +			 * first mda (which ends at a pe_align boundary)
> +			 */
> +			pv->pe_start = (start1 + mda_size1) >> SECTOR_SHIFT;
> +			if (data_alignment_offset)
> +				pv->pe_start += data_alignment_offset;
> +		}
> +
>  		if (pvmetadatacopies == 1)
>  			return 1;
>  	} else

While the code already has elsewhere (_text_pv_write):

        /*
         * If pe_start is still unset, set it to first aligned
         * sector after any metadata areas that begin before pe_start.
         */
        if (!pv->pe_start)
                pv->pe_start = pv->pe_align;


Further explanation is required to understand how both can be correct.

Alasdair


