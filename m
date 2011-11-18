From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 18 Nov 2011 19:56:56 +0000
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <87obw9w6vv.fsf@aldalome.int.mornfall.net.>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
	<20111116105953.GD3294@agk-dp.fab.redhat.com>
	<20111116130734.GE3294@agk-dp.fab.redhat.com>
	<87y5vdwydx.fsf@aldalome.int.mornfall.net.>
	<4EC6927B.4000402@redhat.com>
	<87obw9w6vv.fsf@aldalome.int.mornfall.net.>
Message-ID: <20111118195656.GX3294@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Nov 18, 2011 at 08:46:44PM +0100, Peter Rockai wrote:
> that lvconvert did
> not change anything. We don't know 2 and wrongly assume that nothing
> changes, ever (that's the bug).
 
Yes, and we can detect 2 from the status line by checking whether the
device size changed, avoiding the need for the new exit code.

Alasdair


