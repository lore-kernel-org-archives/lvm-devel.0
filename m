From: Mike Snitzer <snitzer@redhat.com>
Date: Sat, 25 Jul 2009 18:09:55 -0400
Subject: Re: [PATCH 1/6] Add --dataalignmentoffset to pvcreate to pad aligned data area
In-Reply-To: <1248317587-11187-2-git-send-email-snitzer@redhat.com>
References: <1248317587-11187-1-git-send-email-snitzer@redhat.com>
	<1248317587-11187-2-git-send-email-snitzer@redhat.com>
Message-ID: <20090725220954.GA28619@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 22 2009 at 10:53pm -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
> index d8e03f0..32af70b 100644
> --- a/lib/format_text/format-text.c
> +++ b/lib/format_text/format-text.c
> @@ -1382,6 +1382,8 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
>  			adjustment = pv->pe_start % pv->pe_align;
>  			if (adjustment)
>  				pv->pe_start += pv->pe_align - adjustment;
> +			if (pv->pe_align_offset)
> +				pv->pe_start += pv->pe_align_offset;
>  		}
>  	}
>  	if (!add_da

My next post of this patch series will add a negative check that makes
sure the PV's data area is not beyond the end of the device.

Mike


