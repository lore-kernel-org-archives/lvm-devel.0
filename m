From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Wed, 9 Jun 2021 17:32:39 +0800
Subject: [QUESTION] lvmcache_label_scan: checksum error at offset xxx
Message-ID: <1cefcef9-7a6b-4054-68a6-bc0d7556065d@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

lvcreate and lvremove execute lvmcache_label_scan() to read the metadata on the lvm device,
but no lock is added for protection. if other processes are currently executing vg_commit() to submit metadata,
then it will go wrong.


lvremove (process1)					
   |--> lvmcache_label_scan()(no lock protection)				
		|-> read metadata data
			 |
			 |
			 | 			
			 |--------->lvm device metadata  				


lvremove (process2)
  ...
  |--> lockd_vg(process_vg)
  |    (Lock the vg that needs to be processed)
  ...
  |--> vg_commit() 								
  	   |--> write metadata data
		     |-----------------> lvm device metadata
  ...
  |--> unlock_vg(process_vg)

Wu Guanghao


