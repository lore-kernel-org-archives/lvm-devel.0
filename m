From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 6 Jul 2009 12:01:00 +0100
Subject: [PATCH v4 2/5] cmdline: support for bytes and sectors
In-Reply-To: <1246847990-13370-3-git-send-email-snitzer@redhat.com>
References: <1246847990-13370-1-git-send-email-snitzer@redhat.com>
	<1246847990-13370-3-git-send-email-snitzer@redhat.com>
Message-ID: <20090706110100.GC11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Jul 05, 2009 at 10:39:47PM -0400, Mike Snitzer wrote:
> Allow commandline sizes to be specified in terms of bytes and sectors.
> Update the man pages to document size units uniformly.
 
Does the addition of 'bytes' now permit invalid sizes to be specified anywhere
leading to rounding happening without warning messages?

If rounding occurs the user should be notified.
E.g. 	lvcreate has: log_print("Rounding size (%d extents) up to stripe boundary "

(Whether to round up or to round down may depend on the context - see lvresize,
for example.)

> @@ -274,11 +274,19 @@ static int _size_arg(struct cmd_context 
>  
>  		if (i < 0)
>  			return 0;
> -
> -		while (i-- > 0)
> -			v *= 1024;
> -
> -		v *= 2;
> +		else if (i == 7) {

else superfluous?

> +			/* sectors */
> +			v = v;
> +		} else if (i == 6) {
> +			/* bytes */

Warning messages needed here, I think.

> +			if (v < 512)
> +				return 0;
> +			v /= 512;
> +		} else {

Add comment like the others to indicate which cases this now covers

> +			while (i-- > 0)
> +				v *= 1024;
> +			v *= 2;
> +		}
>  	} else
>  		v *= factor;

Alasdair


