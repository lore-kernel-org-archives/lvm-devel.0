From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 25 Oct 2010 19:59:56 +0100
Subject: [RFC][PATCH] never scan a device which is using the error target
In-Reply-To: <4CC5215F.4080304@redhat.com>
References: <20101024005515.GA31723@redhat.com>
	<20101025010031.GA26942@agk-dp.fab.redhat.com>
	<4CC5215F.4080304@redhat.com>
Message-ID: <20101025185956.GA29098@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

See the FIXMEs in the code.
With mirrors it already excludes more devs that it actually needs to.

And of course you know what I'd say the right answer is:-)
The entire scanning logic should be outside lvm...

Alasdair


