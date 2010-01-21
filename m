From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 21 Jan 2010 00:24:37 +0000
Subject: [PATCH 0 of 10] LVM: mirrored/redundant/duplicate mirror log
In-Reply-To: <4B578EC6.30104@redhat.com>
References: <1263954062.22044.9.camel@hydrogen.msp.redhat.com>
	<4B578EC6.30104@redhat.com>
Message-ID: <20100121002437.GC22661@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jan 20, 2010 at 06:16:22PM -0500, Takahiro Yasui wrote:
> "reduntant" is used such as by "redundant system," and familiar key word

My point is that the log is not redundant.

There are two copies of the log data - one is necessary, the other could be
considered redundant.  But the descriptive term here describes the *entire*
log, only part, not all, of which is "redundant".

Alasdair


