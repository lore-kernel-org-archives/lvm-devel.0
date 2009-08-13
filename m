From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 14 Aug 2009 00:01:06 +0100
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
In-Reply-To: <20090813142733.24308.qmail@sourceware.org>
References: <20090813142733.24308.qmail@sourceware.org>
Message-ID: <20090813230106.GX7033@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 13, 2009 at 02:27:33PM -0000, mornfall at sourceware.org wrote:
> 	Make lvchange --refresh only take a read lock on volume group.
 
> +  Make lvchange --refresh only take a read lock on volume group.

Declare the other changes in WHATS_NEW too?
  Patch now does this for --monitor too?
  --refresh is now permitted with --ignorelockingfailure?

> -	int avail_only =
> +	int avail_only = /* i.e. only one of -a or --refresh is given */

--monitor?

>  	    !(arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
>  	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
>  	     arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
> -	     arg_count(cmd, refresh_ARG) || arg_count(cmd, alloc_ARG) ||
> -	     arg_count(cmd, resync_ARG));
> +	     arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG));
>  
>  	if (arg_count(cmd, ignorelockingfailure_ARG) && !avail_only) {
>  		log_error("Only -a permitted with --ignorelockingfailure");
 
Alasdair


