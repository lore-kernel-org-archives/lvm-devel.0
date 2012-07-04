From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 4 Jul 2012 21:26:06 +0100
Subject: liblvm2app stripe_size reported wrong
In-Reply-To: <201207041320.24826.benscott@nwlink.com>
References: <201207041320.24826.benscott@nwlink.com>
Message-ID: <20120704202606.GK22022@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 04, 2012 at 01:20:24PM -0700, ben wrote:
> Using Debian liblvm2app2.2:amd64   version 2.02.95-4 the size of stripes on 
> segments is reported incorrectly from the library function. The number of 
> bytes is divided by 512, which I assume is sectors.
 
Please be specific.
Which function?
What value does it give you?
What should it give you?
What does the output of 'lvs' show?

Alasdair


