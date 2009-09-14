From: Mike Snitzer <snitzer@redhat.com>
Date: Sun, 13 Sep 2009 21:40:19 -0400
Subject: Re: LVM2/test t-pvcreate-operation-md.sh
In-Reply-To: <20090913192801.1983.qmail@sourceware.org>
References: <20090913192801.1983.qmail@sourceware.org>
Message-ID: <20090914014018.GA4070@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Sep 13 2009 at  3:28pm -0400,
mbroz at sourceware.org <mbroz@sourceware.org> wrote:

> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	mbroz at sourceware.org	2009-09-13 19:28:00
> 
> Modified files:
> 	test           : t-pvcreate-operation-md.sh 
> 
> Log message:
> 	Do not run mdadm tests if MD module is not loaded.
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
> 
> --- LVM2/test/t-pvcreate-operation-md.sh	2009/08/04 16:02:39	1.1
> +++ LVM2/test/t-pvcreate-operation-md.sh	2009/09/13 19:28:00	1.2
> @@ -14,6 +14,7 @@
>  which perl || exit 200
>  which awk || exit 200
>  which cut || exit 200
> +test -f /proc/mdstat || exit 200
>  
>  . ./test-utils.sh
>  
> 

We might try loading the raid0 module if it isn't loaded (grep for raid0
in /proc/mdstat)?  And if that fails skip this test?


