From: Milan Broz <mbroz@redhat.com>
Date: Tue, 23 Feb 2010 12:15:17 +0100
Subject: [PATCH] Add mirror log to dependency tree using its UUID.
In-Reply-To: <8763624zfz.fsf@twilight.int.mornfall.net.>
References: <1265021478-17029-1-git-send-email-mbroz@redhat.com>
	<8763624zfz.fsf@twilight.int.mornfall.net.>
Message-ID: <4B83B8C5.7090207@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/12/2010 09:42 AM, Petr Rockai wrote:
> If I was a little more careful to check the patch, this could have been
> easy... You have moved the _mlog from _add_lv_to_dtree to
> _create_partial_dtree -- but this is not correct! The following patch
> works:

:-)

> @@ -823,7 +823,8 @@ static int _add_lv_to_dtree(struct dev_m
>  	if (!_add_dev_to_dtree(dm, dtree, lv, "cow"))
>  		return_0;
>  
> -	if (!_add_dev_to_dtree(dm, dtree, lv, "_mlog"))
> +	if ((lv->status & MIRRORED) && first_seg(lv)->log_lv &&
> +	    !_add_dev_to_dtree(dm, dtree, first_seg(lv)->log_lv, NULL))
>  		return_0;

yes, this seem to be correct, ack

Milan


