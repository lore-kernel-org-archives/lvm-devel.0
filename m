From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 Oct 2010 12:09:29 -0400
Subject: [PATCH 05/14] Refactor and add code for (lv) 'convert_lv' get function.
In-Reply-To: <87eibvv20v.fsf@twilight.int.mornfall.net.>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-6-git-send-email-dwysocha@redhat.com>
	<87hbgs37u1.fsf@twilight.int.mornfall.net.>
	<1286896462.15299.16.camel@f12-work>
	<87eibvv20v.fsf@twilight.int.mornfall.net.>
Message-ID: <1286899769.24741.6.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2010-10-12 at 17:55 +0200, Petr Rockai wrote:
> Hi,
> 
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> >> > +char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
> >> > +{
> >> > +	struct lv_segment *seg;
> >> > +	const char *name = NULL;
> >> > +
> >> > +	if (lv->status & CONVERTING) {
> >> > +		if (lv->status & MIRRORED) {
> >> > +			seg = first_seg(lv);
> >> > +
> >> > +			/* Temporary mirror is always area_num == 0 */
> >> > +			if (seg_type(seg, 0) == AREA_LV &&
> >> > +			    is_temporary_mirror_layer(seg_lv(seg, 0)))
> >> > +				name = seg_lv(seg, 0)->name;
> >> > +		}
> >> > +	}
> >> > +	if (name)
> >> > +		return dm_pool_strndup(mem, name, strlen(name) + 1);
> >> > +	return NULL;
> >> > +}
> 
> > Done.  I also simplified the lv->status checks:
> >
> > +char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
> > +{
> > +       struct lv_segment *seg;
> > +
> > +       if (lv->status & (CONVERTING|MIRRORED)) {
> > +               seg = first_seg(lv);
> > +
> > +               /* Temporary mirror is always area_num == 0 */
> > +               if (seg_type(seg, 0) == AREA_LV &&
> > +                   is_temporary_mirror_layer(seg_lv(seg, 0)))
> > +                       return dm_pool_strdup(mem, seg_lv(seg, 0)->name);
> > +       }
> > +       return NULL;
> > +}
> >
> 
> Looks OK to me. So the first ~half of the patches should be ready to go
> in. I haven't noticed any forward dependencies, so you can check in what
> we have (unless I have missed something), I'll get through more of the
> review later today.
> 

Ok - checking in through patches #1-8.


