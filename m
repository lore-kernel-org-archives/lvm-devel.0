From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 13 May 2009 02:54:41 +0100
Subject: [PATCH] Remove NON_BLOCKING flag from the tools and set a policy to auto-set.
In-Reply-To: <1242166871-25734-3-git-send-email-dwysocha@redhat.com>
References: <1242166871-25734-1-git-send-email-dwysocha@redhat.com>
	<1242166871-25734-2-git-send-email-dwysocha@redhat.com>
	<1242166871-25734-3-git-send-email-dwysocha@redhat.com>
Message-ID: <20090513015441.GC10652@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 12, 2009 at 06:21:11PM -0400, Dave Wysochanski wrote:
> As a simplification to the tools and further liblvm, this patch pushes
> the setting of NON_BLOCKING lock flag inside the lock_vol() call.
> The policy we set is if any existing VGs are currently locked, we
> set the NON_BLOCKING flag.
 
Ack, assuming you checked all the places setting it today have
VG locks already held.

Alasdair


