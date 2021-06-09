From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 9 Jun 2021 13:09:31 +0200
Subject: [QUESTION] lvmcache_label_scan: checksum error at offset xxx
In-Reply-To: <1cefcef9-7a6b-4054-68a6-bc0d7556065d@huawei.com>
References: <1cefcef9-7a6b-4054-68a6-bc0d7556065d@huawei.com>
Message-ID: <ecc2153b-e722-a93a-ec15-06e35196397c@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 09. 06. 21 v 11:32 Wu Guanghao napsal(a):
> Hi,
>
> lvcreate and lvremove execute lvmcache_label_scan() to read the metadata on the lvm device,
> but no lock is added for protection. if other processes are currently executing vg_commit() to submit metadata,
> then it will go wrong.



Hi

The initial scan is going 'lockless' to avoid holding VG locks for too long 
when it's not strictly necessary.

The purpose of this scan is to quickly collect & cache all the info which is 
needed to know. The we take the lock and essentially do another 'rescan' 
however in this case we only need to 'check' if the cache data corresponds to 
the current disk state by checking only PV small header information.

Another 'side' efffect? (probably not very used) is that user may specify VG 
via? VG UUID, but for the VG lock we need to use VG name - so we need to be 
able to 'translate' UUID to vgname - and for this we need to know lvm2 
metadata with this info.

Now when the parallel processe manages to change some data (while holding its 
lock), such internal disk cache will be thrown away (PV header will mismatch) 
and this particular PV is rereaded while the command now holds the correct 
lock. But this is really very occasional situation and the benefit of lockless 
asynchronous scanning outweighs this.


Regards


Zdenek



