From: ben <benscott@nwlink.com>
Date: Wed, 4 Jul 2012 14:01:36 -0700
Subject: liblvm2app stripe_size reported wrong
In-Reply-To: <20120704205301.GM22022@agk-dp.fab.redhat.com>
References: <201207041320.24826.benscott@nwlink.com>
	<201207041341.29807.benscott@nwlink.com>
	<20120704205301.GM22022@agk-dp.fab.redhat.com>
Message-ID: <201207041401.37385.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wednesday, July 04, 2012 1:53:01 PM Alasdair G Kergon wrote:
 
> Well this field is stored in sectors internally, so it's probably just
> returning that value directly.
> 
> Whether it should be converting or not, I don't know.
> This doesn't seem to be documented and so we'll need to look at how other
> fields are handled to see if there's a consistent 'rule' here or not.
> 
> Alasdair

Sector size is changing to a mix of 512 and 4k which will add to the confusion 
if it reports sectors.



