From: Brassow Jonathan <jbrassow@redhat.com>
Date: Thu, 24 Apr 2014 15:15:26 -0500
Subject: [POC PATCH] All or nothing pvmove.
In-Reply-To: <1398364838.26048.2.camel@f16>
References: <1398364838.26048.2.camel@f16>
Message-ID: <C9975A81-A7E6-4A17-A09E-2E2AB6DFA7E3@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Apr 24, 2014, at 1:40 PM, Jonathan Brassow wrote:

> The attached patch is only a proof-of-concept that shows how we might go
> about using 'nosync' mirrors for COMPLETE segments.  It does not yet
> handle important topics, including:
> - machine failure:  If there are outstanding writes to COMPLETE segments,
>  we cannot simply use 'nosync' when restarting the pvmove.  This would
>  lead to loss of data.  We could either use a log/bitmap with the mirror
>  and not use 'nosync', or we could write a flag to the pvmove segment in
>  the metadata that tells us whether the VG was shutdown cleanly or not.
>  If cleanly, we can safely use 'nosync' on COMPLETE segments; otherwise,
>  we cannot.

A slightly less desirable but still functionally correct solution might simply be that the sync needs to start from the beginning when a pvmove is activated.  This would be quick to implement, but we would want to move on to another solution at some point.  In the meantime, users who choose the all-or-nothing approach would need to know that if the pvmove volume needed to be reactivated, it would be forced to start from the beginning.  If they should choose the one-by-one approach (i.e. the current method), any completed segments would not need to be re-copied.

 brassow



