From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 16 Nov 2011 10:28:41 +0000
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <87ipmkxvlt.fsf@aldalome.int.mornfall.net.>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<4EC2E670.6000208@redhat.com>
	<20111116000020.GA3294@agk-dp.fab.redhat.com>
	<87ipmkxvlt.fsf@aldalome.int.mornfall.net.>
Message-ID: <20111116102841.GC3294@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 16, 2011 at 10:30:38AM +0100, Peter Rockai wrote:
> No, the real problem is that the snapshot is being filled and reaches
> the threshold again, after first extension is done. Nothing wrong with
> calculation.
 
Repeated extensions in those circumstances are OK.  If the user wants
a larger granularity, they can configure one.

Alasdair


