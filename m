From: David Teigland <teigland@redhat.com>
Date: Thu, 10 Mar 2016 13:39:37 -0600
Subject: pvchange returns 5 when the other vg is exported
In-Reply-To: <20160310102326.GA14371@wlh-host.lab.bej.apac.novell.com>
References: <20160310102326.GA14371@wlh-host.lab.bej.apac.novell.com>
Message-ID: <20160310193937.GB22047@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Mar 10, 2016 at 06:23:26PM +0800, Liuhua Wang wrote:
> Hi List,
> 
> I did test as below it is ok:
>     vgcreate vg1 /dev/vdb1
>     vgcreate vg2 /dev/vdb2
>     vgexport vg1
>     pvchange -u /dev/vdb2 
> 
> But there is problem with the follwoing sequence:
>     vgcreate vg1 /dev/vdb1
>     vgcreate vg2 /dev/vdb2
>     vgexport vg2
>     pvchange -u /dev/vdb1 
>     Volume group vg2 is exported
>     Cannot process volume group vg2
>     Replacing dev /dev/vdb1 pvid YvlMvgQ0RngwY7Xmqb7w3MBaKkyqvOg0 with dev /dev/vdb1 pvid TK1Y3yunbJ3pw7nK4SWx6ZtyKg1onpZL
>     Physical volume "/dev/vdb1" changed
>     1 physical volume changed / 0 physical volumes not changed
> 
> The reason is that:
>     pvchange()->process_each_pv()-> _process_pvs_in_vgs()->
>     vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
>     if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip, &notfound)) {
>         stack;
>         ret_max = ECMD_FAILED;
>         if (!skip)
>             goto endvg;
>         /* Drop through to eliminate a clustered VG's PVs from the devices list */
>     }
> 
>    Because vg2 is exported and vg2 locates on the head of list, firstly vg_read(vg2) 
>    will cause set read error and cause ignore_vg() to return 1 (read_error != SUCCESS)
>    
>    Then ret_max remains ECMD_FAILED(5) and is returned. I don't think returning error
>    is expected since vg2 has no relationship with /dev/vdb1.

Thanks, I've fixed this here:
https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=0f10823ec910c0a6015b20580f5aa26f209cea04

Dave


