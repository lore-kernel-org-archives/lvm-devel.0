From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 28 Nov 2010 23:22:41 +0100
Subject: LVM2 tools/lvconvert.c test/t-lvconvert-twostep.sh
In-Reply-To: <20101125171554.6287.qmail@sourceware.org>
References: <20101125171554.6287.qmail@sourceware.org>
Message-ID: <4CF2D631.3040101@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.11.2010 18:15, mornfall at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	mornfall at sourceware.org	2010-11-25 17:15:48
> 
> Modified files:
> 	tools          : lvconvert.c 
> Added files:
> 	test           : t-lvconvert-twostep.sh 
> 
> Log message:
> 	Disallow certain lvconvert operations that need to both allocate and free
> 	extents, while physical volumes are specified. Fixes BZ 640051.
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-twostep.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
> 
> /cvs/lvm2/LVM2/test/t-lvconvert-twostep.sh,v  -->  standard output
> revision 1.1
> --- LVM2/test/t-lvconvert-twostep.sh
> +++ -	2010-11-25 17:15:51.043330000 +0000
> @@ -0,0 +1,21 @@

> --- LVM2/tools/lvconvert.c	2010/10/13 21:26:38	1.148
> +++ LVM2/tools/lvconvert.c	2010/11/25 17:15:47	1.149
> @@ -1345,6 +1345,15 @@
>  					     &new_mimage_count, &new_log_count))
>  		return 0;
>  
> +        if (((old_mimage_count < new_mimage_count && old_log_count > new_log_count) ||
> +             (old_mimage_count > new_mimage_count && old_log_count < new_log_count)) &&
> +            lp->pv_count) {
> +		log_error("Cannot both allocate and free extents when specifying physical"
> +			  " volumes to use.");
> +		log_error("Please specify the operation in two steps.");


Missing update for t-lvconvert-mirror.sh which seems to report this message
now and fails the test ?

Zdenek


