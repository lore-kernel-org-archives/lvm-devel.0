From: Petr Rockai <prockai@redhat.com>
Date: Mon, 26 Mar 2012 11:04:57 +0200
Subject: LVM2/test/lib aux.sh test.sh utils.sh
In-Reply-To: <20120320105158.7804.qmail@sourceware.org>
	(zkabelac@sourceware.org's message of "20 Mar 2012 10:51:58 -0000")
References: <20120320105158.7804.qmail@sourceware.org>
Message-ID: <87haxbspfq.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

zkabelac at sourceware.org writes:
> 	Make the teardown really usable - it will try down to remove all the left
> 	devices even from previous test runs
> 	(the only missing piece is probably proper mdadm teardown)
> 	Add few more local vars
> 	Try to setup PATH and LD_LIBRARY_PATH just once.
> 	Try shorter sleeps.

The problem with this is that it breaks parallel runs (someone already
broke them earlier, I know). I would be grateful if this rampant
cleaning up could be at least made optional.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


