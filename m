From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 02:13:57 +0000
Subject: [PATCH 22/23] Remove dead assignment in dm_event_get_registered_device
In-Reply-To: <0e0eb44bdebea6c5d74cb20e3638987793fd4543.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<0e0eb44bdebea6c5d74cb20e3638987793fd4543.1292945707.git.zkabelac@redhat.com>
Message-ID: <20110105021356.GR10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 04:41:54PM +0100, Zdenek Kabelac wrote:
> ret assigned from _do_event was actually not used and replaced with next
> assignment without any read of returned value.
 
But does the actual error already get logged somewhere?
(I don't see where.)
Some _do_event() failures are reported, others aren't.  I don't see
why there's a distinction.

A DM_EVENT_CMD_REGISTER_FOR_EVENT failure is logged.
A DM_EVENT_CMD_GET_TIMEOUT failure is not.

Surely these failures should never occur on a properly-running system, so why
not log them all in a similar way?

Alasdair


