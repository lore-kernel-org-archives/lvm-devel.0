From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 28 Sep 2009 19:17:06 +0100
Subject: Re: [PATCH]: unify logical volume structure initialization
In-Reply-To: <Pine.LNX.4.64.0909281352280.26755@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.0909240857590.7388@hs20-bc2-1.build.redhat.com>
	<20090928174008.GI5351@agk-dp.fab.redhat.com>
	<Pine.LNX.4.64.0909281352280.26755@hs20-bc2-1.build.redhat.com>
Message-ID: <20090928181706.GJ5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > Already initialised AFAICT.
> No, it isn't ... if you look up at this function (import_pool_lvs), 
> there's: lv = dm_pool_zalloc(mem, sizeof(*lv)
 
After applying the patch I got 2 x lv_init() on the same lv and so I
removed the second one.  The pool code began as a copy of the format1 code
so I'm not sure how the duplicate initialisation crept in.

> The requirement is this: there must be a central point where the lv 
> entries are initialized. So that if someone adds new entries, he writes 
> the initialization only in one place. If you want to unify allocation and 
> initialization, it is possible, just do it (but it requires somehow bigger 
> code change than this patch).
 
Indeed - that's what lv_create_empty() was meant to be (and what new code
should be trying to use).

Alasdair


