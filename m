From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 12 Dec 2008 00:02:32 +0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
In-Reply-To: <20081211162552.29826.qmail@sourceware.org>
References: <20081211162552.29826.qmail@sourceware.org>
Message-ID: <20081212000232.GQ24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 11, 2008 at 04:25:52PM -0000, zkabelac at sourceware.org wrote:
> Changes by:	zkabelac at sourceware.org	2008-12-11 16:25:51
> Modified files:
> 	.              : WHATS_NEW_DM 
> 	libdm          : libdm-deptree.c 
> 
> Log message:
> 	Replace _dm_snprintf with EMIT_PARAMS macro for creating target lines
 

> +++ LVM2/libdm/libdm-deptree.c	2008/12/11 16:25:51	1.48
> -/* FIXME Consider exporting this */
> -static int _dm_snprintf(char *buf, size_t bufsize, const char *format, ...)

We already did export it in libdm-string.c!

> +/* simplify string emiting code */
> +#define EMIT_PARAMS(p, str...)\
> +	do {\
> +		const size_t bufsize = paramsize - (size_t)p;\
> +		int w;\
> +		\
> +		if ((w = snprintf(params + p, bufsize, str)) < 0\
> +		    || ((size_t)w >= bufsize)) {\

Can we use dm_snprintf() here now?
Also, a style point, we put || on the end of the previous line.

>  			    struct load_segment *seg, char *params,
>  			    size_t paramsize, int *pos)
>  {
>  	struct seg_area *area;
>  	char devbuf[DM_FORMAT_DEV_BUFSIZE];
> -	int tw;
> -	const char *prefix = "";
>  
>  	dm_list_iterate_items(area, &seg->areas) {
>  		if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
>  			return_0;
>  
> -		if ((tw = _dm_snprintf(params + *pos, paramsize - *pos, "%s%s %" PRIu64,
> -					prefix, devbuf, area->offset)) < 0) {
> -                        stack;	/* Out of space */
> -                        return -1;
> -                }
> -
> -		prefix = " ";
> -		*pos += tw;
> +		EMIT_PARAMS(*pos, " %s %" PRIu64, devbuf, area->offset);

Has this changed the prefix behaviour by adding a space to the first one or
does that cancel out somewhere else?
(Any changes to whitespace require thorough testing - there is code that
relies on comparing these lines as strings against equivalent lines generated
in-kernel.)

Alasdair
-- 
agk at redhat.com


