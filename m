From: David Teigland <teigland@redhat.com>
Date: Fri, 10 Sep 2021 08:11:57 -0500
Subject: [PATCH 0/3] cov: fix memory leak caused by abnormal exit
In-Reply-To: <8dfc7c3b-6be6-bea4-6b13-11b1bffc0215@huawei.com>
References: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
	<8dfc7c3b-6be6-bea4-6b13-11b1bffc0215@huawei.com>
Message-ID: <20210910131156.GA30860@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Sep 10, 2021 at 10:21:50AM +0800, Zhiqiang Liu wrote:
> ping...
> 
> On 2021/8/30 15:12, Wu Guanghao wrote:
> > Several possible memory leaks were discovered through tool scans
> >
> > wuguanghao (3):
> >   cmdlib_lvm2_init: release cmd after registration failed
> >   read_adopt_file: Set the default value of r to NULL,
> >         and release r when exiting abnormally
> >   read_adopt_file: fix memory leak

this commit addressed part of that, but the first didn't seem quite right.
https://sourceware.org/git/?p=lvm2.git;a=blobdiff;f=daemons/lvmlockd/lvmlockd-core.c;h=c570b9d14eb6ec0db4e0bffb371a3cd70c67d9b6;hp=fef9589b9d985e5767c19db2650235fbfd406f7f;hb=62c599f78151e65105c92c87ac406e3f3f360b1a;hpb=350f8845bd39dd7aaf5a52ad5deff6859fd06568


