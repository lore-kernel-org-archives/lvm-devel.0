From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 17:40:49 +0000
Subject: LVM2/daemons/clvmd lvm-functions.c
In-Reply-To: <20101129110515.8572.qmail@sourceware.org>
References: <20101129110515.8572.qmail@sourceware.org>
Message-ID: <20101129174049.GR29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Nov 29, 2010 at 11:05:15AM -0000, zkabelac at sourceware.org wrote:
> 	Remove printing of LCK_CACHE
 	
But straightforward to fix so it still gets printed (somewhere)?

> 	If the LCK_CLUSTER should be printed here - lot of code need
> 	to be reworked - so adding FIXME comment.
 
With code like:
  (lock_flags & LCK_CLUSTER_VG)
LCK_CLUSTER_VG (I presume you meant) should it be handled by decode_flags?

> + * FIXME: 8bit value passed here -
> + *        so only LCK_XXX defines < 0x100 can be decoded

(Not really the thing to fix.)

Alasdair


