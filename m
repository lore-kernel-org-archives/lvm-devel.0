From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 19 Apr 2010 15:34:58 -0400
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_pv.c lvm_vg.c
In-Reply-To: <4BCC77EC.30005@redhat.com>
References: <20100419152225.3141.qmail@sourceware.org>
	<4BCC77EC.30005@redhat.com>
Message-ID: <1271705698.2480.335.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-04-19 at 17:34 +0200, Zdenek Kabelac wrote:
> On 19.4.2010 17:22, wysochanski at sourceware.org wrote:
> > CVSROOT:	/cvs/lvm2
> > Module name:	LVM2
> > Changes by:	wysochanski at sourceware.org	2010-04-19 15:22:24
> > 
> > Modified files:
> > 	liblvm         : lvm2app.h lvm_lv.c lvm_pv.c lvm_vg.c 
> > 
> > Log message:
> > 	Use vg->vgmem to allocate vg/lv/pv string properties instead of dm_malloc/fr
> > 	
> > 	Everywhere else in the API the caller can rely on lvm2app taking care of
> > 	memory allocation and free, so make the 'name' and 'uuid' properties of a
> > 	vg/lv/pv use the vg handle to allocate memory.
> > 	
> > 	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> 
> > -char *lvm_vg_get_name(const vg_t vg)
> > +const char *lvm_vg_get_name(const vg_t vg)
> >  {
> > -	char *name;
> > -
> > -	name = dm_malloc(NAME_LEN + 1);
> > -	strncpy(name, (const char *)vg->name, NAME_LEN);
> > -	name[NAME_LEN] = '\0';
> > -	return name;
> > +	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
> >  }
> 
> 
> Either we should return   const char*  return vg->name;
> or we should  char* return strdup(vg->name) and user could do whatever he
> wants to do with the string.
> 
> I'd prefer 1.) for efficiency, but I don't see any point in current code.
> Usually user wants to make a quick check for something - he will use const
> char*, or he want to keep it for later and he fill duplicate string with his
> own memory allocation routines (i.e. C++ new.... )
> 

I thought I answered this in my other mail, but you never responded.

I guess you are not as concerned about a misbehaving application as I
am.  Returning pointers to internal LVM data seems dangerous to me, but
perhaps I'm overly paranoid.

Indeed, 'const' should be enough to tell the application "this is a
snapshot of the present state, don't modify it".  But what if he does -
then we have a potential for corrupt metadata.  I'd like to take #1
approach, but it just doesn't seem safe.

If you copy memory but don't use 'const', then I would think this sends
the wrong message to applications using the API.


