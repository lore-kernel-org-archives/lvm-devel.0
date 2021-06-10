From: David Teigland <teigland@redhat.com>
Date: Thu, 10 Jun 2021 13:44:15 -0500
Subject: [QUESTION] lvmcache_label_scan: checksum error at offset xxx
In-Reply-To: <897da3d9-6818-05c0-7d77-ec35f7a635b7@huawei.com>
References: <1cefcef9-7a6b-4054-68a6-bc0d7556065d@huawei.com>
	<ecc2153b-e722-a93a-ec15-06e35196397c@redhat.com>
	<897da3d9-6818-05c0-7d77-ec35f7a635b7@huawei.com>
Message-ID: <20210610184415.GA617@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jun 10, 2021 at 05:19:17PM +0800, Wu Guanghao wrote:

> lvm[708341]: /dev/ram0: Checksum error at offset 203776
> lvm[708341]: WARNING: invalid metadata text from /dev/ram0 at 203776.
> lvm[708341]: WARNING: metadata on /dev/ram0 at 203776 has invalid summary for VG.
> lvm[708341]: WARNING: bad metadata text on /dev/ram0 in mda1
> lvm[708341]: WARNING: scanning /dev/ram0 mda1 failed to read metadata summary.

> lvm[639523]: WARNING: Metadata location on /dev/ram0 at 464384 begins with invalid VG name.
> lvm[639523]: WARNING: bad metadata text on /dev/ram0 in mda1
> lvm[639523]: WARNING: scanning /dev/ram0 mda1 failed to read metadata summary.

Hi, I'm not sure if these specific errors would be caused by the lock-less
label scan.  I would expect lvm to read valid but old metadata (which it
expects to find on occasion because of the lock-less scan.)  The full
command debugging along with a dd of the ondisk metadata areas would be
most helpful.

Thanks,
Dave


