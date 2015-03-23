From: Liuhua Wang <lwang@suse.com>
Date: Mon, 23 Mar 2015 02:26:23 -0600
Subject: Week report - week 12
Message-ID: <55103EAF020000A00000F135@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

[red]

[amber]

[green]

Sle11sp3:

- bsc#850414 /dev/$VGNAME/$LVNAME symlinks missing in SLE11SP3 rescue system
   * reproduce locally,  waiting for feedback

- bsc#914391 - L3: Multipath/LVM boot failure with incomplete root volume
   * seems '/dev/mapper/*-mpath' links are not created successfully.
       let use modify filter and have a try

opensuse:

-bsc#923127- split clvm package into independent specfiles
   * modified lvm2.spec and sred to opensuse:Factory

-bsc# Boot fails during mount of a /etc/fstab entry on LVM partition
    * modified fstab entry as user's and cannot reproduce either.

# sles10sp4 
-bsc#730584 - if lvchange command is invoked through 
  a shell script, the command is getting hanged
   * close as resolved noresponse.

Fate#312262:Automatic recover mirrored LV from a failed PV device
   * discussion with Lidong
   * did some userspace coding
   * tested with the modified kernel modules

Others:
  o Weekly English class(2H)
  o Beijing HA weekly meeting
  o 1:1 talk with Jason
  o All hands meeting with Jason
  o Training about multipath from Mike
  o Team building
 
Best regards,
Liuhua Wang




