From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Tue, 16 Jun 2020 16:19:29 +0530
Subject: Reg dm-cache-policy-smq
Message-ID: <CAHFy8gB2RdbJx_S-krDcQ91+qhGQkt_TUYwyeCGfCg9c2quTFw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!
I was browsing dm-cache smq policy and have an observation, can
someone help with them?

1/

static void update_promote_levels(struct smq_policy *mq)
{
/*
* If there are unused cache entries then we want to be really
* eager to promote.
*/
unsigned threshold_level = allocator_empty(&mq->cache_alloc) ?
default_promote_level(mq) : (NR_HOTSPOT_LEVELS / 2u);

threshold_level = max(threshold_level, NR_HOTSPOT_LEVELS);

^^^ threshold_level seems to always be NR_HOTSPOT_LEVELS, was min()
intended instead of max()?

Is this a bug or am I reading it wrong?

2/ Also I see there aren't any tunables  for smq. Probably that was
the original design goal. But I have been testing with cache drives of
sizes nearing 1TB on a server class system with multi container
systems.
I am seeing largish IO latency sometimes way worse than the origin device.
Upon reading the code, I am sensing it may be because of an incoming
IO  hitting an inprogress migration block, thereby increasing io
latency.

Would that be a possible scenario?

3/
As a thumb rule, I am keeping the migration threshold at 100 times
cache block size. So apart from controlling cache block size, are
there any other way to control the IO latency on a cache miss.

Thanks


