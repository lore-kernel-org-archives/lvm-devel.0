From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 12 Apr 2011 14:40:07 +0200
Subject: LVM2 lib/metadata/lv.c lib/metadata/lv.h lib/r ...
In-Reply-To: <20110412122431.26467.qmail@sourceware.org>
References: <20110412122431.26467.qmail@sourceware.org>
Message-ID: <4DA44827.3000808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.4.2011 14:24, mornfall at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	mornfall at sourceware.org	2011-04-12 12:24:30
> 
> Modified files:
> 	lib/metadata   : lv.c lv.h 
> 	lib/report     : properties.c report.c 
> 	test/api       : test.c 
> 
> Log message:
> 	This patchset refactors some reporting code and completes the remaining
> 	lvseg properties for lvm2app, 'devices' and 'seg_pe_ranges'.
> 	
> 	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> 	Reviewed-by: Petr Rockai <prockai@redhat.com>
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
> 
> --- LVM2/lib/metadata/lv.c	2011/03/29 12:51:57	1.23
> +++ LVM2/lib/metadata/lv.c	2011/04/12 12:24:29	1.24
> @@ -21,6 +21,88 @@
>  #include "segtype.h"
>  #include "str_list.h"
>  
> +static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
> +			     int range_format)
> +{
> +	unsigned int s;
> +	const char *name = NULL;
> +	uint32_t extent = 0;
> +	char extent_str[32];
> +
> +	if (!dm_pool_begin_object(mem, 256)) {
> +		log_error("dm_pool_begin_object failed");
> +		return NULL;
> +	}
> +
> +	for (s = 0; s < seg->area_count; s++) {
> +		switch (seg_type(seg, s)) {
> +		case AREA_LV:
> +			name = seg_lv(seg, s)->name;
> +			extent = seg_le(seg, s);
> +			break;
> +		case AREA_PV:
> +			name = dev_name(seg_dev(seg, s));
> +			extent = seg_pe(seg, s);
> +			break;
> +		case AREA_UNASSIGNED:
> +			name = "unassigned";
> +			extent = 0;
> +		}
> +
> +		if (!dm_pool_grow_object(mem, name, strlen(name))) {
> +			log_error("dm_pool_grow_object failed");
> +			return NULL;
> +		}
> +


unified error path for failing allocation could be: { goto err; }

err:
log_error("error");
dm_pool_abandon_object(mem);
return NULL;

Zdenek


