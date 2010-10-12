From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 Oct 2010 11:43:35 -0400
Subject: [PATCH 09/14] Refactor and add code for (lv) 'lv_name' get function.
In-Reply-To: <871v7w37bl.fsf@twilight.int.mornfall.net.>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-10-git-send-email-dwysocha@redhat.com>
	<871v7w37bl.fsf@twilight.int.mornfall.net.>
Message-ID: <1286898215.24741.4.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-10-11 at 20:36 +0200, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> Reviewed-By: Petr Rockai <prockai@redhat.com>
> 
> > --- a/lib/metadata/lv.c
> > +++ b/lib/metadata/lv.c
> > @@ -20,6 +20,33 @@
> >  #include "segtype.h"
> >  #include "str_list.h"
> >  
> > +char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
> > +{
> > +	char *repstr, *lvname;
> > +	size_t len;
> > +
> > +	if (lv_is_visible(lv)) {
> > +		goto dup;
> > +	}
> > +
> > +	len = strlen(lv->name) + 3;
> > +	if (!(repstr = dm_pool_zalloc(mem, len))) {
> > +		log_error("dm_pool_alloc failed");
> > +		return NULL;
> > +	}
> > +
> > +	if (dm_snprintf(repstr, len, "[%s]", lv->name) < 0) {
> > +		log_error("lvname snprintf failed");
> > +		return NULL;
> > +	}
> > +dup:
> > +	if (!(lvname = dm_pool_strdup(mem, lv->name))) {
> > +		log_error("dm_pool_strdup failed");
> > +		return NULL;
> > +	}
> > +	return lvname;
> > +}
> Using (proposed) dm_pool_asprintf would simplify this a lot, too.
> 

Ok.  Actually this patch is wrong anyway.
The 'dup' function should dup the name.
The code that adds the '[' and ']' should be left inside
the 'disp' function.


> > --- a/lib/metadata/lv.h
> > +++ b/lib/metadata/lv.h
> >  
> > -	if (!(lvname = dm_pool_strdup(mem, lv->name))) {
> > -		log_error("dm_pool_strdup failed");
> > -		return 0;
> > -	}
> > +	name = lv_name_dup(mem, lv);
> > +	if (name)
> > +		return dm_report_field_string(rh, field, &name);
> if ((name = ...)) vs ... ; if (name) ... again
> 

Ok.




