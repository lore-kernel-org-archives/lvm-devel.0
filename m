From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 29 Mar 2010 11:13:44 -0400
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenode.c
In-Reply-To: <871vf3b3cb.fsf@twilight.int.mornfall.net.>
References: <20100326154537.2860.qmail@sourceware.org>
	<871vf3b3cb.fsf@twilight.int.mornfall.net.>
Message-ID: <20100329151343.GA20880@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Mar 29 2010 at 10:38am -0400,
Petr Rockai <prockai@redhat.com> wrote:

> Hi!
> 
> snitzer at sourceware.org writes:
> > Modified files:
> > 	.              : WHATS_NEW 
> > 	daemons/clvmd  : clvmd-singlenode.c 
> >
> > Log message:
> > 	Use a real socket for singlenode clvmd to fix clvmd's high cpu load.
> Interesting. Is this because /dev/null is always "ready" for reading?

Yes, daemons/clvmd/clvmd.c:main_loop's select() on /dev/null appears to
be the problem.  If I set the associated listen_fd to be nonblocking the
CPU load goes from 100%+ to ~80%.  But with the committed "fix" cpu load
(when clvmd is idle) is now ~1% (on my f12 kvm guest).

> Is there a less complicated workaround for that problem?

I haven't looked for an alternative.  Not really seeing the current fix
as overly complicated.  Its pretty standard socket code, which Milan
started, that I then refined to be modeled after
daemons/clvmd/clvmd.c:open_local_sock().  For that matter, we could have
a single function that is used for both (reducing the perceived
complexity of the clvmd-singlenode.c:init_comms).

Mike


