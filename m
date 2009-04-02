From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 2 Apr 2009 15:42:26 +0100
Subject: [PATCH] fix _copy_pv to allocate even new pv->vg_name
In-Reply-To: <49D4C98A.5050906@redhat.com>
References: <49D4C98A.5050906@redhat.com>
Message-ID: <20090402144226.GS13664@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 02, 2009 at 04:19:54PM +0200, Milan Broz wrote:
> Allocate new pv->vg_name from pool, it can be destroyed later.
 
Ack.

Alasdair
-- 
agk at redhat.com


