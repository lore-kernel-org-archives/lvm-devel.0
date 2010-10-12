From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 Oct 2010 11:14:22 -0400
Subject: [PATCH 05/14] Refactor and add code for (lv) 'convert_lv' get function.
In-Reply-To: <87hbgs37u1.fsf@twilight.int.mornfall.net.>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-6-git-send-email-dwysocha@redhat.com>
	<87hbgs37u1.fsf@twilight.int.mornfall.net.>
Message-ID: <1286896462.15299.16.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-10-11 at 20:25 +0200, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> Reviewed-By: Petr Rockai <prockai@redhat.com>
> 
> > --- a/lib/metadata/lv.c
> > +++ b/lib/metadata/lv.c
> > @@ -18,6 +18,26 @@
> >  #include "activate.h"
> >  #include "toolcontext.h"
> >  
> > +char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
> > +{
> > +	struct lv_segment *seg;
> > +	const char *name = NULL;
> > +
> > +	if (lv->status & CONVERTING) {
> > +		if (lv->status & MIRRORED) {
> > +			seg = first_seg(lv);
> > +
> > +			/* Temporary mirror is always area_num == 0 */
> > +			if (seg_type(seg, 0) == AREA_LV &&
> > +			    is_temporary_mirror_layer(seg_lv(seg, 0)))
> > +				name = seg_lv(seg, 0)->name;
> > +		}
> > +	}
> > +	if (name)
> > +		return dm_pool_strndup(mem, name, strlen(name) + 1);
> > +	return NULL;
> > +}
> strndup/strdup again, use of "name" can be eliminated as well...
> 

Done.  I also simplified the lv->status checks:

+char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+       struct lv_segment *seg;
+
+       if (lv->status & (CONVERTING|MIRRORED)) {
+               seg = first_seg(lv);
+
+               /* Temporary mirror is always area_num == 0 */
+               if (seg_type(seg, 0) == AREA_LV &&
+                   is_temporary_mirror_layer(seg_lv(seg, 0)))
+                       return dm_pool_strdup(mem, seg_lv(seg, 0)->name);
+       }
+       return NULL;
+}


> > +
> >  char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
> >  {
> >  	const char *name;
> 
> > --- a/lib/metadata/lv.h
> > +++ b/lib/metadata/lv.h
> > @@ -55,5 +55,6 @@ char *lv_tags_dup(const struct logical_volume *lv);
> >  char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
> >  uint64_t lv_origin_size(const struct logical_volume *lv);
> >  char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
> > +char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
> >  
> >  #endif
> 
> > --- a/lib/report/properties.c
> > +++ b/lib/report/properties.c
> > @@ -131,7 +131,7 @@ GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
> >  #define _copy_percent_set _not_implemented_set
> >  GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
> >  #define _move_pv_set _not_implemented_set
> > -#define _convert_lv_get _not_implemented_get
> > +GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
> >  #define _convert_lv_set _not_implemented_set
> >  GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
> >  #define _lv_tags_set _not_implemented_set
> 
> > --- a/lib/report/report.c
> > +++ b/lib/report/report.c
> > @@ -392,19 +392,8 @@ static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute
> >  {
> >  	const struct logical_volume *lv = (const struct logical_volume *) data;
> >  	const char *name = NULL;
> > -	struct lv_segment *seg;
> > -
> > -	if (lv->status & CONVERTING) {
> > -		if (lv->status & MIRRORED) {
> > -			seg = first_seg(lv);
> > -
> > -			/* Temporary mirror is always area_num == 0 */
> > -			if (seg_type(seg, 0) == AREA_LV &&
> > -			    is_temporary_mirror_layer(seg_lv(seg, 0)))
> > -				name = seg_lv(seg, 0)->name;
> > -		}
> > -	}
> >  
> > +	name = lv_convert_lv_dup(mem, lv);
> >  	if (name)
> >  		return dm_report_field_string(rh, field, &name);
> 
> Ok. Although we don't need a string duplicate here. On the other hand,
> having a non-dup version of the above code and the dup version
> implemented in terms of that would be overkill, I guess...
> 
> Yours,
>    Petr.
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel



