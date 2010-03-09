From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 9 Mar 2010 03:38:18 +0000
Subject: userspace patches for shared snapshots
In-Reply-To: <Pine.LNX.4.64.1003082209210.21624@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1002101858410.15802@hs20-bc2-1.build.redhat.com>
	<20100225221324.GA29946@redhat.com>
	<Pine.LNX.4.64.1002252327100.29287@hs20-bc2-1.build.redhat.com>
	<20100226211702.GA23893@redhat.com>
	<20100303223740.GA12242@redhat.com>
	<Pine.LNX.4.64.1003040502020.16112@hs20-bc2-1.build.redhat.com>
	<20100304132228.GA20534@redhat.com>
	<Pine.LNX.4.64.1003082209210.21624@hs20-bc2-1.build.redhat.com>
Message-ID: <20100309033818.GB27306@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A forward goto is unlikely to get through without a decent name (I don't
think 'midcycle' tells me much useful) and (very brief) explanation of the
non-standard code structure in the comment: it'll need people like me to
understand that any other way of structuring it (including moving some
of the code out to a function or 'rotating' the loop or having an ugly
'first time' variable) would be significantly (not merely slightly) more
convoluted or harder to understand.

Alasdair


