From: Petr Rockai <prockai@redhat.com>
Date: Tue, 11 May 2010 14:21:37 +0200
Subject: LVM2/test Makefile.in test-utils.sh
In-Reply-To: <4BE3BFC8.6070608@redhat.com> (Zdenek Kabelac's message of "Fri, 
	07 May 2010 09:22:48 +0200")
References: <20100506185453.2064.qmail@sourceware.org>
	<4BE3BFC8.6070608@redhat.com>
Message-ID: <87bpcmljce.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> daemons/dmeventd/plugins/mirror daemons/dmeventd/plugins/snapshot shouldn't be
> here at all - these should be loaded via configurable plugin path - and we
> need some more updates even on dlopen part of code (as we move plugins to
> subdir of libdir.  Another thing that needs to be changed is the configurable
> comunication fifo.
Feel free to fix it.

> At this moment dmeventd is not yet ready for parallel testing.
Who cares? The tests skip if any dmeventd is running in the system --
the same approach as with clvmd. You can't run two clvmd tests in
parallel either... It works for what I need it for. If you need more,
patches welcome of course.

Yours,
   Petr.


