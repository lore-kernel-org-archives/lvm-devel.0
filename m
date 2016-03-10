From: Liuhua Wang <lwang@suse.com>
Date: Thu, 10 Mar 2016 18:23:26 +0800
Subject: pvchange returns 5 when the other vg is exported
Message-ID: <20160310102326.GA14371@wlh-host.lab.bej.apac.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi List,

I did test as below it is ok:
    vgcreate vg1 /dev/vdb1
    vgcreate vg2 /dev/vdb2
    vgexport vg1
    pvchange -u /dev/vdb2 

But there is problem with the follwoing sequence:
    vgcreate vg1 /dev/vdb1
    vgcreate vg2 /dev/vdb2
    vgexport vg2
    pvchange -u /dev/vdb1 
    Volume group vg2 is exported
    Cannot process volume group vg2
    Replacing dev /dev/vdb1 pvid YvlMvgQ0RngwY7Xmqb7w3MBaKkyqvOg0 with dev /dev/vdb1 pvid TK1Y3yunbJ3pw7nK4SWx6ZtyKg1onpZL
    Physical volume "/dev/vdb1" changed
    1 physical volume changed / 0 physical volumes not changed

The reason is that:
    pvchange()->process_each_pv()-> _process_pvs_in_vgs()->
    vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
    if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip, &notfound)) {
        stack;
        ret_max = ECMD_FAILED;
        if (!skip)
            goto endvg;
        /* Drop through to eliminate a clustered VG's PVs from the devices list */
    }

   Because vg2 is exported and vg2 locates on the head of list, firstly vg_read(vg2) 
   will cause set read error and cause ignore_vg() to return 1 (read_error != SUCCESS)
   
   Then ret_max remains ECMD_FAILED(5) and is returned. I don't think returning error
   is expected since vg2 has no relationship with /dev/vdb1.

Attached is the output of `pvchange -u /dev/vdb1 -vvvv`

Thank you very much.

Best regards,
Liuhua 





-- 
---
Liuhua Wang
-------------- next part --------------
  LV   VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home system -wi-ao----  3.00g                                                    
  root system -wi-ao---- 10.00g                                                    
  swap system -wi-ao----  2.00g                                                    
