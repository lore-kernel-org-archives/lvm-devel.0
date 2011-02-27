From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 27 Feb 2011 13:54:06 +0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/confi ...
In-Reply-To: <4D6A2C2B.10209@redhat.com>
References: <20110227003833.23186.qmail@sourceware.org>
	<4D6A2C2B.10209@redhat.com>
Message-ID: <20110227135405.GY3626@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Feb 27, 2011 at 11:49:15AM +0100, Milan Broz wrote:
> no change in man page (--alloc description) needed here?

No changes were made to the formal definitions of the alloc modes.
(Log placement was deliberately never documented.)
So there's only lvm.conf to update (which is probably still missing 
several other changes too) and an lvcreate example that somehow
got in and went beyond the strict policy defition.

But I want to get more feedback on the change first before tidying
all that up, in case people do find they need easy command line
control - I'm hoping they won't, and the latest implementation
of the normal policy's "common sense" behaves better.
 
Alasdair


