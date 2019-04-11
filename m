From: Eric Ren <renzhengeek@gmail.com>
Date: Thu, 11 Apr 2019 21:09:14 +0800
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <62151b2e-c21a-177e-f66b-e2e08857be17@redhat.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
	<47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
	<CAKM4Aexm31mYW8WDeiZ4shCoysCcGjic8zV0XiVqEVZvKz-ecQ@mail.gmail.com>
	<7839ff52-18e5-6a95-9a2a-12ea73457700@redhat.com>
	<CAKM4AezLrUrXZKA=vKMaRHcij3K6UBZpy-RcVXeUB9Wwfszh7Q@mail.gmail.com>
	<62151b2e-c21a-177e-f66b-e2e08857be17@redhat.com>
Message-ID: <CAKM4AeyMsmqmF7NHu9-u0-86LnzrHR4Z5xNt0bmfpLJyoDE0Sw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

> So do you get  'partial' error on thin-pool activation on your physical server ?

Yes, the VG of the thin pool only has one simple physical disk, at
beginning, I also suspected the disk may disconnect at that moment.
But, I start to think maybe it is caused by some reason hidden in the
interaction between lvm and dm driver in kernel.

It can not be reproduced easily, but happens randomly for several
times. The behavior model of lvm abstracted from the upper service is
like:
there are many (64) control flow in parallel, in each  one it loops to
randomly create/activate/delete thin LVs.

The error happened two place:
1. activate the thin LV:  _lv_activate -> _tree_action ->
dev_manager_activate ->  _add_new_lv_to_dtree -> add_areas_line  ->
striped_add_target_line on **metadata LV**,
I don't what .add_target_line() does for?

2. fail to suspend the origin LV when created.

I'm trying to reproduce it in a simple way, will report once succeed :-)

Thanks very much!
Eric


