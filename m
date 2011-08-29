From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 29 Aug 2011 15:18:12 +0200
Subject: [PATCH] Use direct memory allocation instead of memory pool during PV analysis (pvck)
In-Reply-To: <4E5B8CC5.3050001@redhat.com>
References: <4E5B8CC5.3050001@redhat.com>
Message-ID: <4E5B9194.70609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.8.2011 14:57, Peter Rajnoha napsal(a):
> There's a very high memory usage when calling _pv_analyse_mda_raw (e.g. while
> executing pvck) that can end up with "out of memory".
> 
> _pv_analyse_mda_raw scans for metadata in the MDA, iteratively increasing the
> size to scan with SECTOR_SIZE until we find a probable config section or we're
> at the edge of the metadata area. However, when using a memory pool, we're also
> iteratively chasing for bigger and bigger mempool chunk which can't be found
> and so we're always allocating a new one, consuming more a more memory...
> (Even a 2MB metadata area can bring pvck down on my test machine!)
> 
> This patch just changes the mempool to direct memory allocation in this
> problematic part of the code.
> 

ACK

Using mempools for temporal buffers within non-critical section is not a good
idea.

Though it seems like mempools might get some 'enhancement' as well - as we
might trim/free the reserved preallocated chunk if it's not big enough for new
allocation. The usage of this 'optimalisation' is rather questionable - but it
would solve the problem visible here.


Zdenek



> Peter
> ---
>  lib/format_text/format-text.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
> index 4a025b2..513ac96 100644
> --- a/lib/format_text/format-text.c
> +++ b/lib/format_text/format-text.c
> @@ -226,7 +226,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
>  		 * "maybe_config_section" returning true when there's no valid
>  		 * metadata in a sector (sectors with all nulls).
>  		 */
> -		if (!(buf = dm_pool_alloc(fmt->cmd->mem, size + size2)))
> +		if (!(buf = dm_malloc(size + size2)))
>  			goto_out;
>  
>  		if (!dev_read_circular(area->dev, offset, size,
> @@ -261,14 +261,14 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
>  				size += SECTOR_SIZE;
>  			}
>  		}
> -		dm_pool_free(fmt->cmd->mem, buf);
> +		dm_free(buf);
>  		buf = NULL;
>  	}
>  
>  	r = 1;
>   out:
>  	if (buf)
> -		dm_pool_free(fmt->cmd->mem, buf);
> +		dm_free(buf);
>  	if (!dev_close(area->dev))
>  		stack;
>  	return r;
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


