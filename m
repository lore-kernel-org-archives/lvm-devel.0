From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 Oct 2010 10:29:59 -0400
Subject: [PATCH 02/14] Refactor and add code for (lv) 'lv_path' get function.
In-Reply-To: <87tyks38l1.fsf@twilight.int.mornfall.net.>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-3-git-send-email-dwysocha@redhat.com>
	<87tyks38l1.fsf@twilight.int.mornfall.net.>
Message-ID: <1286893799.15299.13.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-10-11 at 20:09 +0200, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> Reviewed-By: Petr Rockai <prockai@redhat.com>
> 
> (But! See inline comments below. It would make sense to have another go
> at this one.)
> 

Ok.


> > +
> > +char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
> > +{
> > +	char *repstr;
> > +	size_t len;
> > +
> > +	len = strlen(lv->vg->cmd->dev_dir);
> > +	len += strlen(lv->vg->name) + strlen(lv->name) + 2;
> Can you just make that a single size_t len = foo + bar + ...; line? That
> would make it clear there are no side effects involved...
> 

done.


> > +	if (!(repstr = dm_pool_zalloc(mem, len))) {
> > +		log_error("dm_pool_alloc failed");
> > +		return 0;
> > +	}
> > +
> > +	if (dm_snprintf(repstr, len, "%s%s/%s",
> > +			lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0) {
> > +		log_error("lvpath snprintf failed");
> > +		return 0;
> > +	}
> ^^ Should the above dm_pool_zalloc/dm_snprintf go into some
> dm_pool_asprintf, in fact? That would also remove that "len" computation
> and make this function completely trivial. We already have dm_asprintf
> (which uses dm_malloc). You could probably parametrise dm_asprintf with
> the strdup function into dm_generic_asprintf and have both dm_asprintf
> and dm_pool_asprintf implemented in terms of that.
> 
> > +	return repstr;
> > +}
> 
> Also, the log_error bits aren't that spectacular... Could you make them
> a bit clearer, or even omit them? The caller has to check the result and
> error out anyway...
> 

If it's ok with you, I may defer these to a couple cleanup patches.
They are good suggestions but I'm mostly focused on straight moving and
refactoring for this patch set.

There's probably other places in the code that could benefit from such a
dm_pool_asprintf.  So when that is proposed as a patch, all code should
get cleaned up.

The error paths in the attribute and lvm2app code need a cleanup pass -
for example some places I'm using log_errno(ENOMEM, ....), others it
seems we're just doing return_NULL, and still others is this method.

I've placed these two items into the bz for now:
https://bugzilla.redhat.com/show_bug.cgi?id=614049




