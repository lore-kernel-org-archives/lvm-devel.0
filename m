From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 02 Jun 2010 11:11:01 +0200
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c ...
In-Reply-To: <20100601160814.13230.qmail@sourceware.org>
References: <20100601160814.13230.qmail@sourceware.org>
Message-ID: <4C062025.8020201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 1.6.2010 18:08, prajnoha at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	prajnoha at sourceware.org	2010-06-01 16:08:14
>
> Modified files:
> 	.              : WHATS_NEW_DM
> 	libdm/ioctl    : libdm-iface.c
> 	libdm/misc     : dm-ioctl.h
>
> Log message:
> 	Add support for dm-mod module autoload.

>   	/*
> @@ -279,7 +304,8 @@
>   	 * Assume 2.4 kernels are patched not to.
>   	 * FIXME Check _dm_version and _dm_version_minor if 2.6 changes this.
>   	 */
> -	if (!strncmp(uts.release, "2.6.", 4))
> +	if (KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release)>=
> +	    KERNEL_VERSION(2, 6, 0))
>   		_dm_multiple_major_support = 0;
>


I think slightly better API would be here - to call some function like:

int is_kernel_version_higher(major, minor,relase);

Returns 1 if the kernel version is > than given argument.
And keep _kernel_major local static in this function.

Zdenek


