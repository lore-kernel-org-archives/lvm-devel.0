From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 22 Aug 2007 15:45:05 +0100
Subject: [LVM2 PATCH] (3/5) Remove unused parameters from _allocate()
In-Reply-To: <46CB5834.2030307@ce.jp.nec.com>
References: <46CB5834.2030307@ce.jp.nec.com>
Message-ID: <20070822144504.GG2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Aug 21, 2007 at 05:25:08PM -0400, Jun'ichi Nomura wrote:
> This patch removes unused 'stripes', 'mirrors', 'status' and
> 'segtype' parameters from _allocate() in lib/metadata/lv_manip.c.
> 'stripes' and 'mirrors' can be found in struct alloc_handle.
> 'status' and 'segtype' aren't there but if future code requires them,
> they can be embedded in struct alloc_handle, too.
 
They date from before that function was split into two and are
no longer needed.

Alasdair
-- 
agk at redhat.com


