From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 16 Aug 2010 16:34:02 +0100
Subject: [PATCH 2 of 3] Handle failures of mirror devices while under snapshot origin (bug 613829)
In-Reply-To: <1281911365.30206.6.camel@hydrogen.msp.redhat.com>
References: <1281911365.30206.6.camel@hydrogen.msp.redhat.com>
Message-ID: <20100816153401.GC11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Aug 15, 2010 at 05:29:25PM -0500, Jon Brassow wrote:
> The code that was evaluating the mirror status line for failure
> was not taking into account that a mirror might be under a
> snapshot origin.  This patch causes it to look at <lv>-real
> if necessary.
 
Ack.

Alasdair


