From: Paul B. Henson <henson@acm.org>
Date: Wed, 5 Feb 2014 17:36:23 -0800
Subject: cache support
In-Reply-To: <52F2AD44.8030006@redhat.com>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>	<52F205CA.1090807@redhat.com>	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>
	<52F2AD44.8030006@redhat.com>
Message-ID: <0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> From: Zdenek Kabelac
> Sent: Wednesday, February 05, 2014 1:30 PM
>
> lvm2 is not supporting caching of PVs - that's the layer below the lvm2.
Your
> proposed idea would be hard to efficiently implement.

Hmm, yes, I see what you mean. I guess to go that way I'd have to use
dm-cache directly or reconsider bcache to create a cached device to feed to
lvm as a PV.

> We may consider the option to use a single cache pool for multiple single
> linear LVs - since in this case we might be able to resolve tricky virtual
> mapping.

It would probably work out for my use case if the PV itself wasn't cached
but the entire SSD cache device could be shared amongst all of the LV's. I
really don't want to split the cache into separate pieces per LV though,
that's just not going to scale.

Thanks.



