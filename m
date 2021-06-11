From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Fri, 11 Jun 2021 09:53:27 +0800
Subject: [QUESTION] lvmcache_label_scan: checksum error at offset xxx
In-Reply-To: <20210610184415.GA617@redhat.com>
References: <1cefcef9-7a6b-4054-68a6-bc0d7556065d@huawei.com>
	<ecc2153b-e722-a93a-ec15-06e35196397c@redhat.com>
	<897da3d9-6818-05c0-7d77-ec35f7a635b7@huawei.com>
	<20210610184415.GA617@redhat.com>
Message-ID: <22d55c34-1b3f-16ec-b30b-8346a5c1646a@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

A high probability is caused by lock-free scanning, because after the command execution fails,
it is normal to execute it manually again. The specific test script is already in
https://bugzilla.redhat.com/show_bug.cgi?id=1970719

Wu Guanghao

? 2021/6/11 2:44, David Teigland ??:
> Hi, I'm not sure if these specific errors would be caused by the lock-less
> label scan.  I would expect lvm to read valid but old metadata (which it
> expects to find on occasion because of the lock-less scan.)  The full
> command debugging along with a dd of the ondisk metadata areas would be
> most helpful.



