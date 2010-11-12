From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Nov 2010 08:54:21 +0100
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
In-Reply-To: <20101111172909.22001.qmail@sourceware.org>
References: <20101111172909.22001.qmail@sourceware.org>
Message-ID: <4CDCF2AD.4040603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11.11.2010 18:29, agk at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	agk at sourceware.org	2010-11-11 17:29:06
> 
> Modified files:
> 	.              : WHATS_NEW 
> 	lib/commands   : toolcontext.c toolcontext.h 
> 	lib/metadata   : lv_manip.c metadata-exported.h 
> 	liblvm         : lvm_lv.c 
> 	tools          : args.h lvchange.c lvcreate.c lvm.c 
> 	                 lvm2cmdline.h lvmcmdline.c pvchange.c tools.h 
> 	                 vgchange.c vgcreate.c 
> 
> Log message:
> 	Support repetition of --addtag and --deltag arguments.
> 	Add infrastructure for specific cmdline arguments to be repeated in groups.
> 	Split the_args cmdline arguments and values into arg_props and arg_values.
> 
>/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
> 
> --- LVM2/WHATS_NEW	2010/11/10 16:14:02	1.1795
> +++ LVM2/WHATS_NEW	2010/11/11 17:29:05	1.1796
> @@ -1,7 +1,10 @@
>  Version 2.02.77 -
>  ===================================
> -  Fix fsadm need of using '-f' for downsize of unmounted filesystem.
> -  Fix fsadm regression in detection of mounted filesystem for older systems (2.0.75).
> +  Support repetition of --addtag and --deltag arguments.
> +  Add infrastructure for specific cmdline arguments to be repeated in groups.
> +  Split the_args cmdline arguments and values into arg_props and arg_values.
> +FIXME??? Fix fsadm need of using '-f' for downsize of unmounted filesystem.
> +  Fix fsadm to detect mounted filesystems on older systems. (2.0.75)
>    Extend cling allocation policy to recognise PV tags (cling_by_tags).

Probably not the best word order - maybe this way it would be better:

Fsadm no longer needs to be given option '-f' to resize unmounted unchecked
filesystem ?

Zdenek


