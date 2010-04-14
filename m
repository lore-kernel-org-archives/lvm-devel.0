From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 14 Apr 2010 12:35:11 -0400
Subject: [PATCH 1/2] Use vg->vgmem to allocate vg/lv/pv string properties instead of dm_malloc/free.
In-Reply-To: <4BC5DD5D.3010908@redhat.com>
References: <1271258086-14238-1-git-send-email-dwysocha@redhat.com>
	<1271258086-14238-2-git-send-email-dwysocha@redhat.com>
	<4BC5DD5D.3010908@redhat.com>
Message-ID: <1271262911.2489.73.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2010-04-14 at 17:21 +0200, Zdenek Kabelac wrote:
> On 14.4.2010 17:14, Dave Wysochanski wrote:
> > Everywhere else in the API the caller can rely on lvm2app taking care of
> > memory allocation and free, so make the 'name' and 'uuid' properties of a
> > vg/lv/pv use the vg handle to allocate memory.
> > 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > ---
> >  liblvm/lvm2app.h |   24 ++++++++++++------------
> >  liblvm/lvm_lv.c  |   10 +++-------
> >  liblvm/lvm_pv.c  |   10 +++-------
> >  liblvm/lvm_vg.c  |    9 ++-------
> >  4 files changed, 20 insertions(+), 33 deletions(-)
> > 
> > diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
> > index 61ffd87..dad92c0 100644
> > --- a/liblvm/lvm2app.h
> > +++ b/liblvm/lvm2app.h
> > @@ -642,12 +642,12 @@ uint64_t lvm_vg_is_partial(vg_t vg);
> >  uint64_t lvm_vg_get_seqno(const vg_t vg);
> >  
> >  /**
> > - * Get the current name of a volume group.
> > + * Get the current uuid of a volume group.
> >   *
> >   * \memberof vg_t
> >   *
> > - * Memory is allocated using dm_malloc() and caller must free the memory
> > - * using dm_free().
> > + * The memory allocated for the uuid is tied to the vg_t handle and will be
> > + * released when lvm_vg_close() is called.
> >   *
> >   * \param   vg
> >   * VG handle obtained from lvm_vg_create or lvm_vg_open().
> > @@ -658,12 +658,12 @@ uint64_t lvm_vg_get_seqno(const vg_t vg);
> >  char *lvm_vg_get_uuid(const vg_t vg);
> >  
> >  /**
> > - * Get the current uuid of a volume group.
> > + * Get the current name of a volume group.
> >   *
> >   * \memberof vg_t
> >   *
> > - * Memory is allocated using dm_malloc() and caller must free the memory
> > - * using dm_free().
> > + * The memory allocated for the name is tied to the vg_t handle and will be
> > + * released when lvm_vg_close() is called.
> >   *
> >   * \param   vg
> >   * VG handle obtained from lvm_vg_create or lvm_vg_open().
> > @@ -783,7 +783,7 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg);
> >   * \memberof vg_t
> >   *
> >   * The memory allocated for the list is tied to the vg_t handle and will be
> > - * released when lvm_vg_close is called.
> > + * released when lvm_vg_close() is called.
> >   *
> >   * To process the list, use the dm_list iterator functions.  For example:
> >   *      vg_t vg;
> > @@ -1001,7 +1001,7 @@ int lvm_lv_remove_tag(lv_t lv, const char *tag);
> >   * \memberof lv_t
> >   *
> >   * The memory allocated for the list is tied to the vg_t handle and will be
> > - * released when lvm_vg_close is called.
> > + * released when lvm_vg_close() is called.
> >   *
> >   * To process the list, use the dm_list iterator functions.  For example:
> >   *      lv_t lv;
> > @@ -1057,8 +1057,8 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
> >   *
> >   * \memberof pv_t
> >   *
> > - * Memory is allocated using dm_malloc() and caller must free the memory
> > - * using dm_free().
> > + * The memory allocated for the uuid is tied to the vg_t handle and will be
> > + * released when lvm_vg_close() is called.
> >   *
> >   * \param   pv
> >   * Physical volume handle.
> > @@ -1073,8 +1073,8 @@ char *lvm_pv_get_uuid(const pv_t pv);
> >   *
> >   * \memberof pv_t
> >   *
> > - * Memory is allocated using dm_malloc() and caller must free the memory
> > - * using dm_free().
> > + * The memory allocated for the uuid is tied to the vg_t handle and will be
> > + * released when lvm_vg_close() is called.
> >   *
> >   * \param   pv
> >   * Physical volume handle.
> > diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
> > index d3bb6b8..1a6c6ce 100644
> > --- a/liblvm/lvm_lv.c
> > +++ b/liblvm/lvm_lv.c
> > @@ -47,17 +47,13 @@ char *lvm_lv_get_uuid(const lv_t lv)
> >  		log_error(INTERNAL_ERROR "unable to convert uuid");
> >  		return NULL;
> >  	}
> > -	return strndup((const char *)uuid, 64);
> > +	return dm_pool_strndup(lv->vg->vgmem, (const char *)uuid, 64);
> >  }
> >  
> >  char *lvm_lv_get_name(const lv_t lv)
> >  {
> > -	char *name;
> > -
> > -	name = dm_malloc(NAME_LEN + 1);
> > -	strncpy(name, (const char *)lv->name, NAME_LEN);
> > -	name[NAME_LEN] = '\0';
> > -	return name;
> > +	return dm_pool_strndup(lv->vg->vgmem, (const char *)lv->name,
> > +			       NAME_LEN+1);
> >  }
> >  
> >  uint64_t lvm_lv_is_active(const lv_t lv)
> > diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
> > index 894aa4b..033bc88 100644
> > --- a/liblvm/lvm_pv.c
> > +++ b/liblvm/lvm_pv.c
> > @@ -25,17 +25,13 @@ char *lvm_pv_get_uuid(const pv_t pv)
> >  		log_error(INTERNAL_ERROR "Unable to convert uuid");
> >  		return NULL;
> >  	}
> > -	return strndup((const char *)uuid, 64);
> > +	return dm_pool_strndup(pv->vg->vgmem, (const char *)uuid, 64);
> >  }
> >  
> >  char *lvm_pv_get_name(const pv_t pv)
> >  {
> > -	char *name;
> > -
> > -	name = dm_malloc(NAME_LEN + 1);
> > -	strncpy(name, (const char *)pv_dev_name(pv), NAME_LEN);
> > -	name[NAME_LEN] = '\0';
> > -	return name;
> > +	return dm_pool_strndup(pv->vg->vgmem,
> > +			       (const char *)pv_dev_name(pv), NAME_LEN + 1);
> >  }
> 
> Why not return const char* for given PV - if user needs local copy,
> he may do a local copy himself calling strdup - doing this all the time is not
> really effective.
> 

Right - const.  I forgot that yet again - I will update the patch.

The memory copy on the attributes is for safety.  The question is, what
is the consequence of allowing an application the possibility to change
an attribute value without using a 'set' or 'change' function.  Using
const, you do get a compile warning, but you can still change it if for
example a non-const pointer is used as the lvalue for assignment to the
function return.  For things like vgnames, uuids, we definitely would
not want to allow the possibility.  For other things, maybe the
consequences would not be as great but I guess I'd err on the side of
safety instead of efficiency.  This is one area where an internal
library may differ from an external/application library though.



