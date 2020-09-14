From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 14 Sep 2020 13:21:01 +0200
Subject: [PATCH 0/4] LVM2: some code cleanups and bugfixs checked by codeDEX tools
In-Reply-To: <33d05bf3-542e-70c1-b63c-f8666cf6a73b@redhat.com>
References: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
	<33d05bf3-542e-70c1-b63c-f8666cf6a73b@redhat.com>
Message-ID: <4dcccaa4-3865-b6da-4464-c6438ddb2f09@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11. 09. 20 v 13:07 Zdenek Kabelac napsal(a):
> Dne 11. 09. 20 v 11:38 Wu Guanghao napsal(a):
>> When I learn the LVM2 source code and test it, I
>> find some bugs and fix them. At the same time,
>> static scanning tools were used to analyze the code,
>> and several possible problems were found.
>>
>> repo: https://sourceware.org/git/lvm2.git
>> repo link: https://sourceware.org/git/lvm2.git
>> branch: master
>>
>> wuguanghao (4):
>> ?? pvmove: check return value of top_level_lv_name() in _set_up_pvmove_lv
>> ?? lvconvert_poll: check whether lv is a snapshot type in 
>> poll_thin_merge_progress
>> ?? lvconvert: _lvconvert_splitsnapshot check if lv is snapshot type
>> ?? fix core dump when thinpool size more than the remaining space of vg
>>
> 
> 
> Hi
> 
> Great findings - I'll check how they could be applied.
> In some cases you are rather fixed internal error so
> it's always great if some test case which show how
> the error can be hit is provided (like in patch 4)

Hi

So the patches are upstream - although they need some extra care:


1 ->
https://www.redhat.com/archives/lvm-devel/2020-September/msg00059.html
Added handling of lv_name


2 ->
https://www.redhat.com/archives/lvm-devel/2020-September/msg00063.html
Switched  || to &&


3 ->
https://www.redhat.com/archives/lvm-devel/2020-September/msg00069.html
We are actually splitting 'cow'  so  lv_is_cow()


4 ->
https://www.redhat.com/archives/lvm-devel/2020-September/msg00062.html
Fixed differently by correcting evaluation of needed extents for allocation.

Once again thanks for reporting mainly the issue from patch 4.

Regards

Zdenek


