From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 8 Jul 2009 13:37:47 +0100
Subject: Re: [PATCH] more segtypes in one library
In-Reply-To: <Pine.LNX.4.64.0906250938160.6612@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.0906250938160.6612@hs20-bc2-1.build.redhat.com>
Message-ID: <20090708123746.GO11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jun 25, 2009 at 10:04:14AM -0400, Mikulas Patocka wrote:
> This is the patch for more segtypes in one shared library. You define 
> function init_segtypes (instead of init_segtype) and this function can 
> register arbitraty number of segtypes with lvm_add_segtype. It returns 
> nonzero on success or zero on failure (in this case, the registered 
> segtypes are destroyed and the library is unloaded).
> The old function init_segtype to init one segtype is still available, so 
> it doesn't break binary compatibility.

I've modified it a bit (passed a new struct instead of using the static,
added warning if both interfaces defined) and checked it in.
 
Alasdair


