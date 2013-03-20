From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 20 Mar 2013 09:26:46 -0500
Subject: [PATCH] Need another set of eyes to understand this
In-Reply-To: <1363751532-16597-1-git-send-email-tasleson@redhat.com>
References: <1363751532-16597-1-git-send-email-tasleson@redhat.com>
Message-ID: <5149C726.5040609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Even in the case where it works with command line the pv->vg pointer is
pointing to the wrong vg.  The first 2 pv in the list point to the same
second vg.

The only reason the code is working today is that the display code
doesn't use the pv->vg pointer.  It uses the correct bits from the pv
pointer and retrieves the vg structure again.

What's the point of having a vg pointer in the pv structure if it isn't
correct?

-Tony


On 03/19/2013 10:52 PM, Tony Asleson wrote:
> I'm working on a lvm2app library function to return a list of physical
> volumes.  When I call get_pvs and use dm_list_iterate_items to walk the
> returned list I'm finding that the pv->vg->vgmem is NULL for one of my
> three physical volumes (First one) which causes problems as current code
> assumes that this is valid and blindly dereferences it.
> 
> This is the same code path we use for the pvs command line and I'm at a
> loss why I am getting this, unless I am missing something in the
> cmd_context *cmd structure parameter.
> 
> Running in the debugger I can see that when walking the list of pv to add, the
> pv and vg are correct, but when we do the _copy_pv we just copy the address
> of the vg pointer.  We then do a release_vg and when we iterate to the next
> pv to add we call vg_read_internal and assign the results to the same
> vg local variable we end up stomping on the pv->vg->vgmem that is in the
> results that we are going to return.
> 
> Can someone shed some light on how this was intended to work?
> 
> The command pvs returns this:
> 
> PV         VG             Fmt  Attr PSize  PFree
> /dev/sdc                  lvm2 a--  18.00g 18.00g
> /dev/sdd   vg-targetd-too lvm2 a--  18.00g 18.00g
> /dev/sde   vg-targetd     lvm2 a--  18.00g 17.90g
> 
> vg-targetd is the first one to get added to the results list
> and is the one that pvl->pv->vg-vgmem that is zero'd out, the
> others are fine.
> 
> Thanks,
> Tony
> 
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>  liblvm/lvm2app.h | 15 +++++++++++++++
>  liblvm/lvm_pv.c  | 17 +++++++++++++++++
>  python/liblvm.c  | 54 ++++++++++++++++++++++++++++++++++++++++++++++++------
>  3 files changed, 80 insertions(+), 6 deletions(-)
> 
> diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
> index 98585c0..b07eff5 100644
> --- a/liblvm/lvm2app.h
> +++ b/liblvm/lvm2app.h
> @@ -534,6 +534,21 @@ vg_t lvm_vg_create(lvm_t libh, const char *vg_name);
>  struct dm_list *lvm_vg_list_lvs(vg_t vg);
>  
>  /**
> + * Return a list of PV handles for all.
> + *
> + * \memberof lvm_t
> + *
> + * \param   libh
> + * Library handle retrieved from lvm_init
> + *
> + * \return
> + * A list of lvm_pv_list structures containing pv handles for all physical
> + * volumes. If no PVs exist or a global lock was unable to be obtained a
> + * NULL is returned.
> + */
> +struct dm_list *lvm_list_pvs(lvm_t libh);
> +
> +/**
>   * Return a list of PV handles for a given VG handle.
>   *
>   * \memberof vg_t
> diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
> index bf9f630..3a8b148 100644
> --- a/liblvm/lvm_pv.c
> +++ b/liblvm/lvm_pv.c
> @@ -17,6 +17,7 @@
>  #include "lvm-string.h"
>  #include "lvm_misc.h"
>  #include "lvm2app.h"
> +#include "locking.h"
>  
>  const char *lvm_pv_get_uuid(const pv_t pv)
>  {
> @@ -60,6 +61,22 @@ struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
>  	return get_property(NULL, NULL, NULL, NULL, pvseg, name);
>  }
>  
> +struct dm_list *lvm_list_pvs(lvm_t libh)
> +{
> +	struct dm_list *pvslist = NULL;
> +	struct lvm_pv_list *pvl;
> +	struct cmd_context *cmd = (struct cmd_context *)libh;
> +
> +	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
> +		log_errno(ENOLCK, "Unable to obtain global lock.");
> +	} else {
> +		pvslist = get_pvs(cmd);
> +		unlock_vg(cmd, VG_GLOBAL);
> +	}
> +
> +	return pvslist;
> +}
> +
>  struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
>  {
>  	struct dm_list *list;
> diff --git a/python/liblvm.c b/python/liblvm.c
> index 906825e..d77fc9a 100644
> --- a/python/liblvm.c
> +++ b/python/liblvm.c
> @@ -153,6 +153,45 @@ liblvm_lvm_list_vg_uuids(void)
>  }
>  
>  static PyObject *
> +liblvm_lvm_list_pvs(void)
> +{
> +	struct dm_list *pvs;
> +	struct lvm_pv_list *pvl;
> +	PyObject * pytuple;
> +	pvobject * pvobj;
> +	int i = 0;
> +
> +	LVM_VALID();
> +
> +	/* unlike other LVM api calls, if there are no results, we get NULL */
> +	pvs = lvm_list_pvs(libh);
> +	if (!pvs)
> +		return Py_BuildValue("()");
> +
> +	pytuple = PyTuple_New(dm_list_size(pvs));
> +	if (!pytuple)
> +		return NULL;
> +
> +	dm_list_iterate_items(pvl, pvs) {
> +		/* Create and initialize the object */
> +		pvobj = PyObject_New(pvobject, &LibLVMpvType);
> +		if (!pvobj) {
> +			Py_DECREF(pytuple);
> +			return NULL;
> +		}
> +
> +		/* We don't have a parent vg object to be concerned about */
> +		pvobj->parent_vgobj = NULL;
> +
> +		pvobj->pv = pvl->pv;
> +		PyTuple_SET_ITEM(pytuple, i, (PyObject *) pvobj);
> +		i++;
> +	}
> +
> +	return pytuple;
> +}
> +
> +static PyObject *
>  liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
>  {
>  	double converted;
> @@ -1343,13 +1382,15 @@ liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
>  
>  /* PV Methods */
>  
> -#define PV_VALID(pvobject)						\
> -	do {								\
> -		VG_VALID(pvobject->parent_vgobj);			\
> -		if (!pvobject->pv) {					\
> +#define PV_VALID(pvobject)								\
> +	do {												\
> +		if (pvobject->parent_vgobj) {					\
> +			VG_VALID(pvobject->parent_vgobj);			\
> +		}												\
> +		if (!pvobject->pv) {							\
>  			PyErr_SetString(PyExc_UnboundLocalError, "PV object invalid"); \
> -			return NULL;					\
> -		}							\
> +			return NULL;								\
> +		}												\
>  	} while (0)
>  
>  static PyObject *
> @@ -1550,6 +1591,7 @@ static PyMethodDef Liblvm_methods[] = {
>  	{ "scan",		(PyCFunction)liblvm_lvm_scan, METH_NOARGS },
>  	{ "listVgNames",	(PyCFunction)liblvm_lvm_list_vg_names, METH_NOARGS },
>  	{ "listVgUuids",	(PyCFunction)liblvm_lvm_list_vg_uuids, METH_NOARGS },
> +	{ "listPvs",		(PyCFunction)liblvm_lvm_list_pvs, METH_NOARGS },
>  	{ "percentToFloat",	(PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
>  	{ "vgNameFromPvid",	(PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
>  	{ "vgNameFromDevice",	(PyCFunction)liblvm_lvm_vgname_from_device, METH_VARARGS },


