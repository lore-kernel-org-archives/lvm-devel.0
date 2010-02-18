From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 18 Feb 2010 07:17:31 -0500
Subject: [PATCH 4/8] Add dm_pool_strdup to allocate memory and copy a tag in {lv|vg}_change_tag()
In-Reply-To: <4B7D006A.9040109@redhat.com>
References: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-2-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-3-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-4-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-5-git-send-email-dwysocha@redhat.com>
	<4B7D006A.9040109@redhat.com>
Message-ID: <1266495451.2497.8.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-02-18 at 09:55 +0100, Zdenek Kabelac wrote:
> On 17.2.2010 18:29, Dave Wysochanski wrote:
> > We need to allocate memory for the tag and copy the tag value before we
> > add it to the list of tags.  We could put this inside lvm2app since the
> > tools keep their memory around until vg_write/vg_commit is called, but
> > we put it inside the internal library to minimize code in lvm2app.
> > We need to copy the tag passed in by the caller to ensure the lifetime of
> > the memory until the {vg|lv} handle is released.
> > 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > ---
> >  lib/metadata/metadata.c |   14 ++++++++++++--
> >  1 files changed, 12 insertions(+), 2 deletions(-)
> > 
> > diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> > index 2b8a1be..2667e90 100644
> > --- a/lib/metadata/metadata.c
> > +++ b/lib/metadata/metadata.c
> > @@ -667,6 +667,8 @@ int vg_reduce(struct volume_group *vg, char *pv_name)
> >  
> >  int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
> >  {
> > +	char *tag_new;
> > +
> >  	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
> >  		log_error("Logical volume %s/%s does not support tags",
> >  			  lv->vg->name, lv->name);
> > @@ -674,7 +676,10 @@ int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
> >  	}
> >  
> >  	if (add_tag) {
> > -		if (!str_list_add(lv->vg->vgmem, &lv->tags, tag)) {
> > +		if (!(tag_new = dm_pool_strdup(lv->vg->vgmem, tag))) {
> > +			return_0;
> > +		}
> 
> just a tiny change here:
> 
> return_0;
> prints just backtrace - however dm_pool_strdup() doesn't report allocation
> failure message so a better way would be:
> 
> +log_error("tag duplication failed")
> +return 0;
> 
Ok.  Changed to:

-               if (!str_list_add(lv->vg->vgmem, &lv->tags, tag)) {
+               if (!(tag_new = dm_pool_strdup(lv->vg->vgmem, tag))) {
+                       log_error("Failed to duplicate tag %s from %s/%s",
+                                 tag, lv->vg->name, lv->name);
+                       return 0;
+               }


> To remain consistent with the rest of lvm code.
> 
> 
> Zdenek
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel



