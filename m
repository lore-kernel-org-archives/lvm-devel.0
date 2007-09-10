From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 10 Sep 2007 16:07:02 -0400
Subject: [LVM2 PATCH] Add pvseg_free field to 'pvs' output
In-Reply-To: <1189447092.4444.2.camel@linux-cxyg>
References: <1189447092.4444.2.camel@linux-cxyg>
Message-ID: <1189454822.4444.12.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2007-09-10 at 13:58 -0400, Dave Wysochanski wrote:
> Add pvseg_free field to 'pvs' output to display whether a segment
> is free or allocated to an LV.  This brings pvs segment output 
> closer to 'pvdisplay --maps'.
> 
> # tools/lvm pvs -o pv_name,pvseg_start,pvseg_size,pvseg_free 
>   PV         Start SSize Free 
>   /dev/loop1     0    32 Y    
>   /dev/loop1    32    31 N    
>   /dev/loop2     0    32 Y    
>   /dev/loop2    32    15 Y    
>   /dev/loop2    47    16 N    
>   /dev/loop3     0    63 N    
> 
> 
> ---
> Index: LVM2/lib/report/columns.h
> ===================================================================
> --- LVM2.orig/lib/report/columns.h	2007-08-20 16:55:27.000000000 -0400
> +++ LVM2/lib/report/columns.h	2007-09-10 13:47:33.000000000 -0400
> @@ -83,4 +83,5 @@ FIELD(SEGS, seg, STR, "Devices", list, 5
>  
>  FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, "pvseg_start", "Physical Extent number of start of segment.")
>  FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, "pvseg_size", "Number of extents in segment.")
> +FIELD(PVSEGS, pvseg, STR, "Free", lvseg, 5, lvseg, "pvseg_free", "Whether the segment is free or allocated to an LV.")
>  /* *INDENT-ON* */
> Index: LVM2/lib/report/report.c
> ===================================================================
> --- LVM2.orig/lib/report/report.c	2007-08-22 10:38:17.000000000 -0400
> +++ LVM2/lib/report/report.c	2007-09-10 13:47:33.000000000 -0400
> @@ -62,6 +62,15 @@ static char _alloc_policy_char(alloc_pol
>  /*
>   * Data-munging functions to prepare each data type for display and sorting
>   */
> +static int _lvseg_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
> +		       struct dm_report_field *field,
> +		       const void *data, void *private __attribute((unused)))
> +{
> +	const struct lv_segment *seg = *(const struct lv_segment **) data;
> +	dm_report_field_set_value(field, seg ? "Y" : "N", NULL);

Logic actually reversed here but fixed on commit.




