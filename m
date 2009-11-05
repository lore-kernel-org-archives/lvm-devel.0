From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 5 Nov 2009 10:46:47 -0600
Subject: [PATCH 1 of 1] LVM: add split capability
In-Reply-To: <20091103142706.GK13375@agk-dp.fab.redhat.com>
References: <200910302323.n9UNN2nV009157@hydrogen.msp.redhat.com>
	<20091103142706.GK13375@agk-dp.fab.redhat.com>
Message-ID: <F6A35F2D-D3F2-4EAB-A6A0-2A22F0DAC7F8@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Nov 3, 2009, at 8:27 AM, Alasdair G Kergon wrote:

> On Fri, Oct 30, 2009 at 06:23:02PM -0500, Jon Brassow wrote:
>> Patch name: lvm-add-split-capability.patch
>
> Patch doesn't apply/compile - log_count undefined, and  
> lv_split_mirror_images
> not exported.
>
> Please fix and repost.

Indeed, this is because this patch was to come after the 'redundant  
mirror log' patch series.

I will fix this patch to put it up front and address Petr's concerns.

  brassow


