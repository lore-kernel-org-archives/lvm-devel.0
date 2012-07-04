From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 4 Jul 2012 22:34:51 +0100
Subject: liblvm2app stripe_size reported wrong
In-Reply-To: <201207041401.37385.benscott@nwlink.com>
References: <201207041320.24826.benscott@nwlink.com>
	<201207041341.29807.benscott@nwlink.com>
	<20120704205301.GM22022@agk-dp.fab.redhat.com>
	<201207041401.37385.benscott@nwlink.com>
Message-ID: <20120704213451.GO22022@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 04, 2012 at 02:01:36PM -0700, ben wrote:
> Sector size is changing to a mix of 512 and 4k which will add to the confusion 
> if it reports sectors.

Like in the kernel, we have a convention that sectors are always treated as 512
bytes.
 
commit 0bc382eae4cf77bdec9e5a2fdb11c72db64438bb
Author: Petr Rockai <prockai@redhat.com>
Date:   Thu Nov 25 14:39:02 2010 +0000

    All 'size' values of lvm2app properties should be in bytes.
    Fix 'seg_size' to return bytes.
    
    Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
    Reviewed-by: Petr Rockai <prockai@redhat.com>


But if the assertion that all size values should be in bytes is true, why
did that patch only change one field and not these others?

Alasdair


