From: dustin@v.igoro.us <dustin@v.igoro.us>
Date: Thu, 8 Feb 2007 10:42:56 -0600
Subject: shared segtypes loading
In-Reply-To: <1170952305.4207.25.camel@linux-cxyg.rtp.netapp.com>
References: <20070207221541.GG29594@v.igoro.us>
	<1170952305.4207.25.camel@linux-cxyg.rtp.netapp.com>
Message-ID: <20070208164256.GO29594@v.igoro.us>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Feb 08, 2007 at 11:31:45AM -0500, Dave Wysochanski wrote:
> Moving the add below the list_iterate_safe will still add it to the list
> even if there's a duplicate right?  So maybe the right thing is
> something like this:
> 
> Index: LVM2/lib/commands/toolcontext.c
> ===================================================================
> --- LVM2.orig/lib/commands/toolcontext.c	2007-02-08 11:27:13.000000000 -0500
> +++ LVM2/lib/commands/toolcontext.c	2007-02-08 11:27:24.000000000 -0500
> @@ -777,7 +777,8 @@ static int _init_segtypes(struct cmd_con
>  
>  			list_iterate_safe(sgtl, tmp, &cmd->segtypes) {
>  				segtype2 = list_item(sgtl, struct segment_type);
> -				if (!strcmp(segtype2->name, segtype->name)) {
> +				if ( (segtype2 != segtype) &&
> +				     !strcmp(segtype2->name, segtype->name)) {
>  					log_error("Duplicate segment type %s: "
>  						  "unloading shared library %s",
>  						  segtype->name, cv->v.str);

Agreed, that would be better.

Dustin


