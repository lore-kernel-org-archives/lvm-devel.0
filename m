From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 20 Apr 2010 10:36:23 -0400
Subject: fix topology test to work again
In-Reply-To: <87sk6qz65k.fsf@twilight.int.mornfall.net.>
References: <20100419225312.GA23512@redhat.com>
	<87sk6qz65k.fsf@twilight.int.mornfall.net.>
Message-ID: <20100420143623.GC7538@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 20 2010 at  7:59am -0400,
Petr Rockai <prockai@redhat.com> wrote:

> Hi,
> 
> Mike Snitzer <snitzer@redhat.com> writes:
> > Reintroduce teardown_() because t-topology-support.sh only needs a
> > subset of the full teardown() between each iteration of the topology
> > tests -- in particular the $TESTDIR must not get removed between each
> > topology test iteration.
> 
> I would prefer to have prepare_scsi_debug_dev changed to drop the
> devices and re-create them when invoked for the second time than to bend
> the teardown mechanism for something it is not intended for.

I can't say I agree with you here.  The previous split of teardown and
teardown_ made it possible to do what was done for the topology tests
(using a minimalist teardown to cleanup the device).  I made use of the
previous teardown split to add more functionality; no different than how
any code evolves.  Once code evolves we cannot just break that new
functionality when making new changes.

So I'd like to restore the topology test with the minimalist amount of
change.  Once it is back to working I can look at your suggestion of how
to change prepare_scsi_debug_dev, etc.

> Also,
> teardown/teardown_ is a poor distinction and does not say much about
> intended usage. You can of course re-use parts of teardown in your
> implementation, but please name the new function(s) appropriately in
> that case.

I'll rename teardown_

Thanks,
Mike


