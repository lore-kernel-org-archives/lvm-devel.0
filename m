From: corubba <corubba@gmx.de>
Date: Thu, 27 Oct 2022 03:13:04 +0200
Subject: [PATCH 0/2] report: improve lv_active_remotely and lv_active_exclusively for shared VGs
Message-ID: <752e9d7d-028d-270c-9024-f50feadc2d5a@gmx.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

following a recent conversation [0] on the linux-lvm mailing list, this
patchset aims to improve the lv_active_remotely and lv_active_exclusively
report options so they accurately represent the actual state for LVs in
shared VGs using lvmlockd.

I implemented the proposed changes using `lvmlockd-client.h`, and peeked
at `_query_lv_lock(...)` and `lvmlockctl.c` to get an idea how to query
lvmlockd for lock modes of specific LVs. I also tested them to the best
of my abilities, and are quiet satisfied with the end-result as seen
below.

```
root at node1:~# vgchange --lock-start
root at node1:~# lvchange -ay  'my-local-vg/used-lv'
root at node1:~# lvchange -aey 'my-shared-vg/node1-exclusive-lv'
root at node1:~# lvchange -asy 'my-shared-vg/shared-but-only-node1-lv'
root at node1:~# lvchange -asy 'my-shared-vg/shared-on-both-lv'

root at node1:~# lvs -a -o 'vg_name,vg_shared,vg_lock_type,vg_lock_args,lv_name,lv_uuid,lv_active,lv_active_locally,lv_active_remotely,lv_active_exclusively,lv_lockargs'
   VG           Shared  LockType VLockArgs     LV                       LV UUID                                Active ActLocal       ActRemote  ActExcl            LLockArgs
   my-local-vg                                 used-lv                  bPQnVM-5tvh-zXm2-1SV3-sqSb-FqTN-pk0g6q active active locally            active exclusively
   my-local-vg                                 unused-lv                B9zzl2-k2PV-P1tR-WStf-nfme-gvIi-ij5Jzg
   my-shared-vg  shared sanlock  1.0.0:lvmlock [lvmlock]                2Iuwpm-TA9H-0JSA-EmeS-PaZX-oCzU-jo3X7h active active locally    unknown
   my-shared-vg  shared sanlock  1.0.0:lvmlock node1-exclusive-lv       TDFv2h-gYnZ-dkj4-kAVx-tkCR-gCvf-fXgDK7 active active locally    unknown active exclusively 1.0.0:70254592
   my-shared-vg  shared sanlock  1.0.0:lvmlock node2-exclusive-lv       Pjhy72-Ah71-lPac-mC1f-FH4h-yXYx-JoplUH                          unknown                    1.0.0:71303168
   my-shared-vg  shared sanlock  1.0.0:lvmlock shared-but-only-node1-lv qPVTYt-YGP0-X7kr-afGJ-8PyG-vS1p-FGWQLf active active locally    unknown                    1.0.0:72351744
   my-shared-vg  shared sanlock  1.0.0:lvmlock shared-but-only-node2-lv 0mfufn-JJDI-IoVm-dyUf-soWa-Wy4G-TcGnbe                          unknown                    1.0.0:73400320
   my-shared-vg  shared sanlock  1.0.0:lvmlock shared-on-both-lv        DPsQl2-6pqd-ZUTM-plv6-qR4w-VSZv-6mRwBr active active locally    unknown                    1.0.0:74448896
   my-shared-vg  shared sanlock  1.0.0:lvmlock unused-lv                96X21r-Zm2Z-O2gp-hWVw-ryCb-y6JV-QYQOBk                          unknown                    1.0.0:75497472

root at node1:~# lvmlockctl --info --dump | grep 'type=lv'
   info=r name=TDFv2h-gYnZ-dkj4-kAVx-tkCR-gCvf-fXgDK7 type=lv mode=ex sh_count=0 version=0
   info=r name=Pjhy72-Ah71-lPac-mC1f-FH4h-yXYx-JoplUH type=lv mode=un sh_count=0 version=0
   info=r name=qPVTYt-YGP0-X7kr-afGJ-8PyG-vS1p-FGWQLf type=lv mode=sh sh_count=1 version=0
   info=r name=0mfufn-JJDI-IoVm-dyUf-soWa-Wy4G-TcGnbe type=lv mode=un sh_count=0 version=0
   info=r name=DPsQl2-6pqd-ZUTM-plv6-qR4w-VSZv-6mRwBr type=lv mode=sh sh_count=1 version=0
   info=r name=96X21r-Zm2Z-O2gp-hWVw-ryCb-y6JV-QYQOBk type=lv mode=un sh_count=0 version=0
   info=r name=2Iuwpm-TA9H-0JSA-EmeS-PaZX-oCzU-jo3X7h type=lv mode=un sh_count=0 version=0
```

One thing I noticed is that `lvmlockctl --info` now shows a row for the
sanlock `lvmlock` LV with no lock, which it didn't before. I assume this
is created/triggered by the query for that LV.

Thanks to David Teigland for his guidance.


[0] https://listman.redhat.com/archives/linux-lvm/2022-October/026293.html

----
Greetings

Corubba

