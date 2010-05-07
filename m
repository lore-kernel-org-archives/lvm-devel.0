From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 07 May 2010 09:22:48 +0200
Subject: LVM2/test Makefile.in test-utils.sh
In-Reply-To: <20100506185453.2064.qmail@sourceware.org>
References: <20100506185453.2064.qmail@sourceware.org>
Message-ID: <4BE3BFC8.6070608@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.5.2010 20:54, mornfall at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	mornfall at sourceware.org	2010-05-06 18:54:52
> 
> Modified files:
> 	test           : Makefile.in test-utils.sh 
> 
> Log message:
> 	Add some basic provisions for automated testing of dmeventd.
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.39&r2=1.40
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.38&r2=1.39
> 
> --- LVM2/test/Makefile.in	2010/04/30 14:33:39	1.39
> +++ LVM2/test/Makefile.in	2010/05/06 18:54:51	1.40
> @@ -78,7 +78,11 @@
>  	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
>  	echo 'PATH=$$abs_top_builddir/test/bin:$$PATH' >> $@-t
>  	LDLPATH="\$$abs_top_builddir/libdm"; \
> +	LDLPATH="$$LDLPATH:\$$abs_top_builddir/tools"; \
>  	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd"; \
> +	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/lvm2"; \
> +	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/mirror"; \
> +	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/snapshot"; \


Oh - I've had this one in my tree for some time - but as we do not test
dmeventd - I've been not pushing it upstream - as we need a better solution.

daemons/dmeventd/plugins/mirror daemons/dmeventd/plugins/snapshot shouldn't be
here at all - these should be loaded via configurable plugin path - and we
need some more updates even on dlopen part of code (as we move plugins to
subdir of libdir.  Another thing that needs to be changed is the configurable
comunication fifo.

At this moment dmeventd is not yet ready for parallel testing.

Zdenek


