From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 13 Oct 2009 10:14:06 +0200
Subject: LVM2 daemons/dmeventd/Makefile.in tools/Makefi ...
In-Reply-To: <20091013013111.23965.qmail@sourceware.org>
References: <20091013013111.23965.qmail@sourceware.org>
Message-ID: <4AD436CE.5080608@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.10.2009 03:31, agk at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	agk at sourceware.org	2009-10-13 01:31:10
> 
> Modified files:
> 	daemons/dmeventd: Makefile.in 
> 	tools          : Makefile.in 
> 
> Log message:
> 	More build cleanups (linker parameter ordering).
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.101&r2=1.102
> 
> --- LVM2/daemons/dmeventd/Makefile.in	2009/10/05 13:46:01	1.27
> +++ LVM2/daemons/dmeventd/Makefile.in	2009/10/13 01:31:10	1.28
> @@ -45,8 +45,8 @@
>  LIBS += -ldl -ldevmapper -lpthread
>  
>  dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
> -	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmeventd.o \
> -	-L. -ldevmapper-event $(LIBS) -rdynamic
> +	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
> +	-ldevmapper-event $(LIBS) -rdynamic
>  

Hmm - why moving '-L' library path in before '-o' option?

I think the '-L' should be rather right before '-l' library
(i.e. part of LVMLIBS)
LVMLIBS += -L. -ldevmapper-event -lpthread -ldevmapper

or maybe even more complex (eventually partially placed in make.tmpl.in)

DEVMAPLIBS = -L. -ldevmapper
DEVMAPELIBS = -L. -ldevmapper-event -lpthread

LVMLIBS += $(DEVMAPELIBS) $(DEVMAPLIBS)

And actually - why the -L. is used ? We are already changing LDFLAGS in
make.tmpl to support separate build directory. Thus I think -L. should be
possibly avoided in this case ?


Zdenek


