From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 7 Feb 2018 17:49:33 +0100
Subject: master - pvmove: reinstantiate clustered pvmove
In-Reply-To: <5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
References: <201802012058.w11KwnMa018375@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5cecc671-dbc2-c0d7-e1a9-64d4bcb68860@suse.com>
Message-ID: <d278fca1-00a6-d29b-925f-047aed4c949e@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.2.2018 v 08:17 Eric Ren napsal(a):
> Hello Zdenek,
> 
> I've tried this patch with clvmd and cmirrord running, and all LVs in 
> clustered VG being activated
> on both nodes. But, pvmove still cannot work as expect - move data on 
> underlying PV of the the
> non-exclusive activated LV.
> 
> ==========
> tw1:~ # pgrep -a mirrord
> 11931 cmirrord
> tw1:~ # pgrep -a clvmd
> 11748 /usr/sbin/clvmd -T90 -d0
> 
> tw1:~ # vgs -o+vg_clustered vgtest2
>  ??? VG????? #PV #LV #SN Attr?? VSize VFree Clustered
>  ??? vgtest2?? 2?? 2?? 0 wz--nc 9.30g 6.30g? clustered
> tw1:~ # lvs -o+lv_active_exclusively,lv_active_locally vgtest2
>  ??? LV?? VG????? Attr?????? LSize Pool Origin Data%? Meta%? Move Log Cpy%Sync 
> Convert ActExcl??? ActLocal
>  ??? lv1? vgtest2 -wi-a----- 2.00g active locally
>  ??? lv2? vgtest2 -wi-a----- 1.00g active locally
> tw1:~ # pvs -S vg_name=vgtest2
>  ??? PV???????? VG????? Fmt? Attr PSize PFree
>  ??? /dev/vdb1? vgtest2 lvm2 a--? 4.65g 4.65g
>  ??? /dev/vdb2? vgtest2 lvm2 a--? 4.65g 1.65g
> 
> tw1:~ # pvmove /dev/vdb2
>  ??? Cannot move in clustered VG vgtest2, clustered mirror (cmirror) not 
> detected and LVs are activated non-exclusively.
> ============
> 
> 
> GDB it a little bit. The problem seems because:
> 
> _pvmove_target_present(cmd, 1)
> 
> 
> will always return 0 - "not found".
> 
> During one pvmove command, the _pvmove_target_present() is invoked twice. At 
> first call,
> "segtype->ops->target_present()", i.e _mirrored_target_present() will set 
> "_mirrored_checked = 0".
> 
> At the second call, _mirrored_target_present() will not go through the 
> following code to get the
> "_mirror_attributes":
> 


Hi

I think I've intentionally kept away locally active LVs,
but in your case where LV is locally active just on a single node,
it still possible we can use such LV for pvmove - although during
pvmove 'restart' it  will be only  'exclusively' activated.

I'll try to think how to 'integrate' back support for  locally
active LVs on a single node back as well.


Regards

Zdenk


