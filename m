From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 Oct 2010 10:22:46 -0400
Subject: [PATCH 03/14] Refactor and add code for (lv) 'origin_size' get function.
In-Reply-To: <87pqvg38er.fsf@twilight.int.mornfall.net.>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-4-git-send-email-dwysocha@redhat.com>
	<87pqvg38er.fsf@twilight.int.mornfall.net.>
Message-ID: <1286893366.15299.5.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-10-11 at 20:13 +0200, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> Reviewed-By: Petr Rockai <prockai@redhat.com>
> 
> >  
> > +uint64_t lv_origin_size(const struct logical_volume *lv)
> > +{
> > +	uint64_t size;
> > +
> > +	if (lv_is_cow(lv))
> > +		size = (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
> > +	else if (lv_is_origin(lv))
> > +		size = lv->size;
> > +	else
> > +		size = UINT64_C(0);
> > +	return size;
> > +}
> You don't need the UINT64_C there. size = 0 will work, you know. :)
> Also, I would be inclined to write instead:
> 
> uint64_t lv_origin_size(const struct logical_volume *lv)
> {
> 	if (lv_is_cow(lv))
> 		return (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
> 	if (lv_is_origin(lv))
> 		return lv->size;
> 	return 0;
> }
> 
> which has the same effect.
> 

Very good.  An excellent cleanup - thanks.



