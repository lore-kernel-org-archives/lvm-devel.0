From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Fri, 19 Jun 2020 13:20:42 +0530
Subject: Reg dm-cache-policy-smq
In-Reply-To: <20200617091845.6jeooa5llthuvimo@reti>
References: <CAHFy8gB2RdbJx_S-krDcQ91+qhGQkt_TUYwyeCGfCg9c2quTFw@mail.gmail.com>
	<20200617091845.6jeooa5llthuvimo@reti>
Message-ID: <CAHFy8gDzCn8UKTQhAv+9FsgMDzdSjPj5w1g6cA-v4O84VKwprw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Joe,
Thank you for your reply.

I have a few followup questions, please do help me with my understanding.
1/ Does configured migration threshold account for active IO migration
of dirty cache blocks in addition to cache block migration to/from
cache device?
My understanding is migration threshold only control promotion and
demotion IO, and does not affect dirty IO writeback.
Although all of these get queued to background worker thread, which
can only actively do 4K max requests, so there is a max limit to the
migration bandwidth at any point in time from the origin device.

2/ Reading the smq caching policy, I see that the cache policy is slow
to cache and has no sense to track sequential or random traffic.
So the initial IO may never be cached. But one does rely on cache hit
ratio to be poor, and so the threshold for promotion is likely to be
lower, thereby enabling hotspots to promote faster even on random
access? Do you have any simulation results you can share with me over
dm-cache-smq to help understand smq behavior for random/sequential
traffic patterns?

3/ How does dm-writeboost compare for stability, I do not see it yet
integrated to the mainline. How are lvm supporting it?

4/ There exists also a dm-writecache, is it stable? Is lvm ready to
use dm-writecache? Any idea which distro has it integrated and
available for use?
I see rhel still reports it as experimental. Would love to hear your opinion.

Regards
LN







On Wed, Jun 17, 2020 at 2:49 PM Joe Thornber <thornber@redhat.com> wrote:
>
> On Tue, Jun 16, 2020 at 04:19:29PM +0530, Lakshmi Narasimhan Sundararajan wrote:
>
> > Is this a bug or am I reading it wrong?
>
> I agree it looks strange; I'll do some benchmarking to see how setting to min
> effects it.
>
> > 2/ Also I see there aren't any tunables  for smq. Probably that was
> > the original design goal. But I have been testing with cache drives of
> > sizes nearing 1TB on a server class system with multi container
> > systems.
> > I am seeing largish IO latency sometimes way worse than the origin device.
> > Upon reading the code, I am sensing it may be because of an incoming
> > IO  hitting an inprogress migration block, thereby increasing io
> > latency.
> >
> > Would that be a possible scenario?
>
> Yes, this is very likely what is happening.  It sounds like your migration_threshold may
> be set very high.  dm-cache is meant to be slow moving so I typically have it as a small
> multiple of the block size (eg, 8).
>
> > 3/
> > As a thumb rule, I am keeping the migration threshold at 100 times
> > cache block size. So apart from controlling cache block size, are
> > there any other way to control the IO latency on a cache miss.
>
> That seems v. high.
>
> Depending on your IO load you may find dm-writeboost gives you better latency.
>
> - Joe
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


