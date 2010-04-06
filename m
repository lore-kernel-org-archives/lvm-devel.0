From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 6 Apr 2010 13:59:40 +0100
Subject: [PATCH 1/5] Add pv to vg->pvs after check for maximum value of vg->extent_count.
In-Reply-To: <1270497099-13259-2-git-send-email-dwysocha@redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-2-git-send-email-dwysocha@redhat.com>
Message-ID: <20100406125940.GA30760@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 05, 2010 at 03:51:35PM -0400, Dave Wysochanski wrote:
> In add_pv_to_vg(), we should only add the pv to vg->pvs after all
> internal checks have passed.  The check for vg->extent_count exeeding
> maximum was after we added the pv to the list, so this function could
> return a state of vg->pvs that did not reflect other parameters such
> as vg->pv_count.
 
Ack.

Alasdair


