From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 20 Aug 2010 10:45:55 -0400
Subject: LVM2/lib/report properties.c
In-Reply-To: <4C6E87E9.9040109@redhat.com>
References: <20100820130240.24771.qmail@sourceware.org>
	<4C6E87E9.9040109@redhat.com>
Message-ID: <1282315555.5781.8.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2010-08-20 at 15:49 +0200, Zdenek Kabelac wrote:
> Dne 20.8.2010 15:02, wysochanski at sourceware.org napsal(a):
> > CVSROOT:	/cvs/lvm2
> > Module name:	LVM2
> > Changes by:	wysochanski at sourceware.org	2010-08-20 13:02:39
> > 
> > Modified files:
> > 	lib/report     : properties.c 
> > 
> > Log message:
> > 	Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' functions.
> > 
> > Patches:
> > http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
> > 
> > --- LVM2/lib/report/properties.c	2010/08/20 12:45:09	1.2
> > +++ LVM2/lib/report/properties.c	2010/08/20 13:02:39	1.3
> > @@ -20,6 +20,15 @@
> >  #include "lvm-types.h"
> >  #include "metadata.h"
> >  
> > +#define GET_NUM_PROPERTY_FN(NAME, VALUE) \
> > +static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
> > +{ \
> > +	struct volume_group *vg = (struct volume_group *)obj; \
> > +\
> > +	prop->v.n_val = VALUE; \
> > +	return 1; \
> > +}
> > +
> 
> 
> Is this going to be part of liblvm API - or it's only purpose is to be used
> through liblvm2api - in that case it would be better to have this code
> compiled as a part of liblvm2api library and not increasing size of liblvm ?
> 

I originally had properties.[ch] inside liblvm subdirectory, but then
reconsidered based on:
1) Longer term the goal is for tools to call the library.  As a result,
I try to put only what is absolutely necessary inside liblvm.
2) Based on the fact properties.c included lib/report/columns.h, it
seemed like extending the reporting infrastructure was better done
inside lib instead of liblvm

That said, I had not considered size implications - can you be more
specific as to your concerns there?  Is it something specific like
initrd, or a design concern?


