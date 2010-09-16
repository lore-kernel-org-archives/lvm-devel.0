From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 16 Sep 2010 10:16:34 -0400
Subject: [PATCH 17/19] Rename internal vg_get_property to more generic lvm_get_property.
In-Reply-To: <4C91DBDF.7010508@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
	<1284564971-26060-18-git-send-email-dwysocha@redhat.com>
	<4C91D82D.2080302@redhat.com>  <4C91DBDF.7010508@redhat.com>
Message-ID: <1284646594.28453.19.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-09-16 at 10:57 +0200, Zdenek Kabelac wrote:
> Dne 16.9.2010 10:41, Zdenek Kabelac napsal(a):
> > Dne 15.9.2010 17:36, Dave Wysochanski napsal(a):
> >>  lib/report/properties.c |    4 ++--
> >>  lib/report/properties.h |    2 +-
> >>  liblvm/lvm_vg.c         |    2 +-
> >>  3 files changed, 4 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/lib/report/properties.c b/lib/report/properties.c
> >> index 0b80593..95da8ab 100644
> >> --- a/lib/report/properties.c
> >> +++ b/lib/report/properties.c
> >> @@ -262,7 +262,7 @@ struct lvm_property_type _properties[] = {
> >>  #undef FIELD
> >>  
> >>  
> >> -int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
> >> +int lvm_get_property(void *obj, struct lvm_property_type *prop)
> > 
> > Hope vg_get_property has been marked as unstable API ?
> > 
> > 
> >>  {
> >>  	struct lvm_property_type *p;
> >>  
> >> @@ -278,7 +278,7 @@ int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
> >>  	}
> >>  
> >>  	*prop = *p;
> >> -	if (!p->get((void *)vg, prop)) {
> >> +	if (!p->get(obj, prop)) {
> >>  		return 0;
> >>  	}
> >>  	return 1;
> >> diff --git a/lib/report/properties.h b/lib/report/properties.h
> >> index 2e1381d..0a13f39 100644
> >> --- a/lib/report/properties.h
> >> +++ b/lib/report/properties.h
> >> @@ -32,6 +32,6 @@ struct lvm_property_type {
> >>  	int (*set) (void *obj, struct lvm_property_type *prop);
> >>  };
> >>  
> >> -int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop);
> >> +int lvm_get_property(void *obj, struct lvm_property_type *prop);
> >>  
> >>  #endif
> >> diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
> >> index 9a72bec..98070dd 100644
> >> --- a/liblvm/lvm_vg.c
> >> +++ b/liblvm/lvm_vg.c
> >> @@ -343,7 +343,7 @@ int lvm_vg_get_property(vg_t vg, const char *name,
> >>  	struct lvm_property_type prop;
> >>  
> >>  	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
> >> -	if (!vg_get_property(vg, &prop))
> >> +	if (!lvm_get_property((void *)vg, &prop))
> > 
> > No need to add cast to (void*) - it's C not C++...
> > 
> 
> In fact - do we really need this functionality ?? It's quite dangerous to
> allow passing any pointer type to such global API function.
> 

Let's see what our options are to clean this up.

It's either void * or duplicate the lvm_get_property() function for each
object (vg, lv, pv) if you don't like void.  If void * is ok, I could
add a magic number to the head of each pointer and do a check inside the
lvm_get_property().  (BTW, In my patchset, I've renamed
lvm_get_property() to just get_property() for now.)


> I would vote for only using separate functionality and using right types and
> right function names - this C++ polymorphism in C code leads to error which
> are hard to catch as compiler will not give any warning about missused typed
> structure pointers.
> 

Ok, so you're saying something like this in properties.h:

int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop);
int pv_get_property(struct physical_volume *vg, struct lvm_property_type *prop);
int lv_get_property(struct logical_volume *lv, struct lvm_property_type *prop);

and maybe make a generic _get_property() inside properties.c, 
called from each of the above, like this:

static int _get_property(void *obj, struct lvm_property_type *prop)
{
	struct lvm_property_type *p;

	p = _properties;
	while (p->id[0]) {
		if (!strcmp(p->id, prop->id))
			break;
		p++;
	}
	if (!p->id[0]) {
		log_errno(EINVAL, "Invalid property name %s", prop->id);
		return 0;
	}

	*prop = *p;
	if (!p->get(obj, prop)) {
		return 0;
	}
	return 1;
}


Keep in mind I'm trying to extend the columns.h / report.c existing structure,
so I've got this _properties array similar to the _fields array in report.c.
In this array, I look up based on field id, then need to call some 'get' or
'set' function tied to the field_id / property name.  The 'get' or 'set'
functions defined inside struct lvm_property_type needed to have one prototype,
so it was either void * or I guess I could do a union.  Would you prefer a
union there?  Maybe I should be using lvm_report_object * instead of
void * for 'obj'?

Let me see if I can rework to be more type-safe.


