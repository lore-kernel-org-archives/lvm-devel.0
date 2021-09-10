From: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Date: Fri, 10 Sep 2021 10:21:50 +0800
Subject: [PATCH 0/3] cov: fix memory leak caused by abnormal exit
In-Reply-To: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
References: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
Message-ID: <8dfc7c3b-6be6-bea4-6b13-11b1bffc0215@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ping...

On 2021/8/30 15:12, Wu Guanghao wrote:
> Several possible memory leaks were discovered through tool scans
>
> wuguanghao (3):
>   cmdlib_lvm2_init: release cmd after registration failed
>   read_adopt_file: Set the default value of r to NULL,
>         and release r when exiting abnormally
>   read_adopt_file: fix memory leak
>
>  daemons/lvmlockd/lvmlockd-core.c | 7 +++++--
>  tools/lvmcmdlib.c                | 4 +++-
>  2 files changed, 8 insertions(+), 3 deletions(-)
>
> --
> 2.23.0
>
> .


