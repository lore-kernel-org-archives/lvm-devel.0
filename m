From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 30 Nov 2009 09:50:18 +0000
Subject: [PATCH] Optionally abort on internal errors.
In-Reply-To: <87ocml3zeu.fsf@twilight.int.mornfall.net.>
References: <87ocml3zeu.fsf@twilight.int.mornfall.net.>
Message-ID: <20091130095018.GB22702@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Nov 29, 2009 at 08:26:49PM +0100, Peter Rockai wrote:
> a fairly straightforward patch adding a configure option that will
> abort() the process in case it encounters an internal
> error. Undocumented so far and not sure it's appropriate to expose --
> but maybe we have a policy of no undocumented options?

It should be added to docs/example.conf at the end of the global section.
(The connection with 'log' is only an implementation detail -
conceptually it's a 'global' option.)

Ack.
 
Alasdair


