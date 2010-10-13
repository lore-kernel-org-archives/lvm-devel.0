From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Oct 2010 10:22:27 +0200
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
In-Reply-To: <20101012161235.24148.qmail@sourceware.org>
References: <20101012161235.24148.qmail@sourceware.org>
Message-ID: <4CB56C43.5060001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.10.2010 18:12, wysochanski at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	wysochanski at sourceware.org	2010-10-12 16:12:34
> 
> Modified files:
> 	lib/metadata   : lv.c lv.h 
> 	lib/report     : properties.c report.c 
> 
> Log message:
> 	Refactor and add code for (lv) 'lv_kernel_{major|minor}' get functions.
> 	
> 	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> 	Reviewed-By: Petr Rockai <prockai@redhat.com>
> 

> +int lv_kernel_minor(const struct logical_volume *lv)
> +{
> +	struct lvinfo info;
>

I think for cases like this one - where the return value is different from
common practice in lvm codebase we should add some doxygen comments - so it's
clear that -1 is return value in this function.


Zdenek


