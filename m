From: Joe Thornber <thornber@redhat.com>
Date: Wed, 17 Jun 2020 10:18:45 +0100
Subject: Reg dm-cache-policy-smq
In-Reply-To: <CAHFy8gB2RdbJx_S-krDcQ91+qhGQkt_TUYwyeCGfCg9c2quTFw@mail.gmail.com>
References: <CAHFy8gB2RdbJx_S-krDcQ91+qhGQkt_TUYwyeCGfCg9c2quTFw@mail.gmail.com>
Message-ID: <20200617091845.6jeooa5llthuvimo@reti>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jun 16, 2020 at 04:19:29PM +0530, Lakshmi Narasimhan Sundararajan wrote:

> Is this a bug or am I reading it wrong?

I agree it looks strange; I'll do some benchmarking to see how setting to min
effects it.

> 2/ Also I see there aren't any tunables  for smq. Probably that was
> the original design goal. But I have been testing with cache drives of
> sizes nearing 1TB on a server class system with multi container
> systems.
> I am seeing largish IO latency sometimes way worse than the origin device.
> Upon reading the code, I am sensing it may be because of an incoming
> IO  hitting an inprogress migration block, thereby increasing io
> latency.
> 
> Would that be a possible scenario?

Yes, this is very likely what is happening.  It sounds like your migration_threshold may
be set very high.  dm-cache is meant to be slow moving so I typically have it as a small
multiple of the block size (eg, 8).

> 3/
> As a thumb rule, I am keeping the migration threshold at 100 times
> cache block size. So apart from controlling cache block size, are
> there any other way to control the IO latency on a cache miss.

That seems v. high.

Depending on your IO load you may find dm-writeboost gives you better latency.

- Joe


