From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 12 Mar 2010 13:44:52 -0600
Subject: [PATCH 1 of 11] LVM: agk allocation changes
In-Reply-To: <20100312121941.GA7267@agk-dp.fab.redhat.com>
References: <201003120029.o2C0TvC8027865@hydrogen.msp.redhat.com>
	<20100312121941.GA7267@agk-dp.fab.redhat.com>
Message-ID: <2D4941B1-7C28-4EEA-A7D6-03C0E4613555@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mar 12, 2010, at 6:19 AM, Alasdair G Kergon wrote:

> On Thu, Mar 11, 2010 at 06:29:57PM -0600, Jon Brassow wrote:
>> Patch name: lvm-agk-allocation-changes.patch
>> agk's allocation changes.
>
> You deleted the part of the header that said this is an example patch
> that has only passed one very basic test - that's why I didn't give it
> wider circulation.  People are better off testing the patch series
> without this patch yet.

Yes.  I also didn't explicitly mention that the patch was preliminary  
- mea culpa.

Still, people can test these patches as long as they don't stress the  
'--alloc anywhere' cases.

  brassow


