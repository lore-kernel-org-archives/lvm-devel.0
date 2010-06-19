From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 19 Jun 2010 01:55:27 +0100
Subject: [PATCH] Missing error checking in cmirrord
In-Reply-To: <1276895420.26585.1.camel@hydrogen.msp.redhat.com>
References: <1276895420.26585.1.camel@hydrogen.msp.redhat.com>
Message-ID: <20100619005527.GL15698@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 18, 2010 at 04:10:20PM -0500, Jon Brassow wrote:
> There are missing error checks... it's possible for
> sprintf to fail.
 
And an inline comment to explain how data has an adequate minimum size
perhaps?

Alasdair


