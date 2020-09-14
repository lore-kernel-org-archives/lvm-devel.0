From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Mon, 14 Sep 2020 16:10:37 +0800
Subject: [PATCH 0/4] LVM2: some code cleanups and bugfixs checked by codeDEX tools
In-Reply-To: <33d05bf3-542e-70c1-b63c-f8666cf6a73b@redhat.com>
References: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
	<33d05bf3-542e-70c1-b63c-f8666cf6a73b@redhat.com>
Message-ID: <ffa33c95-707b-65c0-e8a6-d34ce3931609@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Thanks for your review. If you have a better solution for patch 4, please reply by email.

Regards

Wu Guanghao

? 2020/9/11 19:07, Zdenek Kabelac ??:
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
>> ?? lvconvert_poll: check whether lv is a snapshot type in poll_thin_merge_progress
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
> 
> Regards
> 
> Zdenek
> 
> 
> .



