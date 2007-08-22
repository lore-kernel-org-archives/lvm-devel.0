From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 22 Aug 2007 20:35:41 +0100
Subject: [LVM2 PATCH] (2/5) Fix lvconvert to pass correct parameter to allocate_extents()
In-Reply-To: <46CB582D.9070302@ce.jp.nec.com>
References: <46CB582D.9070302@ce.jp.nec.com>
Message-ID: <20070822193541.GI2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Aug 21, 2007 at 05:25:01PM -0400, Jun'ichi Nomura wrote:
> This patch fixes lvconvert_mirrors() to pass correct set of
> parameters to allocate_extents().

lvcreate and lvextend do this correctly as intended.

lvconvert (the new code) should do things the same way as those existing
callers.

Alasdair
-- 
agk at redhat.com


