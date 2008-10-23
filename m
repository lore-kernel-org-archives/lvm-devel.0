From: Milan Broz <mbroz@redhat.com>
Date: Thu, 23 Oct 2008 09:45:52 +0200
Subject: [PATCH] Fix _mimagetmp left activated after upconversion of inactive mirrored LV
In-Reply-To: <490020E8.4000401@ce.jp.nec.com>
References: <490020E8.4000401@ce.jp.nec.com>
Message-ID: <49002BB0.3060603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
>> commit e36b529d7381725e839befcf001e9453eda6886a
>> Author: Alasdair Kergon <agk@redhat.com>
>> Date:   Fri Oct 17 10:57:14 2008 +0000
>>
>>     Use temp table to set device size when converting mirrors.
>>     
>>     (Avoids having same mirror table loaded twice concurrently by first
>>     using a 'zero' table to set the size of the device so when mirror
>>     table is preloaded it doesn't have to be activated immediately.)
> 
> This change broke t-mirror-vgreduce-removemissing.sh test.

Hi,

yes, it broke tests and not only this test. There is already patch,
but unfortunately not yet in CVS/git...

This commit also introduced using zero target, which is not guaranteed
to be properly initialized there (try to run without dm_zero loaded),
so new patch also uses error target instead for temporary mapping.


Thanks,
Milan


