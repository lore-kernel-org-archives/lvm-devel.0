From: Joe Thornber <thornber@redhat.com>
Date: Fri, 19 Jun 2020 11:06:20 +0100
Subject: Reg dm-cache-policy-smq
In-Reply-To: <CAHFy8gDzCn8UKTQhAv+9FsgMDzdSjPj5w1g6cA-v4O84VKwprw@mail.gmail.com>
References: <CAHFy8gB2RdbJx_S-krDcQ91+qhGQkt_TUYwyeCGfCg9c2quTFw@mail.gmail.com>
	<20200617091845.6jeooa5llthuvimo@reti>
	<CAHFy8gDzCn8UKTQhAv+9FsgMDzdSjPj5w1g6cA-v4O84VKwprw@mail.gmail.com>
Message-ID: <20200619100620.uwtfxwrjobpzazav@reti>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 19, 2020 at 01:20:42PM +0530, Lakshmi Narasimhan Sundararajan wrote:
> Hi Joe,
> Thank you for your reply.
> 
> I have a few followup questions, please do help me with my understanding.
> 1/ Does configured migration threshold account for active IO migration
> of dirty cache blocks in addition to cache block migration to/from
> cache device?
> My understanding is migration threshold only control promotion and
> demotion IO, and does not affect dirty IO writeback.

Yes, looking at the code this seems to be the case.

> Although all of these get queued to background worker thread, which
> can only actively do 4K max requests, so there is a max limit to the
> migration bandwidth at any point in time from the origin device.

One confusing aspect of the migration threshold is it's talking about
the max queued migration io at any particular time,  _not_ IO per second.
I think this makes it very unintuitive for the sys admins to set.  If
I ever do any more work on dm-cache then removing migration_threshold
would be my priority.

> 
> 2/ Reading the smq caching policy, I see that the cache policy is slow
> to cache and has no sense to track sequential or random traffic.
> So the initial IO may never be cached. But one does rely on cache hit
> ratio to be poor, and so the threshold for promotion is likely to be
> lower, thereby enabling hotspots to promote faster even on random
> access? Do you have any simulation results you can share with me over
> dm-cache-smq to help understand smq behavior for random/sequential
> traffic patterns?

See below, in particular the FIO tests are essentially random IO.
dm-cache used to have an io-tracker component that was used to assess
how sequential or random io was and weight the promotion chances based
on that (spindles being good at sequential io).  But I took it out in the
end; benchmarks didn't show particular benefit.


> 
> 3/ How does dm-writeboost compare for stability, I do not see it yet
> integrated to the mainline. How are lvm supporting it?


Sorry, I meant writecache, there have been so many similarly named targets
over the years.  See below.

> 4/ There exists also a dm-writecache, is it stable? Is lvm ready to
> use dm-writecache? Any idea which distro has it integrated and
> available for use?

I believe LVM support will be in the next release of RHEL8.  It's coming
out of experimental state.  I did some benchmarking a few months ago
comparing it with dm-cache (see below).  My impressions are that it's
a solid implementation, and a lot simpler than dm-cache (so possibly
more predictable).  It's main drawback is being focussed on writes only.
I think there are still some features lacking in the LVM support compared
to dm-cache (Dave Teigland can give more info).


- Joe


Here's an internal email discussing benchmark results from Feb 2020:




More test results for writecache and dm-cache.

I'd hoped that we'd be able to give clear advise to our customers
about how to choose which cache to use.  But the results are mixed;
more discussion at the end of the email.

Git extract test
================

A simple test that completely killed the previous third party attempts
to write a 'writecache' target.

It creates a new fs on the cached device.  No discard is used by the mkfs,
because dm-cache tracks discarded regions and can get more performance
when writing data to a discarded region, which I feel is not indicative
of general performance.

Then a v. large git repo is cloned to the cached device.  This part is
purely write based (as far as the cache is concerned).

Then 20 different tags are checked out in the git repo.  This part is mixed
read/write load.  All reads are to areas that have been written to earlier 
in the test.

I like to repeat the same test with a range of different 'fast' device
sizes given in meg.  Starting well below the working set for the task,
and ending up larger.

	writecache		dm-cache		
	clone	checkout	clone	checkout
64	31	366		37.2	359.6
256	33	353		36.2	339.8
512	34	291		35	351.1
1024	30	244		30.9	212.6
1536	28	242		26.6	147.4
2048	25	240		23.7	118.1
4096	21	110		20.8	79.6
8192	22	88				
16384	21	90			
							
		clone	checkout					
raw NVMe	23	76					


The dm-cache results are as I would expect.  If the fast device is tiny
compared the the working set then we get poor performance (which could
be tweaked by reducing the migration_threshold tunable).  But as the
available fast device goes up we see real value.

I'd expected writecache to do better here, since we only ever read what's
just been written.  But I think the volume of writes is such that the fast
device is filling up and forcing writecache to writeback before it can cache
any more writes.  It's rare (artificial) for writecache to need more space
than dm-thin. 



Git extract only
================

Like the previous test except the mkfs and git clone are performed on the
origin, and then the caches are attached.  This means the reads are generally
not to areas that have previously been written to.

I've run the checkout part twice to see how the caches adapt (dm-cache is a
slow moving cache after all).


	writecache		dm-cache	
	Pass 1	Pass 2		Pass 1	Pass 2
256	355	365		335.8	351.1
512	290	305		320.8	345.4
1024	242	254		190	170.4
1536	241	242		150.6	98.6
2048	240	238		150.1	100.1
4096	240	239		154.5	101.1

You can see dm-cache adapting nicely here.



FIO benchmarks
==============

I also have some standard FIO tests that I run.  One profile was given
to me by the perf team and is meant to simulate a database workload
(random 8k io, biased to some regions).

dm-cache uses a 32k block size, so the 8k ios will force a full copy when
a block is promoted to the fast device.

I run fio twice to see how the caches warm up.


100% read
---------

	writecache (s)		dm-cache (s)	
	Pass 1	Pass 2		Pass 1	Pass 2
128	241	230		190	162
256	239	230		169	146
512	230	230		159	111
1024	230	230		110	13.4
2048	230	230		103	4.8
4096	230	230		103	4.4
8192	230	230		104	4.7

Obviously this it totally unfair to writecache.


50% read/write
---------------

	writecache (s)		dm-cache (s)	
	Pass 1	Pass 2		Pass 1	Pass 2
128	127	131		213	181
256	101	108		211	189
512	71	71		173	108
1024	62	46		130	19
2048	62	46		111	6
4096	62	46		109	5.8
8192	62	46		110	6.1

writecache wins on the first pass while dm-cache has been frantically
promoting blocks to the fast device.  dm-cache gets it's payoff
on the second pass.


100% write
----------

	writecache (s)		dm-cache (s)	
	Pass 1	Pass 2		Pass 1	Pass 2
128	88.7	107		232	201
256	59	96		225	209
512	9.6	72		185	112
1024	2.3	2.5		127	24
2048	2.6	2.4		113	2.7
4096	2.4	2.4		113	2.6
8192	2.4	2.6		114	2.7

writecache's time to shine.


How do you decide which cache to use?
=====================================

This isn't easy to answer.  Let's play 20 questions instead (questions
should be answered in order).


1. Do you need writethrough mode?   --- Yes --->    Use dm-cache

2. Do you repeatedly do IO to the same parts of the disk?   --- Yes --->   Use dm-cache

  For instance your server may be constantly hitting the same database
  tables.

  Hot spots are really dm-cache's thing.  For instance, if I set up a
  cache with 8G NVME and a 16G origin and then repeatedly zero the first
  1G of the cache.  You'd think that this is playing to writecache's strengths,
  but the timings for JT machine are:

    writecache: 0.88, 1.37, 1.37, 1.37 ...
    dm-cache:   0.91, 0.86, 0.86, 0.87 ...

  writecache is doing great here (spindle would be ~5 seconds).  But it can't
  compete with dm-cache which has just moved the first gig to the fast dev.

3. Is the READ working set small enough to fit in the page cache?  --- Yes --->   Use writecache  

  writecache and the page cache work together.  If the page cache is supplying all your
  read caching needs then you're just left with write io.


Other things to consider:

- Do you use applications that skip the page cache?

  For instance databases often use O_DIRECT, libaio and manage their own read
  caches.




