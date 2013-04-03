From: David Teigland <teigland@redhat.com>
Date: Wed, 3 Apr 2013 11:22:37 -0400
Subject: duplicate pv names
In-Reply-To: <87r4isklih.fsf@mornfall.net>
References: <20130402212408.GA1923@redhat.com>
 <87r4isklih.fsf@mornfall.net>
Message-ID: <20130403152237.GA1031@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 03, 2013 at 11:32:06AM +0200, Petr Rockai wrote:
> I ran into similar problems with a different set of patches, that remove
> pv_read. What I'll probably need to do is adding a list of devices to
> PVs, so we can check whether something on the command line matches any
> of the "duplicate" PVs.
> 
> I see you make quite heavy use of pv_read in your new version of
> process_each_pv. You can have a look at:
> 
> (git clone) http://repos.mornfall.net/lvm2/mornfall.git
> 
> branch "merged" or for more limited view of the pv_read removal patches,
> branch "lvmcache". (git checkout origin/merged).

I wish I'd known you were also working on toollib.c; we could have
coordinated the sequence of changes a little better.  Perhaps we could
all push our in-progress work to an lvm2.git branch like I've done in
http://git.fedorahosted.org/cgit/lvm2.git/log/?h=dev-dct-process-each

> It would be good if we could get rid of pv_read, as the code for
> handling nomda PVs is wrong anyway, and we always need to scan. I think
> the only remaining issue with the non-pv_read version is the duplicate
> handling as outlined above.

OK, it'll be nice to get rid of the nomda case.  I'll study your changes
further and try to rework my new process_each_pv to avoid using pv_read.
Perhaps you'll then be able to drop the toollib commit in your tree.


