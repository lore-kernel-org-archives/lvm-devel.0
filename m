From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 Oct 2010 10:52:52 -0400
Subject: [PATCH 04/14] Refactor and add code for (lv) 'move_pv' get function.
In-Reply-To: <87lj64380j.fsf@twilight.int.mornfall.net.>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-5-git-send-email-dwysocha@redhat.com>
	<87lj64380j.fsf@twilight.int.mornfall.net.>
Message-ID: <1286895172.15299.14.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-10-11 at 20:21 +0200, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> Reviewed-By: Petr Rockai <prockai@redhat.com>
> 
> > diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
> > index ae8a4fb..8f4c95a 100644
> > --- a/lib/metadata/lv.c
> > +++ b/lib/metadata/lv.c
> > @@ -18,6 +18,21 @@
> >  #include "activate.h"
> >  #include "toolcontext.h"
> >  
> > +char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
> > +{
> > +	const char *name;
> > +	struct lv_segment *seg;
> > +
> > +	dm_list_iterate_items(seg, &lv->segments) {
> > +		if (!(seg->status & PVMOVE))
> > +			continue;
> > +		name = dev_name(seg_dev(seg, 0));
> > +	}
> > +	if (name)
> > +		return dm_pool_strndup(mem, name, strlen(name) + 1);
> > +	return NULL;
> > +}
> 
> I believe that dev_name can't give you NULL and that there is only ever
> a single matching device (even if there wasn't, giving first or last
> shouldn't make any difference). So you can remove the "name" temporary
> and just say
> 
> if (seg->status & PVMOVE)
>    return dm_pool_strdup(mem, dev_name(seg_dev(seg, 0)))
> 
> in the loop, and return NULL after the loop. (Even if you prefer the one
> you already have, changing strndup to strdup is a good idea, since doing
> the above comes with no benefits, just downsides.)
> 

Ok, I've made these cleanups as well.  Another good simplification.


