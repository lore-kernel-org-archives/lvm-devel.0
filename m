From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 4 Jul 2012 21:57:49 +0100
Subject: lvm2-api usage in GlusterFS
In-Reply-To: <87txxnqvok.fsf@in.ibm.com>
References: <87txxnqvok.fsf@in.ibm.com>
Message-ID: <20120704205749.GN22022@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 04, 2012 at 11:02:11PM +0530, M.Mohan Kumar wrote:
> Also other issues with the patch is resizing and creating a snapshot
> of LV. There is no API to resize a LV and as of now I am using the

int lvm_lv_resize(const lv_t lv, uint64_t new_size);

"NOTE: This function is currently not implemented."

> Is there any plan to add support to resize a LV and create snapshot of
> LV?
 
Well we're about to start a review of the state of this interface, so if
you have any more suggestions, please send them too.

Alasdair


