From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 14 Jan 2008 14:29:02 +0000
Subject: [PATCH 1/11] lvconvert takes '--wait' instead of '--background'
In-Reply-To: <4787FF3C.8010503@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com> <4787FF3C.8010503@ce.jp.nec.com>
Message-ID: <20080114142902.GC8075@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 11, 2008 at 06:43:56PM -0500, Jun'ichi Nomura wrote:
> Remove '--background' option and add '--wait' option to lvconvert.
 
> The option was inherited from pvmove.
> However, since lvconvert used to exit immediately and it still does
> for different types of conversion (e.g. linear to mirror conversion),
> it's more consistent and intuitive to add '--wait' option for foreground
> polling and do it in background by default.
 
I'm not yet persuaded about the need for this change.

The aim is that the behaviour of the tools be consistent across
the whole command set.

Waiting for the operation to complete feels more intuitive to me.

(It's the existing cases where we don't wait for the kernel to
finish its initial copy that feel wrong to me.)

Alasdair
-- 
agk at redhat.com


