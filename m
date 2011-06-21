From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 21 Jun 2011 19:39:09 +0100
Subject: [PATCH] Fail allocation if number of extents not divisible by area count
In-Reply-To: <1308679642-14694-1-git-send-email-mbroz@redhat.com>
References: <1308679642-14694-1-git-send-email-mbroz@redhat.com>
Message-ID: <20110621183908.GJ19996@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jun 21, 2011 at 08:07:22PM +0200, Milan Broz wrote:
> Allocation should fail early if this condition is not met.
 
Ack, as discussed.

(Really, the tools layer should be dealing with these cases so they
don't reach this code.  E.g. lvresize checks and rounds the size.)

Alasdair


