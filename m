From: Petr Rockai <prockai@redhat.com>
Date: Thu, 08 Apr 2010 00:31:44 +0200
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-de ...
In-Reply-To: <20100407200443.26841.qmail@sourceware.org> (agk@sourceware.org's
	message of "7 Apr 2010 20:04:43 -0000")
References: <20100407200443.26841.qmail@sourceware.org>
Message-ID: <87iq826gj3.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

agk at sourceware.org writes:
> --- LVM2/libdm/libdm-deptree.c	2010/03/25 18:22:04	1.72
> +++ LVM2/libdm/libdm-deptree.c	2010/04/07 20:04:42	1.73
> @@ -1047,9 +1047,14 @@
>  
>  		/* Refresh open_count */
>  		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
> -		    !info.exists || info.open_count)
> +		    !info.exists)
>  			continue;
>  
> +		if (info.open_count) {
> +			r = 0;
> +			continue;
> +		}
As far as I can tell, this r = 0 is new behaviour that breaks a number
of tests and may break user scripts. Is it necessary?

Yours,
   Petr.


