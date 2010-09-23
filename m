From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 22:31:12 -0400
Subject: [PATCH 11/20] Make generic GET_*_PROPERTY_FN macros and define secondary macro for vg, pv, lv.
In-Reply-To: <4C9B49DA.3050402@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
	<1285189592-26525-12-git-send-email-dwysocha@redhat.com>
	<4C9B49DA.3050402@redhat.com>
Message-ID: <1285209072.12533.3.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-09-23 at 14:36 +0200, Zdenek Kabelac wrote:
> Dne 22.9.2010 23:06, Dave Wysochanski napsal(a):
> > Will need similar macros for VG, PV and LV, so define a generic one, and just
> > pass in the struct name and variable name for the specific macro.
> > 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > ---
> >  lib/report/properties.c |   25 +++++++++++++++++++++++--
> >  1 files changed, 23 insertions(+), 2 deletions(-)
> > 
> > diff --git a/lib/report/properties.c b/lib/report/properties.c
> > index 9e3cad3..b39a979 100644
> > --- a/lib/report/properties.c
> > +++ b/lib/report/properties.c
> > @@ -20,14 +20,35 @@
> >  #include "lvm-types.h"
> >  #include "metadata.h"
> >  
> > -#define GET_NUM_PROPERTY_FN(NAME, VALUE) \
> > +#define GET_NUM_PROPERTY_FN(NAME, VALUE, STRUCT, VAR)			\
> >  static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
> >  { \
> > -	struct volume_group *vg = (struct volume_group *)obj; \
> > +	struct STRUCT *VAR = (struct STRUCT *)obj; \
> 
> 
> struct STRUCT *VAR
> 
> 
> looks weird... isn't there something better?
> 

"struct TYPE *VAR" ?


