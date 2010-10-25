From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 25 Oct 2010 02:24:30 +0100
Subject: [RFC][PATCH] never scan a device which is using the error target
In-Reply-To: <20101025012304.GA5698@redhat.com>
References: <20101024005515.GA31723@redhat.com>
	<20101025010031.GA26942@agk-dp.fab.redhat.com>
	<20101025012304.GA5698@redhat.com>
Message-ID: <20101025012429.GC26942@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Oct 24, 2010 at 09:23:04PM -0400, Mike Snitzer wrote:
> What about skipping a dm device whose table only has a single error
> target?
 
That's OK.

Alasdair


