From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Wed, 6 Jul 2011 14:38:14 +0300
Subject: `pvmove stuck' in RH bugzilla
In-Reply-To: <20110706112359.GF5448@agk-dp.fab.redhat.com>
References: <20110706095310.GA3225@swordfish>
	<20110706112359.GF5448@agk-dp.fab.redhat.com>
Message-ID: <20110706113814.GA3215@swordfish.minsk.epam.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On (07/06/11 12:23), Alasdair G Kergon wrote:
> On Wed, Jul 06, 2011 at 12:53:10PM +0300, Sergey Senozhatsky wrote:
> > I think we just trapped into the same trouble with pvmove as described in 
> > https://bugzilla.redhat.com/show_bug.cgi?id=602516
> > https://bugzilla.redhat.com/show_bug.cgi?id=706036
> > 
> > Alasdair, could you please point are those patches in vanilla kernel 
> > (3.0-rc*) or linux-next, or some RH internal tree? 
> > This is not critical, though I'd like to try out patches.
>  
> This is a userspace bug not a kernel one.
> There is a workaround, which is to perform the pvmove one LV at a time
> using the --name option.  (For each LV, run pvmove -n <lvname>.)
> 
> The patched code is in the upstream lvm2 repository:
>   git://sources.redhat.com/git/lvm2
>   http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/?cvsroot=lvm2
>   http://sourceware.org/lvm2/
> 
> It was only last night that the code incorporating these changes passed
> our public testsuite for the first time, so I think it is still
> premature to be using this on production systems.  But this means I hope
> to be in a position to make the first development release containing a
> fix for the problems quite soon.  (I added assertions to catch other
> instances of the related problems - it was more than just pvmove
> affected.)
> 

Thanks a lot for your reply.
We don't have a production machines here (just internal servers),
so I guess I could give it a try.


Best,
	Sergey
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 316 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110706/ca5ad5e1/attachment.sig>
