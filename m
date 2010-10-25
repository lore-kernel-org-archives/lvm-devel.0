From: Milan Broz <mbroz@redhat.com>
Date: Mon, 25 Oct 2010 08:19:11 +0200
Subject: [RFC][PATCH] never scan a device which is using the error target
In-Reply-To: <20101025010031.GA26942@agk-dp.fab.redhat.com>
References: <20101024005515.GA31723@redhat.com>
	<20101025010031.GA26942@agk-dp.fab.redhat.com>
Message-ID: <4CC5215F.4080304@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/25/2010 03:00 AM, Alasdair G Kergon wrote:

> So you may (for now) need a more specific test that's limited
> to snapshot merge.

ok. But with this approach we will have just code full of strange
exceptions.

I thought about "error" device as replacement for "failed" device,
so with this definition it should not be scanned or used.

But we are now apparently using error device as some padding
in intermediate state...

Just ad idea: should not be here special alias for it?
Like "failed" target + "error" target?

The logic "what if error is just one line in table" - the logic
is wrong there already - what if mirror is just part of table?
Now is excluded completely.

Also "suspended" state is state for LUKS device after luksSuspend,
(with volume key wiped) should I add another special exception for that?
...

Isn't there some better approach? Last 2 or 3 deadlocks with
clusters were caused by this code too, seems like candidate for rewrite:)

Milan


