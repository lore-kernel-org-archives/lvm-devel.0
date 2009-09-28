From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 28 Sep 2009 13:59:17 -0400 (EDT)
Subject: Re: [PATCH]: unify logical volume structure initialization
In-Reply-To: <20090928174008.GI5351@agk-dp.fab.redhat.com>
References: <Pine.LNX.4.64.0909240857590.7388@hs20-bc2-1.build.redhat.com>
	<20090928174008.GI5351@agk-dp.fab.redhat.com>
Message-ID: <Pine.LNX.4.64.0909281352280.26755@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Mon, 28 Sep 2009, Alasdair G Kergon wrote:

> >  		} else {
> >  			lv->minor = -1;
> >  		}
> > -		lv->snapshot = NULL;
> > -		dm_list_init(&lv->snapshot_segs);
> > -		dm_list_init(&lv->segments);
> > -		dm_list_init(&lv->tags);
> > +		lv_init(lv);
> 
> Already initialised AFAICT.

No, it isn't ... if you look up at this function (import_pool_lvs), 
there's: lv = dm_pool_zalloc(mem, sizeof(*lv)

> > -	lv->snapshot = NULL;
> > -	dm_list_init(&lv->snapshot_segs);
> > -	dm_list_init(&lv->segments);
> > -	dm_list_init(&lv->tags);
> > -	dm_list_init(&lv->segs_using_this_lv);
> > +	lv_init(lv);
>   
> I prefer including these with the allocation in an alloc_lv().

If you want to make a single function that allocates lv and initializes 
it, do it (and don't use dm_pool_zalloc then).

The requirement is this: there must be a central point where the lv 
entries are initialized. So that if someone adds new entries, he writes 
the initialization only in one place. If you want to unify allocation and 
initialization, it is possible, just do it (but it requires somehow bigger 
code change than this patch).

Mikulas

> Alasdair
> 


