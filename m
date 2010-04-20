From: Petr Rockai <prockai@redhat.com>
Date: Tue, 20 Apr 2010 13:59:19 +0200
Subject: [PATCH] fix topology test to work again
In-Reply-To: <20100419225312.GA23512@redhat.com> (Mike Snitzer's message of
	"Mon, 19 Apr 2010 18:53:12 -0400")
References: <20100419225312.GA23512@redhat.com>
Message-ID: <87sk6qz65k.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Mike Snitzer <snitzer@redhat.com> writes:
> Reintroduce teardown_() because t-topology-support.sh only needs a
> subset of the full teardown() between each iteration of the topology
> tests -- in particular the $TESTDIR must not get removed between each
> topology test iteration.

I would prefer to have prepare_scsi_debug_dev changed to drop the
devices and re-create them when invoked for the second time than to bend
the teardown mechanism for something it is not intended for. Also,
teardown/teardown_ is a poor distinction and does not say much about
intended usage. You can of course re-use parts of teardown in your
implementation, but please name the new function(s) appropriately in
that case.

> Also fix (and simplify) the unsafe scsi-debug device discovery in
> prepare_scsi_debug_dev().
Looks better indeed.

Yours,
   Petr.


