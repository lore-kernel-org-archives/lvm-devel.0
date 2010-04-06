From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 6 Apr 2010 14:03:17 +0100
Subject: [PATCH 2/5] Refactor _read_pv() code that updates vg->extent_count and vg->free_count.
In-Reply-To: <1270497099-13259-3-git-send-email-dwysocha@redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-2-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-3-git-send-email-dwysocha@redhat.com>
Message-ID: <20100406130317.GB30760@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 05, 2010 at 03:51:36PM -0400, Dave Wysochanski wrote:
> Simple refactor to mov code that updates the vg extent counts from a
> single pv's counts close to the code that adds a pv to vg->pvs and
> updates vg->pv_count.  No functional change.
 
Ack.

Alasdair


