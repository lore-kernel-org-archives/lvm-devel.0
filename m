From: David Teigland <teigland@redhat.com>
Date: Wed, 3 Sep 2014 10:30:43 -0500
Subject: [PATCH] lvconvert: limit lv types for cache use
In-Reply-To: <5406DC10.9020108@redhat.com>
References: <20140902205600.GF374@redhat.com>
 <5406DC10.9020108@redhat.com>
Message-ID: <20140903153043.GB20852@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Sep 03, 2014 at 11:14:56AM +0200, Zdenek Kabelac wrote:
> >+#define lv_is_really_mirror_type(lv) (lv_is_mirror_type((lv)) && !lv_is_raid((lv)))
> >+
> 
> In fact - there should be rather fixed the problem of using  mirror_type for
> raids.   These to targets are quite different and should not share internal
> flags - since it leads to many other internal bugs where code tries to
> run mirror repair operations on raid devices.
> 
> So instead we should separate and fix usage of  lv_is_mirror_type purely for
> old mirrors to avoid confusion.

Yeah, I went down that path... until it became too big a mess to untangle
right now.  So this is a temporary solution.

> >  /* Test if given LV is visible from user's perspective */
> >  int lv_is_visible(const struct logical_volume *lv);
> >+int lv_is_invisible(const struct logical_volume *lv);
> 
> !lv_is_visible   is common way for code - so I would avoid to add
> new func for this.

Yeah, I had that... until ls_is_name had to report the inverse which was
more offensive than this addition.

> >+static const char *lv_is_name(struct logical_volume *lv)
> >+{
> >+	if (lv_is_external_origin(lv))
> >+		return "external_origin";
> >+
> 
> There is already a reporting function for this with new Petr's patches.

Yeah, I looked at that, but it was not evident how to use it here, or if
it would really report what we needed here.  I'd be happy if someone
replaced this with something better.

> >+		if (lv_is_external_origin(metadata_lv) ||
> >+		    lv_is_thin_type(metadata_lv) ||
> >+		    lv_is_external_origin(metadata_lv) ||
> >+		    lv_is_really_mirror_type(metadata_lv) ||
> >+		    lv_is_raid_image(metadata_lv) ||
> >+		    lv_is_raid_metadata(metadata_lv) ||
> >+		    lv_is_cache_type(metadata_lv) ||
> >+		    lv_is_virtual(metadata_lv) ||
> 
> Many of those types are already skipped because they are invisible.
> So I think this list should be much shorter.

Probably, but redundant checks are safer than missing some.

> >@@ -2716,12 +2824,6 @@ static int _lvconvert_pool(struct cmd_context *cmd,
> >  				  display_lvname(metadata_lv));
> >  			return 0;
> >  		}
> >-		if (lv_is_thin_type(metadata_lv) ||
> >-		    lv_is_cache_type(metadata_lv)) {
> >-			log_error("Can't use thin or cache type LV %s for pool metadata.",
> >-				  display_lvname(metadata_lv));
> >-			return 0;
> >-		}
> 
> don't remove

Hm, those should be included in the new combined check... will verify that.

> >-	if (!lv_is_visible(pool_lv)) {
> >-		log_error("Can't convert internal LV %s.", display_lvname(pool_lv));
> >-		return 0;
> >-	}
> >-
> >-	if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
> >-		log_error("Mirror logical volumes cannot be used as pools.\n"
> >-			  "Try \"raid1\" segment type instead.");
> >-		return 0;
> >-	}
> >-
> 
> Don't remove

same

> >-	if (lv_is_pool(origin) || lv_is_cache_type(origin)) {
> >-		log_error("Can't cache pool or cache type volume %s.",
> >-			  display_lvname(origin));
> 
> don't remove

same


