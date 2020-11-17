From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Tue, 17 Nov 2020 19:20:49 +0800
Subject: [QUESTION] VG refresh: remove disk and reinsert disk, VG not refresh
In-Reply-To: <20201116164102.GA10385@redhat.com>
References: <7b0ca534-c927-7e15-a6ce-52edc5a1805d@huawei.com>
	<20201116164102.GA10385@redhat.com>
Message-ID: <82ce604b-a2aa-4591-1f10-a5f37352b406@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thank you for your answer, we will solve this problem in our own way.

? 2020/11/17 0:41, David Teigland ??:
> On Mon, Nov 16, 2020 at 11:15:50AM +0800, Wu Guanghao wrote:
>> So I want to know how to add vg refresh function in the 2.02.187 and
>> later to keep it the same as 2.02.181, and why delete vg refresh
>> function?
> 
> Sorry, I don't think I quite knew what a proper use of that looked like
> when removing it.  All the cases I saw were unnecessary or were causing
> problems.  The motivation was numerous problems reported about failed
> activation during boot, some involving unwanted refreshes.  A better fix
> might have found a way to preserve it in the stable branch.
> 
> If you're compiling your own lvm it would be simple to restore, enable the
> if 0 section in pvscan.c.
> 
> More generally, refresh didn't fit correctly where it was implemented.  It
> depended on lvmetad (now removed), and was not really related to
> autoactivation.  If an automatic refresh feature is warranted, it should
> be designed and implemented to stand on its own.
> 
> Dave
> 



