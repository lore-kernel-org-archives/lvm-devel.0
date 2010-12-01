From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 01 Dec 2010 10:07:33 +0100
Subject: LVM2 include/.symlinks.in lib/Makefile.in lib/ ...
In-Reply-To: <20101130115336.28589.qmail@sourceware.org>
References: <20101130115336.28589.qmail@sourceware.org>
Message-ID: <4CF61055.3000008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.11.2010 12:53, mornfall at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	mornfall at sourceware.org	2010-11-30 11:53:33
> 
>  
>  		if (segtype->ops->target_percent &&
>  		    !segtype->ops->target_percent(&dm->target_state,
> -						  &percent_range, dm->mem,
> +						  &percent, dm->mem,
>  						  dm->cmd, seg, params,
>  						  &total_numerator,
>  						  &total_denominator))
>  			goto_out;
>  
>  		if (first_time) {
> -			combined_percent_range = percent_range;
> +			*overall_percent = percent;
>  			first_time = 0;

When we are friends with analyzers now ;) -
if (segtype->ops->target_percent == NULL)
is not defined of fails -  'percent' will contain some garbage.

I assume something like this would help?

-	percent_t percent;
+	percent_t percent = PERCENT_INVALID;


Other thing is - how the _combine_percent() is supposed to work in this case?

Maybe you want to goto_out if segtype->ops->target_percent == NULL) as
programming error ?

Zdenek


