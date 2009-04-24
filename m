From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 24 Apr 2009 01:30:17 +0100
Subject: LVM2/lib/metadata pv_map.c
In-Reply-To: <20090423164128.10352.qmail@sourceware.org>
References: <20090423164128.10352.qmail@sourceware.org>
Message-ID: <20090424003017.GB15019@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 23, 2009 at 04:41:28PM -0000, mornfall at sourceware.org wrote:
> 	Do not include MISSING_PVs in allocation maps.
 
Ack.

WHATS_NEW ?

> +		assert(pvl->pv->dev);
  
Please don't use 'assert'.  It bypasses our logging mechanisms
and aborts the code making debugging harder.

Use log_error() with an informative message instead, for example.

Alasdair
-- 
agk at redhat.com


