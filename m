From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 18 Mar 2010 00:47:46 +0000
Subject: [PATCH] Avoid scanning all pvs in the system if operating on a device with mdas.
In-Reply-To: <1268848742-27785-1-git-send-email-dwysocha@redhat.com>
References: <1268847147.2476.2.camel@f10-node1>
	<1268848742-27785-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20100318004746.GC17615@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 17, 2010 at 01:59:02PM -0400, Dave Wysochanski wrote:
> When we pv_read() a device that has an orphan vgname, we might need to scan
> the system to be sure this is true.  However, if the PV has mdas, there's
> no way possible for it to have an orphan vgname unless it is a true orphan.
> Some areas of the code were optimized to take advantage of this fact, while
> others were not (we would still do the expensive scan if a device had mdas
> but had an orphan VG).
> This patch unifies the code so that every place we are operating on such
> a PV, we skip the expensive scan if there are mdas.
 
Makes sense.
Ack.

Alasdair


