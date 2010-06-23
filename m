From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 23 Jun 2010 21:49:19 +0100
Subject: LVM2/tools lvconvert.c
In-Reply-To: <20100623203231.28578.qmail@sourceware.org>
References: <20100623203231.28578.qmail@sourceware.org>
Message-ID: <20100623204919.GC14902@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jun 23, 2010 at 08:32:31PM -0000, jbrassow at sourceware.org wrote:
> 	the failure of a device that contained both a image of
> 	a mirror and an image of the mirrored log.  The order
> 	of the handling of those faults was important (and
> 	wrong), this patch corrects that.

"order...was important...and wrong...this patch corrects..."

Can you be a bit more specific?
Why was it important?
What was wrong about it?
What does this patch do to correct it?

We need something more precise for WHATS_NEW.
 	
Alasdair


